[CmdletBinding()]
param([switch]$SmokeTest)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'MenuFlow.ps1')
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()

$session = New-MenuSession
$window = New-Object Windows.Forms.Form
$window.Text = 'Aftermath | Standalone menu prototype'
$window.StartPosition = 'CenterScreen'
$window.ClientSize = [Drawing.Size]::new(660, 540)
$window.MinimumSize = [Drawing.Size]::new(560, 560)
$window.BackColor = [Drawing.Color]::FromArgb(23, 28, 33)
$window.ForeColor = [Drawing.Color]::WhiteSmoke
$window.Font = [Drawing.Font]::new('Segoe UI', 11)

$layout = New-Object Windows.Forms.TableLayoutPanel
$layout.Dock = 'Fill'
$layout.Padding = [Windows.Forms.Padding]::new(28)
$layout.ColumnCount = 1
$layout.RowCount = 4
foreach ($row in 1..3) {
    [void]$layout.RowStyles.Add([Windows.Forms.RowStyle]::new([Windows.Forms.SizeType]::AutoSize))
}
[void]$layout.RowStyles.Add([Windows.Forms.RowStyle]::new([Windows.Forms.SizeType]::Percent, 100))
$window.Controls.Add($layout)

$label = New-Object Windows.Forms.Label
$label.AutoSize = $true
$label.Text = 'STANDALONE PROTOTYPE'
$label.ForeColor = [Drawing.Color]::LightSalmon
$layout.Controls.Add($label)

$heading = New-Object Windows.Forms.Label
$heading.AutoSize = $true
$heading.Font = [Drawing.Font]::new('Segoe UI', 24, [Drawing.FontStyle]::Bold)
$layout.Controls.Add($heading)

$details = New-Object Windows.Forms.Label
$details.AutoSize = $true
$details.MaximumSize = [Drawing.Size]::new(470, 0)
$details.Margin = [Windows.Forms.Padding]::new(3, 4, 3, 14)
$layout.Controls.Add($details)

$buttons = New-Object Windows.Forms.FlowLayoutPanel
$buttons.FlowDirection = 'TopDown'
$buttons.WrapContents = $false
$buttons.Dock = 'Fill'
$buttons.AutoScroll = $true
$layout.Controls.Add($buttons)

function Show-MenuScreen {
    $screens = @{
        Title = @('RESIDENT EVIL 4', 'Select AFTERMATH to explore the campaign flow.')
        Aftermath = @('RESIDENT EVIL 4: AFTERMATH', 'Demo checkpoints last until this window closes.')
        Confirm = @('START A NEW CAMPAIGN?', 'Starting over clears the demo checkpoint for this session.')
        Chapters = @('CHAPTER SELECT', 'Play the planned opening of Chapter 1.')
        Intro = @('CHAPTER 1 / INTRO', 'Storyboard: Before dawn, Leon surveys the village. Hunnigan points him toward the outpost and its documents.')
        Chapter = @('CHAPTER 1 / A VILA', 'Simulated arrival at the lookout. Follow the descent to the outpost, then find a way through the village.')
        Extras = @('AFTERMATH EXTRAS', 'The opening storyboard is available from CHAPTER SELECT.')
        Original = @('RESIDENT EVIL 4', 'This action belongs to the original game.')
    }

    $heading.Text, $details.Text = $screens[$session.Screen]
    $window.CancelButton = $null
    foreach ($oldButton in @($buttons.Controls)) { $oldButton.Dispose() }

    foreach ($item in (Get-MenuItems $session)) {
        $button = New-Object Windows.Forms.Button
        $button.Text = $item
        $button.Tag = $item
        $button.Size = [Drawing.Size]::new(305, 40)
        $button.FlatStyle = 'Flat'
        $button.BackColor = [Drawing.Color]::FromArgb(49, 60, 70)
        $button.ForeColor = $window.ForeColor
        $button.Enabled = $item -ne 'CONTINUE' -or $session.CanContinue
        $button.Add_Click({
            param($sender, $eventArgs)
            Invoke-MenuAction $session $sender.Tag
            if ($session.Screen -eq 'Closed') { $window.Close(); return }
            Show-MenuScreen
        })
        $buttons.Controls.Add($button)
        if ($item -eq 'BACK') { $window.CancelButton = $button }
    }

    $first = $buttons.Controls | Where-Object Enabled | Select-Object -First 1
    $window.ActiveControl = $first
}

$window.Add_KeyDown({
    param($sender, $eventArgs)
    if ($eventArgs.KeyCode -in @('Up', 'Down')) {
        $forward = $eventArgs.KeyCode -eq 'Down'
        [void]$buttons.SelectNextControl($buttons.ActiveControl, $forward, $true, $false, $true)
        $eventArgs.SuppressKeyPress = $true
    }
})
$window.KeyPreview = $true

try {
    Show-MenuScreen
    if ($SmokeTest) {
        $window.Add_Shown({
            try {
                foreach ($action in @('AFTERMATH', 'NEW CAMPAIGN', 'SKIP INTRO', 'SAVE DEMO CHECKPOINT', 'CONTINUE', 'BACK', 'BACK')) {
                    $control = $buttons.Controls | Where-Object Tag -eq $action | Select-Object -First 1
                    if (-not $control -or -not $control.Enabled) { throw "Missing UI action: $action" }
                    $control.PerformClick()
                }
                if ($heading.Text -ne 'RESIDENT EVIL 4') { throw 'Expected title after Back.' }
            } catch {
                $session.SmokeFailure = $_
            } finally {
                $window.Close()
            }
        })
    }
    [void]$window.ShowDialog()
    if ($session.SmokeFailure) { throw $session.SmokeFailure }
    if ($SmokeTest) { Write-Output 'UI smoke test passed.' }
} finally {
    $window.Dispose()
}
