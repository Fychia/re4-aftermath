[CmdletBinding()]
param([string]$BuildName = 'Candidate02')

$ErrorActionPreference = 'Stop'
if ($BuildName -notmatch '^[A-Za-z0-9-]+$') { throw 'Invalid build name.' }
$project = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$release = Join-Path $project "08_RELEASES\Aftermath_Alpha_0.1\$BuildName"
$base = Join-Path $project '07_TESTES\MAP-001\v001\Runtime'
$sdk = 'F:\re4-boshjerns-sdk-0.1.1\Bin32'
if (Test-Path -LiteralPath $release) { throw "Build already exists: $release" }
& (Join-Path $project '06_CODIGO\MAP-001\Testar-Mirante.ps1') | Out-Host

$files = [ordered]@{
    'bio4.exe' = Join-Path $base 'Bin32\bio4.exe'
    'steam_api.dll' = Join-Path $base 'Bin32\steam_api.dll'
    'dinput8.dll' = Join-Path $base 'Bin32\dinput8.dll'
    'dinput8.ini' = Join-Path $base 'Bin32\dinput8.ini'
    'xinput1_3.dll' = Join-Path $sdk 'xinput1_3.dll'
    're4modern-core.dll' = Join-Path $sdk 're4modern-core.dll'
}
foreach ($source in $files.Values) {
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing source: $source" }
}
$bin = Join-Path $release 'Bin32'
New-Item -ItemType Directory -Path $bin | Out-Null
foreach ($name in $files.Keys) {
    $target = Join-Path $bin $name
    Copy-Item -LiteralPath $files[$name] -Destination $target
    if ((Get-FileHash -LiteralPath $files[$name]).Hash -ne (Get-FileHash -LiteralPath $target).Hash) {
        throw "Copy mismatch: $name"
    }
}

# Override only the candidate profile. The original INI is never written.
@'
[fun]
mood=2
[movement]
modern_move=0
free_camera=0
move_aim=0
jump=0
[hud]
name=0
[textures]
replace=0
live=0
'@ | Set-Content -LiteralPath (Join-Path $bin 're4modern.ini') -Encoding Ascii

foreach ($name in 'Start-Aftermath.ps1','Intro.ps1','Test-Aftermath.ps1','README.md') {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination $release
}
@'
@echo off
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -STA -File "%~dp0Start-Aftermath.ps1"
if errorlevel 1 pause
'@ | Set-Content -LiteralPath (Join-Path $release 'Jogar-Aftermath.cmd') -Encoding Ascii

$inventory = @(Get-ChildItem -LiteralPath $release -File -Recurse | ForEach-Object {
    [ordered]@{
        Path = $_.FullName.Substring($release.Length+1)
        Bytes = $_.Length
        SHA256 = (Get-FileHash -LiteralPath $_.FullName).Hash
    }
})
[ordered]@{
    Profile = 'Aftermath Alpha 0.1 candidate'
    Status = 'PackageVerified_RuntimeUnverified'
    Room = 'r100'
    Bio4 = Join-Path $base 'BIO4'
    DataChanges = @()
    RuntimeChanges = @('SDK mood=2 candidate', 'RE4 Tweaks direct room launch')
    Files = $inventory
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $release 'manifest.json') -Encoding UTF8
Write-Output $release
