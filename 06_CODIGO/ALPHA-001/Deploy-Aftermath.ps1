[CmdletBinding()]
param(
    [switch]$Restore,
    [switch]$Play
)
$ErrorActionPreference = 'Stop'
if ($Restore -and $Play) { throw 'Restore and Play are mutually exclusive.' }
if (Get-Process -Name bio4 -ErrorAction SilentlyContinue) { throw 'Close RE4 before changing the test profile.' }
$project = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$runtime = Join-Path $project '07_TESTES\MAP-001\v001\Runtime'
$bio = Join-Path $runtime 'BIO4'
$bin = Join-Path $runtime 'Bin32'
$target = Join-Path $bio 'Etc\emleon00.esl.lfs'
$original = '3711B09CD45AC5D7D35D1C5A345097013D980EEB4D9F17AEC6B9EA3A0721C3DE'
$modified = '3C50AFE9B6EF403D4212EDD8D653C55E7DB5BF1617BCD3F1319EFF4D0B422998'
$stem = Join-Path $project '07_TESTES'

foreach ($file in @($project,$stem,(Join-Path $stem 'MAP-001'),(Split-Path $runtime),$runtime,
    $bio,(Split-Path $target),$target,$bin,(Join-Path $bin 'bio4.exe'))) {
    if ((Get-Item -LiteralPath $file -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Unsupported linked path: $file"
    }
}

$source = Join-Path $stem 'BUILD\emleon00.esl.lfs'
$desired = $modified
if ($Restore) {
    $source = Join-Path $stem 'BACKUP_STEAM\emleon00.esl.lfs'
    $desired = $original
}
if ((Get-FileHash -LiteralPath $source).Hash -ne $desired) { throw 'Source hash mismatch.' }
$current = (Get-FileHash -LiteralPath $target).Hash
if ($current -notin @($original,$modified)) { throw 'Unknown runtime file; no change applied.' }

if ($current -ne $desired) {
    $stage = Join-Path (Split-Path $target) ("after-test-{0}.tmp" -f [guid]::NewGuid())
    try {
        [IO.File]::Copy($source,$stage,$false)
        if ((Get-FileHash -LiteralPath $stage).Hash -ne $desired) { throw 'Staged payload hash mismatch.' }
        [IO.File]::Replace($stage,$target,[NullString]::Value)
    } finally {
        if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage }
    }
}
if ((Get-FileHash -LiteralPath $target).Hash -ne $desired) { throw 'Final hash mismatch.' }

if ($Restore) { Write-Output 'Isolated original ESL restored and verified.'; return }
Write-Output 'Don Esteban V1 installed and verified in the isolated runtime.'
if ($Play) {
    $exe = Join-Path $bin 'bio4.exe'
    Start-Process -FilePath $exe -WorkingDirectory $bin -ArgumentList ('-gamedir "{0}" -room r101 -EnableDebugMenu 1' -f $bio)
}
