# Alpha 0.1 — Candidate02

Candidata parcial em `08_RELEASES/Aftermath_Alpha_0.1/Candidate02`. O pacote usa a cópia BIO4 verificada da MAP-001 v001 e um Bin32 próprio. O gatilho de lançamento aponta para o executável local e passa `-gamedir` e `-room r100`. O build grava hashes, caminhos e mudanças de configuração em `manifest.json`.

## Testes

| Verificação | Resultado |
|---|---|
| PowerShell 5.1 e montagem do pacote | Passou |
| Manifestos do BIO4 reutilizado | 947 arquivos de editor e 17 arquivos de referência conferidos por SHA-256 |
| Nove cartões e lógica de encerramento | Passou |
| Janela WinForms com conclusão, pulo e cancelamento | Passou. O teste intercepta a decisão de lançar e termina antes de abrir o RE4. |
| Entrada AFTERMATH no título ou menu interno | Pendente. Nenhum caminho de integração foi implementado nesta candidata. |
| Cutscene dentro do motor | Pendente. A alternativa é uma sequência textual temporizada externa que antecede a invocação do jogo real. |
| Mudança visual em jogo | Preparado perfil de clima noturno via boshjerns SDK, sem comprovação de compatibilidade e de efeito na build local. A geometria ainda é a de r100. |
| Spawn, caminhada, colisão, mirante, saída | Pendentes em jogo. |
| Preservação da Steam e dos saves durante a montagem | O build leu os insumos locais e gravou somente em `08_RELEASES`. Durante os testes da candidata, nenhum processo RE4 foi iniciado. |

## Integração e restauração

Abra `Candidate02/Jogar-Aftermath.cmd` para iniciar a sequência externa e a tentativa de carregamento real de r100 em uma sessão de teste. O isolamento de BIO4 e Bin32 não comprova segregação do perfil Steam. Uma sessão com saves descartáveis e Cloud segregada é necessária antes da validação interativa. Para voltar ao estado habitual, feche a candidata e abra a instalação principal pela biblioteca. O pacote não substitui arquivos da Steam.

O RE4 Tweaks fornece salto de sala como mecanismo de depuração. O SDK documenta um menu de opções em jogo e ajustes de clima. A ligação do título ao estado inicial de uma campanha e a reprodução da introdução interna ainda exigem caminho comprovado e teste com perfil isolado. O objetivo de aceitação segue aberto. [RE4 Tweaks](https://github.com/nipkownix/re4_tweaks/wiki/Modding-Enhancements#command-line-parameters) · [boshjerns SDK](https://github.com/boshjerns/re4-boshjerns-sdk/blob/main/FEATURES.md)
