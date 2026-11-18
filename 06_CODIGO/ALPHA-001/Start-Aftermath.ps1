[CmdletBinding()]
param(
    [switch]$VerifyOnly,
    [ValidateSet('Complete','Skip','Cancel')][string]$SmokeTest
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Intro.ps1')
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') -Raw | ConvertFrom-Json
$bin = Join-Path $PSScriptRoot 'Bin32'
$exe = Join-Path $bin 'bio4.exe'
foreach ($relative in 'bio4.exe','steam_api.dll','dinput8.dll','xinput1_3.dll','re4modern-core.dll') {
    $entry = $manifest.Files | Where-Object Path -eq ('Bin32\' + $relative)
    if (-not $entry -or (Get-FileHash -LiteralPath (Join-Path $bin $relative)).Hash -ne $entry.SHA256) {
        throw "Runtime binary differs from the manifest: $relative"
    }
}
if (-not (Test-Path -LiteralPath (Join-Path $manifest.Bio4 'St1\r100.udas.lfs') -PathType Leaf)) {
    throw 'The isolated BIO4 profile is missing r100.'
}
if ($VerifyOnly) { Write-Output 'Package binaries and r100 path verified.'; return }
if (-not $SmokeTest -and (Get-Process -Name bio4 -ErrorAction SilentlyContinue)) {
    throw 'Close RE4 before starting this candidate.'
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$scenes = @(Get-AftermathScenes)
$state = @{ Index = 0; Started = $false; Launch = $false }
$form = New-Object Windows.Forms.Form
$form.Text = 'Aftermath - Abertura externa'
$form.StartPosition = 'CenterScreen'
$form.ClientSize = [Drawing.Size]::new(770,380)
$form.BackColor = [Drawing.Color]::FromArgb(18,23,29)
$form.ForeColor = [Drawing.Color]::WhiteSmoke
$form.Font = [Drawing.Font]::new('Segoe UI',13)

$title = New-Object Windows.Forms.Label
$title.SetBounds(44,52,680,80)
$title.Font = [Drawing.Font]::new('Segoe UI',25,[Drawing.FontStyle]::Bold)
$title.Text = 'RESIDENT EVIL 4: AFTERMATH'
$form.Controls.Add($title)
$caption = New-Object Windows.Forms.Label
$caption.SetBounds(45,145,675,125)
$caption.Text = 'Apresentação externa. A campanha de teste abre em seguida no Resident Evil 4 UHD.'
$form.Controls.Add($caption)
$next = New-Object Windows.Forms.Button
$next.SetBounds(45,297,220,45)
$next.Text = 'NEW CAMPAIGN'
$next.ForeColor = [Drawing.Color]::Black
$form.Controls.Add($next)
$skip = New-Object Windows.Forms.Button
$skip.SetBounds(282,297,220,45)
$skip.Text = 'Pular introdução'
$skip.ForeColor = [Drawing.Color]::Black
$skip.Visible = $false
$form.Controls.Add($skip)

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 5400
function Show-Scene {
    $scene = $scenes[$state.Index]
    $title.Text = $scene.Title
    $caption.Text = $scene.Text
}
function Move-Intro([switch]$Skip) {
    if ((Get-AftermathIntroResult $state.Index $scenes.Count -Skip:$Skip) -eq 'Launch') {
        $state.Launch = $true
        $form.Close()
        return
    }
    $state.Index++
    Show-Scene
    $timer.Stop()
    $timer.Start()
}

$next.Add_Click({
    if (-not $state.Started) {
        $state.Started = $true
        $skip.Visible = $true
        $next.Text = 'Avançar'
        Show-Scene
        $timer.Start()
        return
    }
    Move-Intro
})
$skip.Add_Click({ Move-Intro -Skip })
$timer.Add_Tick({ Move-Intro })
if ($SmokeTest) {
    $form.Add_Shown({
        $next.PerformClick()
        switch ($SmokeTest) {
            Complete { foreach ($scene in $scenes) { $next.PerformClick() } }
            Skip { $skip.PerformClick() }
            Cancel { $form.Close() }
        }
    })
}
try { [void]$form.ShowDialog() } finally { $timer.Dispose(); $form.Dispose() }
if ($SmokeTest) {
    if ($state.Launch -ne ($SmokeTest -ne 'Cancel')) { throw "UI smoke test failed: $SmokeTest" }
    Write-Output "UI smoke test passed: $SmokeTest"
    return
}
if ($state.Launch) {
    if (Get-Process -Name bio4 -ErrorAction SilentlyContinue) { throw 'RE4 is already running.' }
    Start-Process -FilePath $exe -WorkingDirectory $bin -ArgumentList ('-gamedir "{0}" -room {1}' -f $manifest.Bio4,$manifest.Room)
}
