[CmdletBinding()]
param(
    [ValidatePattern('^v[0-9]+(?:-[A-Za-z0-9-]+)?$')]
    [string]$Version = 'v001',
    [string]$GameRoot = 'F:\Steam\steamapps\common\Resident Evil 4',
    [string]$ToolsRoot = 'F:\Tools',
    [switch]$InventoryOnly
)
$ErrorActionPreference = 'Stop'
$project = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$gameBio = (Get-Item -LiteralPath (Join-Path $GameRoot 'BIO4')).FullName
$work = Join-Path $project "07_TESTES\MAP-001\$Version"
$baselineHash = '3711B09CD45AC5D7D35D1C5A345097013D980EEB4D9F17AEC6B9EA3A0721C3DE'
$backup = Join-Path $project '07_TESTES\BACKUP_STEAM\emleon00.esl.lfs'
$lfs = Join-Path $ToolsRoot 're4-research_build-1.2a\re4lfs.exe'
$udas = Join-Path $ToolsRoot 'JADERLINK_DATUDAS_TOOL.V.1.0.4\JADERLINK_DATUDAS_TOOL.exe'
$pack = Join-Path $ToolsRoot 'RE4_UHD_PACK_TOOL.V.1.0.8\RE4_UHD_PACK_TOOL.exe'

function Get-Sha256([string]$Path) {
    (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Invoke-Extractor([string]$Executable, [string[]]$Arguments, [string]$Expected) {
    & $Executable @Arguments | Out-Host
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $Expected -PathType Leaf)) {
        throw "Extraction failed ($LASTEXITCODE). Expected $Expected"
    }
    if ((Get-Item -LiteralPath $Expected).Length -eq 0) { throw "Empty output: $Expected" }
}

function Assert-PlainPath([string]$Path) {
    while ($Path) {
        if (Test-Path -LiteralPath $Path) {
            $item = Get-Item -LiteralPath $Path -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw "Reparse point is unsupported: $Path"
            }
        }
        $Path = Split-Path -Parent $Path
    }
}

$rooms = 'r100', 'r101', 'r103', 'r104'
$inventory = foreach ($room in $rooms) {
    $paths = @("St1\$room.udas.lfs", "ImagePack\44000$($room.Substring(1)).pack.lfs",
        "ImagePackHD\44000$($room.Substring(1)).pack.lfs")
    if ($room -eq 'r100') {
        $paths += 0..4 | ForEach-Object { 'St1\r100_{0:D2}.dat.lfs' -f $_ }
    }
    foreach ($relative in $paths) {
        $source = Get-Item -LiteralPath (Join-Path $gameBio $relative)
        if ($source.PSIsContainer -or $source.Length -eq 0) { throw "Invalid source: $relative" }
        [pscustomobject]@{ Room = $room; RelativePath = $relative; Bytes = $source.Length; SHA256 = Get-Sha256 $source.FullName }
    }
}

if ($InventoryOnly) { $inventory; return }
if (Test-Path -LiteralPath $work) { throw "Build directory already exists: $work" }
Assert-PlainPath $work
Assert-PlainPath $gameBio
if ($work.StartsWith((Split-Path -Parent $gameBio) + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Build directory must be outside the game installation.'
}
if ((Get-Sha256 $backup) -ne $baselineHash) { throw 'Unexpected original ESL backup hash.' }
foreach ($tool in $lfs, $udas, $pack) {
    if (-not (Test-Path -LiteralPath $tool -PathType Leaf)) { throw "Missing tool: $tool" }
}

$extracted = Join-Path $work 'Editor\BIO4'
New-Item -ItemType Directory -Path $extracted | Out-Null
$inventory | Export-Csv -LiteralPath (Join-Path $work 'inventory.csv') -NoTypeInformation -Encoding UTF8
foreach ($entry in $inventory) {
    if ($entry.RelativePath -like 'ImagePack\*') { continue }
    $target = Join-Path $extracted $entry.RelativePath
    New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $gameBio $entry.RelativePath) -Destination $target
    if ((Get-Sha256 $target) -ne $entry.SHA256) { throw "Source copy mismatch: $target" }
    $unpacked = $target.Substring(0, $target.Length - 4)
    Invoke-Extractor $lfs @($target, $unpacked) $unpacked
    if ($unpacked.EndsWith('.pack')) {
        Invoke-Extractor $pack @('-bat', $unpacked) "$unpacked.idxpack"
        if (-not (Get-ChildItem -LiteralPath ($unpacked -replace '\.pack$') -File | Where-Object Extension -in '.dds','.tga')) {
            throw "No images found for $unpacked"
        }
    } else {
        $index = [IO.Path]::ChangeExtension($unpacked, 'idxj')
        Invoke-Extractor $udas @('-bat', $unpacked) $index
    }
}

$expected = @(
    'r100\r100_004.SMD', 'r100\r100_005.SMD', 'r100\r100_006.SMX',
    'r101\r101_004.SMD', 'r101\r101_005.SMX',
    'r103\r103_004.SMD', 'r103\r103_005.SMX',
    'r104\r104_004.SMD', 'r104\r104_005.SMX'
)
$expected += 0..4 | ForEach-Object { 'r100_{0:D2}\r100_{0:D2}_000.SMD' -f $_ }
foreach ($relative in $expected) {
    $component = Get-Item -LiteralPath (Join-Path "$extracted\St1" $relative)
    if ($component.PSIsContainer -or $component.Length -eq 0) { throw "Invalid editor component: $relative" }
}

$editorManifest = Get-ChildItem -LiteralPath $extracted -Recurse -File | ForEach-Object {
    [pscustomobject]@{
        RelativePath = $_.FullName.Substring($extracted.Length + 1)
        Bytes = $_.Length
        SHA256 = Get-Sha256 $_.FullName
    }
}
$editorManifest | Export-Csv -LiteralPath (Join-Path $work 'editor-manifest.csv') -NoTypeInformation -Encoding UTF8

$runtime = Join-Path $work 'Runtime\BIO4'
$sourceFiles = @(Get-ChildItem -LiteralPath $gameBio -Recurse -File -Force)
$links = Get-ChildItem -LiteralPath $gameBio -Recurse -Force -Attributes ReparsePoint
if ($links) { throw 'BIO4 contains unsupported reparse points.' }
$sourceBytes = ($sourceFiles | Measure-Object -Property Length -Sum).Sum
$drive = Get-PSDrive -Name $project.Substring(0,1)
if ($drive.Free -lt $sourceBytes) { throw "Insufficient space for independent BIO4 copy ($sourceBytes bytes)." }
$copyLog = Join-Path $work 'runtime-copy.log'
& robocopy.exe $gameBio $runtime /E /XJ /R:0 /W:0 /NP "/LOG:$copyLog" | Out-Host
if ($LASTEXITCODE -ge 8) { throw "Robocopy failed: $LASTEXITCODE" }

# Substitute the documented baseline in the new local tree only.
$runtimeEsl = Join-Path $runtime 'Etc\emleon00.esl.lfs'
Copy-Item -LiteralPath $backup -Destination $runtimeEsl
if ((Get-Sha256 $runtimeEsl) -ne $baselineHash) { throw 'Runtime baseline mismatch.' }
$runtimeFiles = @(Get-ChildItem -LiteralPath $runtime -Recurse -File -Force)
if ($runtimeFiles.Count -ne $sourceFiles.Count) { throw 'Runtime file count mismatch.' }
foreach ($source in $sourceFiles) {
    $relative = $source.FullName.Substring($gameBio.Length + 1)
    if ($relative -eq 'Etc\emleon00.esl.lfs') { continue }
    $target = Get-Item -LiteralPath (Join-Path $runtime $relative)
    if ($target.Length -ne $source.Length) { throw "Runtime size mismatch: $relative" }
}
foreach ($entry in $inventory) {
    if ((Get-Sha256 (Join-Path $runtime $entry.RelativePath)) -ne $entry.SHA256) {
        throw "Runtime archive hash mismatch: $($entry.RelativePath)"
    }
}
[ordered]@{
    Version = $Version
    Room = 'r100'
    RoomArguments = @('-room', 'r100')
    Bio4 = $runtime
    Status = 'BuildVerified_RuntimePending'
    RuntimeFileCount = $runtimeFiles.Count
    RuntimeBytes = ($runtimeFiles | Measure-Object -Property Length -Sum).Sum
    RuntimeEslSha256 = $baselineHash
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $work 'profile.json') -Encoding UTF8
Write-Output "Verified build: $work"
