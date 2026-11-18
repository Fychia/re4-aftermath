# Proposta de arquitetura

A campanha começa como um conjunto de alterações de dados sobre salas UHD conhecidas. O Capítulo 1 usa identificadores narrativos próprios no planejamento e associa cada área a uma sala do jogo somente depois de provar essa associação. Uma futura interface de seleção consome a configuração de início da campanha e fica fora do pipeline de autoria de salas.

| Camada | Responsabilidade |
|---|---|
| Fontes locais | Steam em leitura, backups imutáveis e extrações de referência. Registrar jogo alvo, ferramentas, origem, tamanho e SHA-256. |
| Autoria | QuadX em `QUADX_GAME_ROOT`; arquivos temporários separados para export. Blender e editor de imagem entram conforme necessidade. Preservar o layout funcional de r101. |
| Definições versionadas | Scripts PS 5.1, manifestos textuais e configurações próprias. Um manifesto por mudança com sala, caminho relativo, hash base, registros/campos editados e critérios de aceite. |
| Build local | Aplicar receitas a cópias em diretório novo por build, reconstruir contêineres conforme formato e gerar manifesto com hashes de entrada e saída, versões e evidências de round-trip. |
| Execução | Testar perfil BIO4 em cópia local com o `-gamedir` do Tweaks como candidato. A wiki documenta o redirecionamento e a partilha de Bin32. Verificar saves, logs e configurações de forma independente antes da integração. [Wiki de modding](https://github.com/nipkownix/re4_tweaks/wiki/Modding-Enhancements#command-line-parameters) |
| Distribuição | Scripts e receitas aplicáveis pelo usuário à sua cópia compatível. Rever qualquer delta antes de distribuí-lo para que o pacote contenha somente material redistribuível. |

## Contrato de build e teste

1. Resolver caminhos literais e confirmar confinamento do diretório de escrita. Fixar ferramentas por versão e hash. Conferir formato, comprimento, limites e hash dos insumos antes de abrir saídas para escrita.
2. Começar pelo ESL. Verificar índice, tipo e valores esperados do registro. Gerar variante sobre cópia base, comparar bytes com uma lista de alterações permitidas e conferir também que os valores alvo foram gravados. Reextrair o LFS em pasta nova, checar código de saída e comparar SHA-256 com o ESL de entrada.
3. Para UDAS, testar primeiro extração → repack → reextração sem alterações. Comparar entradas, ordem, metadados de índice e hashes por conteúdo. Só aprovar o artefato após teste de carregamento autorizado. Repetir o ciclo para PACK se houver edição de texturas.
4. Tratar artefato e manifesto como unidade. Publicar em pasta nova após validação, rejeitar condição de concorrência sobre a mesma saída e preservar build anterior. Caso o perfil alternativo falhe e um teste na Steam seja autorizado, exigir jogo fechado, hashes de base, backup imutável, registro de substituições e restauração verificável.
5. Validar em jogo com sessão controlada. Registrar entrada inicial, ida e volta, morte/retry, saída ao título, save/reload e integridade do perfil original quando aplicável.

## Controle de versão

Usar o Git encontrado no Visual Studio ou uma instalação acessível via PATH. Ao habilitar o repositório, preparar `.gitignore` com lista de permissões para fontes próprias e conferir os caminhos preparados em staging. Excluir extrações, backups, logs, ZIP de conteúdo não revisado, builds locais e `QUADX_GAME_ROOT`. Guardar binários do jogo no armazenamento local. A arquitetura é proposta, sem migração de pastas.
