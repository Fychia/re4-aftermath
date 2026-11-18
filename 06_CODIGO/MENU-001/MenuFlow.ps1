function New-MenuSession {
    @{
        Screen = 'Title'
        CanContinue = $false
    }
}

function Get-MenuItems {
    param([hashtable]$Session)

    switch ($Session.Screen) {
        'Title' { 'NEW GAME', 'LOAD GAME', 'AFTERMATH', 'OPTIONS', 'EXTRAS', 'EXIT' }
        'Aftermath' { 'NEW CAMPAIGN', 'CONTINUE', 'CHAPTER SELECT', 'EXTRAS', 'BACK' }
        'Confirm' { 'START OVER', 'BACK' }
        'Chapters' { 'CHAPTER 1 - A VILA', 'BACK' }
        'Intro' { 'FINISH INTRO', 'SKIP INTRO', 'BACK' }
        'Chapter' { 'SAVE DEMO CHECKPOINT', 'BACK' }
        default { 'BACK' }
    }
}

function Invoke-MenuAction {
    param([hashtable]$Session, [string]$Action)

    if ($Action -notin (Get-MenuItems $Session)) {
        throw "Action unavailable on this screen: $Action"
    }

    $transition = "$($Session.Screen)/$Action"
    switch ($transition) {
        'Title/AFTERMATH' { $Session.Screen = 'Aftermath' }
        'Title/EXIT' { $Session.Screen = 'Closed' }
        'Aftermath/BACK' { $Session.Screen = 'Title' }
        'Aftermath/NEW CAMPAIGN' {
            if ($Session.CanContinue) {
                $Session.Screen = 'Confirm'
            } else {
                $Session.Screen = 'Intro'
            }
        }
        'Confirm/START OVER' {
            $Session.CanContinue = $false
            $Session.Screen = 'Intro'
        }
        'Aftermath/CONTINUE' {
            if ($Session.CanContinue) { $Session.Screen = 'Chapter' }
        }
        'Aftermath/CHAPTER SELECT' { $Session.Screen = 'Chapters' }
        'Aftermath/EXTRAS' { $Session.Screen = 'Extras' }
        'Chapters/CHAPTER 1 - A VILA' { $Session.Screen = 'Intro' }
        'Intro/FINISH INTRO' { $Session.Screen = 'Chapter' }
        'Intro/SKIP INTRO' { $Session.Screen = 'Chapter' }
        'Chapter/SAVE DEMO CHECKPOINT' {
            $Session.CanContinue = $true
            $Session.Screen = 'Aftermath'
        }
        'Original/BACK' { $Session.Screen = 'Title' }
        default {
            if ($Action -eq 'BACK') {
                $Session.Screen = 'Aftermath'
            } elseif ($Session.Screen -eq 'Title') {
                $Session.Screen = 'Original'
            }
        }
    }
}
