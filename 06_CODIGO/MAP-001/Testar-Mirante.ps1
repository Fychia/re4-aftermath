[CmdletBinding()]
param(
    [ValidatePattern('^v[0-9]+(?:-[A-Za-z0-9-]+)?$')]
    [string]$Version = 'v001'
)
$ErrorActionPreference = 'Stop'
$project = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$work = Join-Path $project "07_TESTES\MAP-001\$Version"
$editor = Join-Path $work 'Editor\BIO4'
$runtime = Join-Path $work 'Runtime\BIO4'

function Assert-Manifest([string]$Base, [object[]]$Entries) {
    foreach ($entry in $Entries) {
        $file = Join-Path $Base $entry.RelativePath
        $data = Get-Item -LiteralPath $file
        if ($data.Length -ne [long]$entry.Bytes -or
            (Get-FileHash -Algorithm SHA256 -LiteralPath $file).Hash -ne $entry.SHA256) {
            throw "Manifest mismatch: $file"
        }
    }
}

$profile = Get-Content -LiteralPath (Join-Path $work 'profile.json') -Raw | ConvertFrom-Json
if ($profile.Status -ne 'BuildVerified_RuntimePending' -or $profile.Room -ne 'r100' -or $profile.Bio4 -ne $runtime) {
    throw 'Unexpected build profile.'
}
$inventory = @(Import-Csv -LiteralPath (Join-Path $work 'inventory.csv'))
$editorManifest = @(Import-Csv -LiteralPath (Join-Path $work 'editor-manifest.csv'))
if ($inventory.Count -ne 17 -or $editorManifest.Count -eq 0) { throw 'Incomplete inventory.' }
Assert-Manifest $editor $editorManifest
Assert-Manifest $runtime $inventory

$runtimeEsl = Join-Path $runtime 'Etc\emleon00.esl.lfs'
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $runtimeEsl).Hash -ne $profile.RuntimeEslSha256) {
    throw 'Runtime ESL hash mismatch.'
}
$files = Get-ChildItem -LiteralPath $runtime -Recurse -File -Force | Measure-Object Length -Sum
if ($files.Count -ne $profile.RuntimeFileCount -or $files.Sum -ne $profile.RuntimeBytes) {
    throw 'Runtime totals differ from the verified build.'
}
[pscustomobject]@{
    Version = $Version
    ReferenceArchivesVerified = $inventory.Count
    EditorFilesVerified = $editorManifest.Count
    RuntimeFilesCounted = $files.Count
    RuntimeBytesCounted = $files.Sum
    InGameValidation = 'Pending'
}
