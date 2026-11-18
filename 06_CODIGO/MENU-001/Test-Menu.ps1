$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'MenuFlow.ps1')

function Assert-Screen {
    param([string]$Expected)
    if ($session.Screen -ne $Expected) { throw "Expected $Expected, got $($session.Screen)" }
}

$session = New-MenuSession
if ((Get-MenuItems $session) -join '|' -cne 'NEW GAME|LOAD GAME|AFTERMATH|OPTIONS|EXTRAS|EXIT') {
    throw 'Unexpected root menu.'
}
Invoke-MenuAction $session 'NEW GAME'
Assert-Screen Original
Invoke-MenuAction $session 'BACK'
Invoke-MenuAction $session 'AFTERMATH'
if ((Get-MenuItems $session) -join '|' -cne 'NEW CAMPAIGN|CONTINUE|CHAPTER SELECT|EXTRAS|BACK') {
    throw 'Unexpected campaign menu.'
}
Invoke-MenuAction $session 'CONTINUE'
Assert-Screen Aftermath
Invoke-MenuAction $session 'NEW CAMPAIGN'
Assert-Screen Intro
Invoke-MenuAction $session 'FINISH INTRO'
Assert-Screen Chapter
Invoke-MenuAction $session 'SAVE DEMO CHECKPOINT'
Assert-Screen Aftermath
Invoke-MenuAction $session 'CONTINUE'
Assert-Screen Chapter
Invoke-MenuAction $session 'BACK'
Invoke-MenuAction $session 'CHAPTER SELECT'
Assert-Screen Chapters
Invoke-MenuAction $session 'CHAPTER 1 - A VILA'
Invoke-MenuAction $session 'SKIP INTRO'
Assert-Screen Chapter
Invoke-MenuAction $session 'BACK'
Invoke-MenuAction $session 'NEW CAMPAIGN'
Assert-Screen Confirm
Invoke-MenuAction $session 'BACK'
if (-not $session.CanContinue) { throw 'Cancel must preserve the checkpoint.' }
Invoke-MenuAction $session 'NEW CAMPAIGN'
Invoke-MenuAction $session 'START OVER'
if ($session.CanContinue -or (New-MenuSession).CanContinue) { throw 'Unexpected checkpoint.' }
Invoke-MenuAction $session 'BACK'
Invoke-MenuAction $session 'EXTRAS'
Assert-Screen Extras
Invoke-MenuAction $session 'BACK'
Invoke-MenuAction $session 'BACK'
Assert-Screen Title
$rejected = $false
try { Invoke-MenuAction $session 'SKIP INTRO' } catch { $rejected = $true }
if (-not $rejected) { throw 'Invalid action accepted.' }
Invoke-MenuAction $session 'EXIT'
Assert-Screen Closed
Write-Output 'Menu flow tests passed.'
