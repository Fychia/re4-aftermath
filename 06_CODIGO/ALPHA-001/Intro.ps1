function Get-AftermathScenes {
    @(
        @{ Title = 'O confronto anterior'; Text = 'No castelo de Salazar, Leon deixa seu adversário caído.' }
        @{ Title = 'Brute sobrevive'; Text = 'Ganados retiram Brute dos escombros e o levam para a ilha.' }
        @{ Title = 'O laboratório'; Text = 'Ferido, Brute encontra o cientista transferido do castelo para a instalação de pesquisa.' }
        @{ Title = 'A variante experimental'; Text = 'Brute sabe que ainda não pode enfrentar Leon. Ele aposta sua vida na variante.' }
        @{ Title = 'A transformação'; Text = 'O tratamento o mantém vivo. O que desperta nele vai além do que o cientista previu.' }
        @{ Title = 'Meses depois'; Text = 'Nas montanhas, uma vila fortificada abriga os novos experimentos de Brute.' }
        @{ Title = 'A missão de Leon'; Text = 'Os rumores chegam a Washington. Hunnigan encaminha Leon para investigar a região.' }
        @{ Title = 'RESIDENT EVIL 4: AFTERMATH'; Text = '' }
        @{ Title = 'Capítulo 1 — A Vila'; Text = 'O Mirante. Siga a estrada pela floresta e procure um ponto alto.' }
    )
}

function Get-AftermathIntroResult {
    param([int]$SceneIndex, [int]$SceneCount, [switch]$Skip)
    if ($Skip -or $SceneIndex -ge ($SceneCount - 1)) { return 'Launch' }
    return 'Next'
}
