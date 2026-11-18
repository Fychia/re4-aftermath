# MENU-001 — Menu da campanha Aftermath

**Viabilidade.** A extensão direta do título continua em pesquisa. As fontes consultadas identificam rotinas reais do título, transições e reprodução de filmes. Elas deixam em aberto o registro de uma nova ação selecionável e o início de uma campanha com persistência própria na build Steam UHD 1.1.0 do projeto. A entrega desta etapa é um protótipo Windows independente.

## O que as ferramentas demonstram

| Fonte primária | Evidência e limite |
|---|---|
| [RE4 Tweaks, Game.cpp](https://github.com/nipkownix/re4_tweaks/blob/master/dllmain/Game.cpp) | Detecta versões pelo texto do título. A lógica de Area Jump passa de `TITLE_WORK` para `Exit` e do estado global para `Doordemo`, encerrando um filme Sofdec ativo. O código também referencia `titleExtraSelect` na detecção de variantes regionais. Isso demonstra uma saída do título para depuração. A construção da lista, os limites do cursor e o dispatcher de uma nova opção continuam sem mapeamento. |
| [RE4 Tweaks, Sofdec.cpp](https://github.com/nipkownix/re4_tweaks/blob/master/dllmain/Sofdec.cpp) | Documenta intervenções em `titleMain` para demos e chamadas de inicialização do Sofdec. É evidência de vídeo no ciclo do título. O início de um filme próprio no fluxo da campanha requer prova separada. |
| [RE4 Tweaks, modding](https://github.com/nipkownix/re4_tweaks/wiki/Modding-Enhancements) | `-room`, `-pos` e `-gamedir` servem de candidatos para testes controlados. O redirecionamento cobre BIO4. A localização efetiva de saves e Steam Cloud precisa ser verificada à parte. |
| [RE4 QuadX](https://github.com/r3nzk/Re4QuadX/blob/main/README.md) | Editor UHD para salas, objetos e inimigos. Usar para autoria do ambiente de chegada do Capítulo 1. As capacidades publicadas não estabelecem uma API de opções do título. |
| [emoose/re4-research](https://github.com/emoose/re4-research/releases) | re4lfs permite extração e repack para inventário de recursos do título. re4sym usa símbolos do debug de GameCube como referência analítica, com correspondência a confirmar no binário UHD. re4resample trabalha com bancos XWB. |
| [boshjerns SDK](https://github.com/boshjerns/re4-boshjerns-sdk) | Demonstra páginas nativas em Options durante o jogo, com cursor, sons e controles. O loader mira uma build específica e a coexistência com Tweaks segue pendente no projeto. As páginas publicadas são precedente de UI, com o ciclo do título ainda a provar. |

O diagnóstico local registrou `BIO4/Title/*_press_Start.fix.lfs`. Esses arquivos dão um ponto de partida para estudar apresentação e localização. Para distinguir dados de interface de lógica do menu, é preciso correlacionar os recursos com o tamanho da lista, ações, estados e retorno sob teclado e controle. Nenhum INI consultado oferece cadastro documentado de uma campanha.

## Protótipo

Abra em PowerShell 5.1 no Windows, a partir da raiz do workspace.

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -STA -File .\06_CODIGO\MENU-001\Start-Menu.ps1
```

Use mouse, Tab e Espaço/Enter. BACK retorna ao nível anterior. ESC aciona BACK nas telas que o oferecem. O título apresenta as seis opções solicitadas. NEW GAME, LOAD GAME, OPTIONS e EXTRAS do título passam por uma tela informativa com volta. EXIT fecha a janela.

Em AFTERMATH, NEW CAMPAIGN abre o storyboard textual de introdução. Concluir ou pular leva à chegada simulada ao mirante de A Vila. SAVE DEMO CHECKPOINT retorna ao submenu e habilita CONTINUE na sessão. CHAPTER SELECT abre o Capítulo 1 com introdução. Uma nova campanha com checkpoint existente pede confirmação de reinício. EXTRAS apresenta a referência ao storyboard. BACK regressa ao título. O estado do protótipo vive apenas em memória. A janela tem identidade visual própria e usa somente controles e fontes do Windows.

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\06_CODIGO\MENU-001\Test-Menu.ps1
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -STA -File .\06_CODIGO\MENU-001\Start-Menu.ps1 -SmokeTest
```

O primeiro comando testa a máquina de fluxo. O segundo aciona botões reais de WinForms e verifica o retorno ao título. Pode abrir brevemente uma janela e exige sessão gráfica.

## Arquitetura de integração proposta

- **Apresentação e roteamento.** Manter ações estáveis para iniciar, continuar, selecionar capítulo, abrir extras e voltar. No UHD, mapear título, submenus, cursor e dispatch, entrada de controle, localização, fades e demo ociosa. BACK restaura título e foco anterior. A integração deve preservar o despacho de cada opção original.
- **Início de campanha.** Criar um descritor de capítulo com ID próprio, sala e spawn aferidos, personagem, inventário, dificuldade, flags iniciais e checkpoint. O mirante tem `r100` e `r104` como candidatos. `r101` é o mapa comprovado para protótipo de sala da vila. Usar depuração de sala para verificar as coordenadas. Validar inicialização de partida como etapa própria.
- **Cutscenes.** Modelar o storyboard de abertura como etapa anterior à chegada. No jogo, pesquisar reprodução SFD autorizada ou evento de cena de referência. Normalizar término, pulo e falha de recurso para uma única transição. Testar cancelamento de demo ociosa, retorno e retomada sem repetir a introdução de um checkpoint posterior.
- **Persistência.** Separar dados Aftermath por perfil e versão. Mapear leitura, escrita e Cloud antes de implementar CONTINUE real. Em ensaio autorizado, usar apenas perfis e saves descartáveis. Conferir hashes dos saves originais antes e depois. Capítulo selecionado é um ponto de entrada com estado definido. CONTINUE usa checkpoint compatível.

## Próxima prova em UHD

1. Registrar hash da build alvo e correlacionar estaticamente os estados do título com os recursos de apresentação, a navegação e o despacho de ações. Identificar a capacidade de acrescentar uma opção por dados e documentar o que exige adaptação em runtime.
2. Em sessão autorizada e isolada, validar carregamento de uma sala conhecida, posição do jogador, estado inicial e destino de saves. Exercitar título, original, título e Aftermath em ambas as ordens.
3. Depois de demonstrar segregação, ligar ação de teste ao início do Capítulo 1 e validar checkpoint, morte, reload e volta ao título. Incluir teclado/controle, idiomas e estados de desbloqueio.
4. Validar conclusão e pulo da introdução com a mesma chegada. Se a entrada dedicada exigir código em runtime, avaliar compatibilidade com Tweaks, versões conhecidas e retirada reversível antes de implementar.

A prova desta etapa termina na janela independente. Ela usa storyboard textual e simula chegada e checkpoint. Steam, processos, executáveis, DLLs e saves do jogo ficam fora do fluxo do protótipo.
