[CmdletBinding()]
param([ValidatePattern('^v[0-9]+$')][string]$Version = 'v003')
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
    RelativePath = "ImagePackHD\$stem.pack.lfs"
    BaseSHA256 = (Get-FileHash -LiteralPath (Join-Path $source "$stem.pack.lfs")).Hash
    SHA256 = (Get-FileHash -LiteralPath $archive).Hash
    TextureCount = $actual.Count
    ModifiedTextures = @($changed)
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $work 'manifest.json') -Encoding UTF8
Get-Content -LiteralPath (Join-Path $work 'manifest.json')
