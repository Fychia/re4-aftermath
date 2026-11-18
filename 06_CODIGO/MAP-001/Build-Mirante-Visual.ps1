[CmdletBinding()]
param(
    [ValidatePattern('^v[0-9]+$')][string]$Version = 'v003',
    [switch]$Diagnostic
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$base = Join-Path $root '07_TESTES\MAP-001\v001'
$work = Join-Path $root "07_TESTES\MAP-001\$Version"
$packTool = 'F:\Tools\RE4_UHD_PACK_TOOL.V.1.0.8\RE4_UHD_PACK_TOOL.exe'
$lfs = 'F:\Tools\re4-research_build-1.2a\re4lfs.exe'
$stem = '44000100'
$source = Join-Path $base 'Editor\BIO4\ImagePackHD'
if (Test-Path -LiteralPath $work) { throw 'Build already exists.' }
$null = New-Item -ItemType Directory -Path $work
$index = Join-Path $work "$stem.pack.idxpack"
Copy-Item -LiteralPath (Join-Path $source "$stem.pack.idxpack") -Destination $index
Copy-Item -LiteralPath (Join-Path $source $stem) -Destination $work -Recurse

$changed = foreach ($file in (Get-ChildItem -LiteralPath (Join-Path $work $stem) -Filter '*.tga' -File)) {
    $bytes = [IO.File]::ReadAllBytes($file.FullName)
    if ($bytes.Length -lt 18 -or $bytes[1] -ne 0 -or $bytes[2] -ne 2 -or $bytes[16] -ne 32) { continue }
    $width = [BitConverter]::ToUInt16($bytes,12)
    $height = [BitConverter]::ToUInt16($bytes,14)
    if ($width -lt 128 -or $height -lt 128) { continue }
    $start = 18 + $bytes[0]
    $end = $start + 4 * [long]$width * $height
    if ($end -gt $bytes.Length) { throw "Truncated TGA: $($file.Name)" }
    # Preserve the alpha channel, dimensions, and container metadata.
    for ($i = $start; $i -lt $end; $i += 4) {
        $bytes[$i] = [byte][Math]::Min(255, [Math]::Round($bytes[$i] * 0.90 + 14))
        $bytes[$i+1] = [byte][Math]::Round($bytes[$i+1] * 0.76)
        $bytes[$i+2] = [byte][Math]::Round($bytes[$i+2] * 0.62)
    }
    [IO.File]::WriteAllBytes($file.FullName,$bytes)
    $file.Name
}
if ($Diagnostic) {
    Add-Type -TypeDefinition @'
using System;
public static class MiranteDxt1
{
    public static void Mark(byte[] data)
    {
        if (data.Length < 128 || BitConverter.ToUInt32(data, 0) != 0x20534444 ||
            BitConverter.ToUInt32(data, 4) != 124 ||
            BitConverter.ToUInt32(data, 84) != 0x31545844)
            throw new ArgumentException("Expected a legacy DXT1 DDS.");
        int height = BitConverter.ToInt32(data, 12);
        int width = BitConverter.ToInt32(data, 16);
        int levels = Math.Max(1, BitConverter.ToInt32(data, 28));
        if (height < 1 || height > 16384 || width < 1 || width > 16384 || levels > 15)
            throw new ArgumentException("Unexpected DDS dimensions.");
        int offset = 128;
        for (int level = 0; level < levels; ++level)
        {
            int end = offset + ((height + 3) / 4) * ((width + 3) / 4) * 8;
            if (end > data.Length) throw new ArgumentException("Truncated DDS mipchain.");
            for (; offset < end; offset += 8)
            {
                ushort a = BitConverter.ToUInt16(data, offset);
                ushort b = BitConverter.ToUInt16(data, offset + 2);
                uint selectors = BitConverter.ToUInt32(data, offset + 4);
                // Preserve transparent texels from blocks that originally used 3-color BC1.
                uint mask = a <= b ? selectors & (selectors >> 1) & 0x55555555u : 0;
                uint output = mask | (mask << 1);
                int shade = 17 + (((a >> 5) & 63) + ((b >> 5) & 63)) / 10;
                ushort magenta = (ushort)((shade << 11) | shade);
                Buffer.BlockCopy(BitConverter.GetBytes(magenta), 0, data, offset, 2);
                Buffer.BlockCopy(BitConverter.GetBytes(magenta), 0, data, offset + 2, 2);
                Buffer.BlockCopy(BitConverter.GetBytes(output), 0, data, offset + 4, 4);
            }
            width = Math.Max(1, width / 2);
            height = Math.Max(1, height / 2);
        }
    }
}
'@
    $changed += @(foreach ($file in (Get-ChildItem -LiteralPath (Join-Path $work $stem) -Filter '*.dds' -File)) {
        $bytes = [IO.File]::ReadAllBytes($file.FullName)
        [MiranteDxt1]::Mark($bytes)
        [IO.File]::WriteAllBytes($file.FullName,$bytes)
        $file.Name
    })
}
if (-not $changed) { throw 'No textures were graded.' }

$pack = Join-Path $work "$stem.pack"
& $packTool '-bat' $index | Out-Null
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $pack)) { throw 'PACK repack failed.' }
& $lfs $pack | Out-Null
$archive = "$pack.lfs"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $archive)) { throw 'LFS pack failed.' }
$check = Join-Path $work 'Verified'
$null = New-Item -ItemType Directory -Path $check
$roundTrip = Join-Path $check "$stem.pack"
& $lfs $archive $roundTrip | Out-Null
if ($LASTEXITCODE -ne 0 -or (Get-FileHash -LiteralPath $pack).Hash -ne (Get-FileHash -LiteralPath $roundTrip).Hash) {
    throw 'LFS round-trip mismatch.'
}
& $packTool '-bat' $roundTrip | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'PACK re-extraction failed.' }
$expected = @(Get-ChildItem -LiteralPath (Join-Path $work $stem) -File)
$actual = @(Get-ChildItem -LiteralPath (Join-Path $check $stem) -File)
if ($expected.Count -ne $actual.Count) { throw 'Texture count mismatch.' }
foreach ($file in $expected) {
    $other = Join-Path (Join-Path $check $stem) $file.Name
    if ((Get-FileHash -LiteralPath $file.FullName).Hash -ne (Get-FileHash -LiteralPath $other).Hash) {
        throw "Re-extracted texture mismatch: $($file.Name)"
    }
}
[ordered]@{
    Room = 'r100'
    Diagnostic = [bool]$Diagnostic
    RelativePath = "ImagePackHD\$stem.pack.lfs"
    BaseSHA256 = (Get-FileHash -LiteralPath (Join-Path $source "$stem.pack.lfs")).Hash
    SHA256 = (Get-FileHash -LiteralPath $archive).Hash
    TextureCount = $actual.Count
    ModifiedTextures = @($changed)
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $work 'manifest.json') -Encoding UTF8
Get-Content -LiteralPath (Join-Path $work 'manifest.json')
