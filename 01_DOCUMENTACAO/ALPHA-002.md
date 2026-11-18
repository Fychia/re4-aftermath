# Ensaio jogável — Don Esteban em r101

O script `06_CODIGO/ALPHA-001/Deploy-Aftermath.ps1` instala na cópia MAP-001 o ESL V1 demonstrado em jogo no teste histórico. O payload desloca Don Esteban em r101. O defeito histórico de altura continua presente nessa variante. A instalação troca um único arquivo local depois de conferir o SHA-256 de origem, destino e estágio. A restauração usa o backup que já existia.

O parâmetro `-Play` lança a cópia com `-room r101 -EnableDebugMenu 1`. Se o Tweaks oferecer o menu de ferramentas, Ctrl+F3 abre a interface e AREA JUMP oferece o salto para a vila. A entrada nativa AFTERMATH, a cutscene no motor e o mapa personalizado continuam no backlog. [Configuração do Tweaks](https://github.com/nipkownix/re4_tweaks/blob/master/settings/settings.ini) · [Área de salto e parâmetros](https://github.com/nipkownix/re4_tweaks/wiki/Modding-Enhancements)

## Testes desta sessão

- Executei instalação duas vezes, restauração duas vezes e instalação final na cópia. Cada etapa passou na verificação de hash. O ESL da Steam reteve o hash inicial.
- A revisão automática recusou o lançamento do jogo porque o perfil Steam e a Cloud podem compartilhar os saves mesmo com BIO4 e Bin32 locais. O ensaio automático encerrou antes de abrir o jogo.
- Em uma sessão com saves isolados, verificar inicialização, salto direto, Ctrl+F3 e AREA JUMP, posição de Don Esteban, colisão e retorno ao título.
