[CmdletBinding()]
param([switch]$Restore,[switch]$Play)
$ErrorActionPreference = 'Stop'
if ($Restore -and $Play) { throw 'Choose Restore or Play.' }
if (Get-Process bio4 -ErrorAction SilentlyContinue) { throw 'Close RE4 before changing the local map.' }

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$map = Join-Path $root '07_TESTES\MAP-001'
$runtime = Join-Path $map 'v001\Runtime'
$bio = Join-Path $runtime 'BIO4'
$bin = Join-Path $runtime 'Bin32'
$relative = 'ImagePackHD\44000100.pack.lfs'
$target = Join-Path $bio $relative
$exe = Join-Path $bin 'bio4.exe'
foreach ($path in @($root,(Split-Path $map),$map,(Split-Path $runtime),$runtime,$bio,(Split-Path $target),$target,$bin,$exe)) {
    if ((Get-Item -LiteralPath $path -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Unsupported linked path: $path"
    }
}
$manifest = Get-Content -LiteralPath (Join-Path $map 'v003\manifest.json') -Raw | ConvertFrom-Json
$source = Join-Path $map 'v003\44000100.pack.lfs'
$wanted = $manifest.SHA256
if ($Restore) {
    $source = Join-Path $map "v001\Editor\BIO4\$relative"
    $wanted = $manifest.BaseSHA256
}
if ((Get-FileHash -LiteralPath $source).Hash -ne $wanted) { throw 'Build source hash mismatch.' }
$present = (Get-FileHash -LiteralPath $target).Hash
if ($present -notin @($manifest.SHA256,$manifest.BaseSHA256)) { throw 'Unknown local PACK. Aborting.' }
if ($present -ne $wanted) {
    $stage = Join-Path (Split-Path $target) ("mirante-{0}.tmp" -f [guid]::NewGuid())
    try {
        [IO.File]::Copy($source,$stage,$false)
        if ((Get-FileHash -LiteralPath $stage).Hash -ne $wanted) { throw 'Staged PACK hash mismatch.' }
        [IO.File]::Replace($stage,$target,[NullString]::Value)
    } finally {
        if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage }
    }
}
if ((Get-FileHash -LiteralPath $target).Hash -ne $wanted) { throw 'Local PACK hash mismatch.' }
Write-Output "Local r100 PACK verified: $wanted"
if ($Play) {
    Start-Process -FilePath $exe -WorkingDirectory $bin -ArgumentList ('-gamedir "{0}" -room r100' -f $bio)
}
