$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$map = Join-Path $root '07_TESTES\MAP-001'
$work = Join-Path $root ('07_TESTES\MAP-002-v001-' + [guid]::NewGuid().ToString('N'))
$release = Join-Path $root '08_RELEASES\Aftermath_MAP-002_v001'
$base = Join-Path $map 'v001\Editor\BIO4\St1'
$source = Join-Path $map 'Geometria-R100'
$edit = Join-Path $work 'Geometry'
$smd = Join-Path $map 'GeometryTools\SMD\RE4_UHD_SCENARIO_SMD_TOOL.exe'
$sat = Join-Path $map 'GeometryTools\SAT\RE4_SAT_EAT_REPACK.exe'
$udas = 'F:\Tools\JADERLINK_DATUDAS_TOOL.V.1.0.4\JADERLINK_DATUDAS_TOOL.exe'
$lfs = 'F:\Tools\re4-research_build-1.2a\re4lfs.exe'
if ((Test-Path $work) -or (Test-Path $release)) { throw 'Build directories already exist.' }
$null = New-Item -ItemType Directory $work
$log = Join-Path $work 'build.log'
function Hash($Path) { (Get-FileHash -LiteralPath $Path).Hash }
function Run($Tool, $Options, $Output) {
    & $Tool @Options | Out-File -LiteralPath $log -Append -Encoding UTF8
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $Output -PathType Leaf)) {
        throw "Missing tool output: $Output. See $log."
    }
}
Copy-Item -LiteralPath $source -Destination $edit -Recurse
Add-Type -Path (Join-Path $PSScriptRoot 'DeformarMalha.cs')
$vertices = [ordered]@{}
foreach ($name in 'R100.allparts.obj','r100_001_0.obj','r100_015_0.obj') {
    $n = [DeformarMalha]::Rewrite((Join-Path $source $name),(Join-Path $edit $name))
    if (-not $n) { throw "No changes to $name" }
    $vertices[$name] = $n
}
$names = @('r100') + @(0..4 | ForEach-Object {'r100_{0:D2}' -f $_})
foreach ($file in (Get-ChildItem -LiteralPath $edit -File | Where-Object Extension -in '.SMD','.SAT','.EAT')) {
    Remove-Item -LiteralPath $file.FullName
}
Run $smd @('-bat',"$edit\R100.allparts.idxuur100repack") "$edit\r100_004.SMD"
Run $sat @("$edit\r100_001.idxsat",'UHD') "$edit\r100_001.SAT"
Run $sat @("$edit\r100_015.idxeat",'UHD') "$edit\r100_015.EAT"
$payload = Join-Path $work 'Payload'
$null = New-Item -ItemType Directory $payload
$files = foreach ($name in $names) {
    $case = Join-Path $work $name
    $null = New-Item -ItemType Directory $case
    Copy-Item -LiteralPath "$base\$name" -Destination $case -Recurse
    $idx = "$case\$name.idxJ"
    (Get-Content -LiteralPath "$base\$name.idxJ") -replace '^!(UDAS_(TOP|MIDDLE):)','$1' |
        Set-Content -LiteralPath $idx -Encoding ASCII
    $ext = 'dat'
    $parts = @($name + '_000.SMD')
    if ($name -eq 'r100') {
        $ext = 'udas'
        $parts = 'r100_004.SMD','r100_005.SMD','r100_001.SAT','r100_015.EAT'
    }
    foreach ($part in $parts) { Copy-Item -LiteralPath "$edit\$part" -Destination "$case\$name\$part" -Force }
    $container = "$case\$name.$ext"
    Run $udas @('-bat',$idx) $container
    $verify = "$case\Verify"
    $null = New-Item -ItemType Directory $verify
    $copy = "$verify\$name.$ext"
    Copy-Item -LiteralPath $container -Destination $copy
    Run $udas @('-bat',$copy) "$verify\$name.idxJ"
    $expected = @(Get-ChildItem -LiteralPath "$case\$name" -File)
    if (@(Get-ChildItem -LiteralPath "$verify\$name" -File).Count -ne $expected.Count) {
        throw "Entry count mismatch: $name"
    }
    foreach ($entry in $expected) {
        $reextracted = "$verify\$name\$($entry.Name)"
        if ($entry.Name -eq 'r100_TOP.HEX') {
            $before = [IO.File]::ReadAllBytes($entry.FullName)
            $after = [IO.File]::ReadAllBytes($reextracted)
            if ($before.Length -ne $after.Length) { throw 'UDAS header length changed.' }
            # These two words are rewritten by DATUDAS when laying out the resized room.
            [Array]::Clear($before,36,4); [Array]::Clear($after,36,4)
            [Array]::Clear($before,76,4); [Array]::Clear($after,76,4)
            if ([Convert]::ToBase64String($before) -ne [Convert]::ToBase64String($after)) {
                throw 'UDAS header differs outside the expected layout words.'
            }
        } elseif ((Hash $entry.FullName) -ne (Hash $reextracted)) { throw "Entry mismatch: $entry" }
    }
    Run $lfs @($container) "$container.lfs"
    Run $lfs @("$container.lfs","$verify\roundtrip.bin") "$verify\roundtrip.bin"
    if ((Hash $container) -ne (Hash "$verify\roundtrip.bin")) { throw "LFS mismatch: $name" }
    $file = "$name.$ext.lfs"
    Copy-Item -LiteralPath "$container.lfs" -Destination "$payload\$file"
    [ordered]@{ File = $file; BaseSHA256 = (Hash "$base\$file"); SHA256 = (Hash "$payload\$file"); ReplacedEntries = $parts }
}
$null = New-Item -ItemType Directory $release
Copy-Item -LiteralPath $payload -Destination $release -Recurse
[ordered]@{ Room = 'r100'; CenterObjXZ = @(-790,-145); VertexEdits = $vertices; WorkDirectory = $work; Files = @($files) } |
    ConvertTo-Json -Depth 6 | Set-Content -LiteralPath "$release\manifest.json" -Encoding UTF8
Get-Content -LiteralPath "$release\manifest.json" -Raw
