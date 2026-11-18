[CmdletBinding()]
param([switch]$Restore,[switch]$Play,[switch]$IsolatedSavesConfirmed)
$ErrorActionPreference = 'Stop'
if ($Play -and ($Restore -or -not $IsolatedSavesConfirmed)) {
    throw 'Play requires an isolated Steam save profile and -IsolatedSavesConfirmed.'
}
if (Get-Process bio4 -ErrorAction SilentlyContinue) { throw 'Close RE4 first.' }
$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$release = Join-Path $root '08_RELEASES\Aftermath_MAP-002_v001'
$map = Join-Path $root '07_TESTES\MAP-001\v001'
$runtime = Join-Path $map 'Runtime'
$bio = Join-Path $runtime 'BIO4'
$stage = Join-Path $bio 'St1'
$base = Join-Path $map 'Editor\BIO4\St1'
$bin = Join-Path $runtime 'Bin32'
$exe = Join-Path $bin 'bio4.exe'
foreach ($path in @($root,(Join-Path $root '07_TESTES'),(Split-Path $map),$map,$runtime,$bio,$stage,$bin,$exe)) {
    if ((Get-Item -LiteralPath $path -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Unexpected linked path: $path"
    }
}
function Hash([string]$Path) { (Get-FileHash -LiteralPath $Path).Hash }
function Replace([string]$From,[string]$To) {
    $temp = Join-Path $stage ('map002-' + [guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::Copy($From,$temp,$false)
        [IO.File]::Replace($temp,$To,[NullString]::Value)
    } finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp }
    }
}
$manifest = Get-Content -LiteralPath "$release\manifest.json" -Raw | ConvertFrom-Json
$names = @('r100.udas.lfs') + @(0..4 | ForEach-Object {'r100_{0:D2}.dat.lfs' -f $_})
if (@($manifest.Files).Count -ne $names.Count) { throw 'Unexpected file count.' }
$changes = foreach ($name in $names) {
    $entry = @($manifest.Files | Where-Object File -ceq $name)
    if ($entry.Count -ne 1) { throw "Unexpected manifest entry: $name" }
    $original = Join-Path $base $name
    $modified = Join-Path "$release\Payload" $name
    $target = Join-Path $stage $name
    if ((Get-Item -LiteralPath $target -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Unexpected linked archive: $target"
    }
    if ((Hash $original) -ne $entry[0].BaseSHA256 -or (Hash $modified) -ne $entry[0].SHA256) {
        throw "Payload or backup mismatch: $name"
    }
    $current = Hash $target
    if ($current -eq $entry[0].BaseSHA256) { $previous = $original }
    elseif ($current -eq $entry[0].SHA256) { $previous = $modified }
    else { throw "Unknown installed archive: $name" }
    $source = if ($Restore) { $original } else { $modified }
    if ($source -ne $previous) {
        [pscustomobject]@{Source=$source;Target=$target;Previous=$previous}
    }
}
$applied = @()
try {
    foreach ($change in $changes) {
        Replace $change.Source $change.Target
        $applied += $change
        if ((Hash $change.Source) -ne (Hash $change.Target)) { throw "Final hash mismatch: $($change.Target)" }
    }
} catch {
    foreach ($change in $applied) { Replace $change.Previous $change.Target }
    throw
}
if ($Restore) { 'Original r100 archives verified in the test copy.'; return }
'MAP-002 archives verified in the test copy.'
if ($Play) {
    Start-Process -FilePath $exe -WorkingDirectory $bin -ArgumentList ('-gamedir "{0}" -room r100' -f $bio)
}
