$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Intro.ps1')
$scenes = @(Get-AftermathScenes)
if ($scenes.Count -ne 9) { throw 'Expected nine scenes.' }
foreach ($i in 0..7) {
    if ((Get-AftermathIntroResult $i $scenes.Count) -ne 'Next') { throw "Unexpected scene end at $i" }
    if ((Get-AftermathIntroResult $i $scenes.Count -Skip) -ne 'Launch') { throw "Skip failed at $i" }
}
if ((Get-AftermathIntroResult 8 $scenes.Count) -ne 'Launch') { throw 'Final scene must launch.' }
'Intro flow passed.'
