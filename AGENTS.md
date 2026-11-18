# AGENTS.md — Resident Evil 4: Aftermath

> **Documento de contexto operacional para Codex**  
> Atualizado em 18/11/2026 (America/Sao_Paulo).  
> Base: histórico de desenvolvimento e resultados compartilhados pelo responsável pelo projeto.  
> **Leia integralmente este documento antes de propor ou executar alterações.**

## 0. Instruções principais para o agente

Você é o assistente de desenvolvimento do **Resident Evil 4: Aftermath**, uma campanha alternativa/continuação não oficial de **Resident Evil 4 clássico, versão UHD (Steam, 2014)**. O objetivo é progredir de alterações pequenas e testáveis para uma campanha com ambientes, eventos, inimigos, textos e missões personalizados, reutilizando recursos do jogo original e criando recursos novos quando viável.

**Regras de atuação:**

1. Responda em **português brasileiro**, com orientações práticas, passos reproduzíveis, caminhos concretos e scripts PowerShell 5.1 quando apropriado.
2. **Não alegue acesso ao disco `F:`** a menos que a sessão do Codex esteja rodando na máquina do projeto e você tenha verificado os caminhos. Os caminhos abaixo foram informados em conversa e podem ter mudado.
3. **Priorize preservar a instalação original** em `F:\Steam\...`. Faça toda preparação e análise em `F:\RE4_MOD_PROJECT`; antes de qualquer substituição na Steam, confirme explicitamente escopo e procedimento de restauração. Nunca sobrescreva backups imutáveis.
4. Antes de gerar scripts que manipulem arquivos binários, **verifique existência, tamanho, hash, formato, offsets e limites**. Use `-LiteralPath`, `$ErrorActionPreference = 'Stop'`, checagem de `$LASTEXITCODE`, falha antes da escrita e verificação de integridade após a escrita.
5. **Não confunda “funciona no QuadX” com “funciona no jogo”.** Exija validação de jogo e documente o resultado observado.
6. Diferencie sempre **confirmado pelo usuário**, **hipótese técnica** e **funcionalidade ainda não comprovada**. Consulte documentação/código-fonte das ferramentas quando uma etapa depender de comportamento específico.
7. Não invente caminhos, nomes de executáveis, CLI, parâmetros, offsets, compatibilidades de formatos ou ações de menus. Procure o arquivo real e a documentação local/externa; se necessário, ofereça script de diagnóstico somente leitura.
8. Mantenha progresso incremental, logs, rollback, critérios de aceite e controle de versões; usar Git para scripts, documentação, configurações textuais, e Git LFS ou armazenamento externo para binários grandes/licenciados (não subir arquivos proprietários originais do jogo para repositório público).
9. O projeto se chama **RE4 Aftermath**; existe também uma pasta antiga `F:\RE4_Aftermath`, mas a pasta principal ativa é `F:\RE4_MOD_PROJECT`.
10. Priorize tarefas de **modding offline/single-player**, sem distribuir arquivos proprietários do jogo ou conteúdo original da Capcom. Para releases, prefira instruções de patch/delta e dependência de cópia legal do jogo, observando permissões/licenças aplicáveis.

---

## 1. Visão do produto e narrativa

**Título provisório:** Resident Evil 4: Aftermath  
**Tipo:** continuação alternativa do Resident Evil 4 original, com Leon S. Kennedy, Hunnigan, Brute e novos personagens/inimigos.  
**Ambição:** campanha própria, incluindo **mapas novos combinados com estruturas/recursos existentes**, variantes visuais de inimigos (inclusive combinação/edição de modelos 3D), novos textos, mensagens, eventos e progressão.  
**Estratégia narrativa inicial:** diálogos escritos, documentos, imagens ilustrativas/cenas estáticas e triggers simples; cutscenes cinematográficas complexas ficam para fases posteriores, após avaliar limitações da engine.

### Antagonista e premissa

- **Brute**, chamado informalmente de **“Vermelinho Cabeça de Bode”**, é o inimigo de manto vermelho e cabeça/máscara de bode que Leon enfrentou no castelo de Ramón Salazar, na sequência do combate com a arma/minigun (descrição narrativa fornecida pelo autor; não presumir exatidão de nomenclatura canônica).
- **Na história do mod**, Brute **sobreviveu** ao combate contra Leon no castelo. Esta sobrevivência é o gatilho da continuação.
- Antes da destruição da ilha e do confronto final Leon vs. Osmund Saddler, Brute chega, ferido e apoiado por Ganados subordinados, a uma instalação/laboratório. Aplica em si mesmo **uma variante experimental de Las Plagas** para sobreviver e ganhar forças.
- **Ajuste já decidido:** o cientista que desenvolveu a variante **havia sido transferido de uma instalação do castelo para uma instalação da ilha antes do confronto final**. Brute o encontra/obriga a acompanhá-lo; isso evita a inconsistência de procurar um cientista ainda no castelo em momento inadequado.
- A variante o torna mais resistente e revela novas habilidades, mas ele entende que ainda não está pronto para enfrentar Leon.
- Brute foge com um pequeno grupo, amostras das variantes e o cientista, estabelecendo-se em região remota. Meses depois, experimentos criam **novas classes de Ganados**, nem todos compatíveis com as variantes; Brute também evolui durante a campanha.
- A vila ocupada é transformada em **fortaleza**, com instalações de pesquisa, treinamento, vigilância e defesas.
- Rumores chegam ao governo dos EUA. Leon é enviado para investigar à noite/madrugada; Hunnigan presta suporte remoto.
- **Confronto com Brute ocorre na própria fortaleza construída por ele**, ao final do arco (decisão do autor). Evolução gradual do antagonista é um elemento importante.

### Início jogável desejado

1. Leon chega de madrugada perto de uma vila na montanha; observa, com binóculos, que há muitos Ganados.
2. Hunnigan indica acesso discreto e rota para investigar sem ser detectado.
3. Leon entra e encontra documentos em um posto avançado/torre que revelam variante inédita de Las Plagas.
4. Um Ganado percebe Leon; inicia-se confronto/cerco.
5. **Duas condições alternativas propostas para resolver o cerco:** (a) derrotar aproximadamente **42 inimigos** e o sino toca; **ou** (b) o jogador aciona manualmente o sino, atraindo os Ganados à igreja. **Ainda não implementadas**, precisam de estudo de eventos, IA, limites de spawn e triggers.
6. Depois, Leon avança, acha novos documentos, descobre que Brute está na fortaleza e obtém instruções de Hunnigan para avançar.

### Proposta de estrutura narrativa (não aprovada como escopo técnico final)

- **Prólogo — O Sobrevivente:** luta no castelo (flashback), fuga de Brute, ilha, experimento e captura/recrutamento forçado do cientista.
- **Capítulo 1 — A Vila Fortificada:** aproximação noturna, reconhecimento, torre, documentos, alarme e evento do sino (2 caminhos).
- **Capítulo 2 — Rastros da Infecção:** casas, passagens subterrâneas/ruínas, coleta de amostras, documentos e variantes iniciais.
- **Capítulo 3 — A Linha de Defesa:** muralhas, minas, mata, guardas, pontos de treinamento e emboscadas.
- **Capítulo 4 — O Laboratório Esquecido:** instalações reaproveitadas, encontro com informações do cientista, testes de variantes e revelação de plano.
- **Capítulo 5 — Coração da Fortaleza:** infiltração, vários níveis de segurança, nova evolução de Brute, confronto final na fortaleza.
- **Epílogo:** consequências, destino do cientista, amostras de Las Plagas, gancho para futura expansão.

Esses capítulos são proposta de design, não funcionalidades já criadas no jogo. Refinar com o autor, documentar quests e mapear rooms/recursos antes de programar.

---

## 2. Ambiente e ferramentas já utilizadas

**Sistema:** Windows, PowerShell **5.1**.  
**Jogo:** Resident Evil 4 UHD (Steam; **não é RE4 Remake 2023**, nem a versão PS2).  
**Instalação original da Steam:**

```text
F:\Steam\steamapps\common\Resident Evil 4
├── Bin32\bio4.exe
└── BIO4\
    ├── St1\r101.udas.lfs
    ├── Etc\emleon00.esl.lfs
    ├── ImagePack\44000101.pack.lfs
    └── ImagePackHD\44000101.pack.lfs
```

**Projeto de trabalho:** `F:\RE4_MOD_PROJECT`  
**Ambiente experimental para leitura QuadX:** `F:\RE4_MOD_PROJECT\QUADX_GAME_ROOT`  
**Sala base:** `r101` / **Village Center [VILLAGE]** (no QuadX pode aparecer `r101S`).  
**Outras rooms observadas nas listas:** r100S (Village Beginning / Woods), r102S (Underground), r103S (Farm), r104S (Mountain Passage / Quarry), r105S, r106S, r107S, r108S (Graveyard/Church), r109S, r10AS etc. Os nomes e a compatibilidade das rooms dependem da versão/lista usada.

### Ferramentas instaladas / caminhos relatados

| Ferramenta | Versão/estado | Caminho relatado |
|---|---|---|
| RE4QuadX | v1.0.1, funcionando | Caminho do executável não informado; interface aberta |
| RE4 Tweaks | v1.9.1.0, funcionando, menu F1 | Arquivos `dinput8.dll`, config e `re4_tweaks` em `F:\Steam\steamapps\common\Resident Evil 4\Bin32` |
| JADERLINK DAT/UDAS Tool | v1.0.4 | `F:\Tools\JADERLINK_DATUDAS_TOOL.V.1.0.4\JADERLINK_DATUDAS_TOOL.exe` |
| re4lfs (emoose) | utilitário 1.2 / build 1.2a | `F:\Tools\re4-research_build-1.2a\re4lfs.exe` |
| JADERLINK RE4 UHD PACK Tool | v1.0.8 | `F:\Tools\RE4_UHD_PACK_TOOL.V.1.0.8\RE4_UHD_PACK_TOOL.exe` |
| JADERLINK GCA Tool | pasta existe; **não necessária para UHD** | `F:\Tools\RE4_2007_GCA_TOOL-V.1.1` |
| Blender | instalado | caminho não informado |
| GIMP | instalado | caminho não informado |
| Visual Studio | instalado | caminho não informado |
| VS Code | instalado | caminho não informado |
| Git | sabe utilizar | instalação não detalhada |

RE4 Tweaks aplicou com sucesso o patch **4GB / Large Address Aware**, criando backup do executável. Jogo e menu F1 foram testados.

**Configuração QuadX (Settings → Tools Paths):** DAT/UDAS, LFS e PACK apontam para os executáveis acima; GCA em branco. **Settings → General**: Preferred Version = `UHD (Steam)`. **Settings → Game Paths**: o usuário configurou `RE4 UHD (Steam) Path = F:\RE4_MOD_PROJECT\QUADX_GAME_ROOT`. **xFile Path** permaneceu vazio, gerando avisos de modelos PMD de inimigos ausentes (não impede a renderização da geometria/texturas da vila). O xFile preferido pelo QuadX usa recursos leves da versão RE4 PC 2007; opcional, sem improvisar arquivos.

### Diretórios do projeto vistos em capturas

```text
F:\RE4_MOD_PROJECT\
├── 01_DOCUMENTACAO\
├── 02_MAPAS\
│   └── r101\
│       ├── originais\
│       ├── extracao_separada\
│       │   ├── r101.udas.lfs
│       │   ├── r101.udas
│       │   ├── r101.idxj
│       │   └── r101\r101_004.SMD (+ outros)
│       ├── r101\
│       │   ├── r101_000.CAM
│       │   ├── r101_001.SAT
│       │   ├── r101_002.LIT
│       │   ├── r101_004.SMD
│       │   ├── r101_005.SMX
│       │   ├── r101_011.ETS
│       │   ├── r101_015.AEV
│       │   ├── r101_030.ITA
│       │   └── ... (vários tipos)
│       ├── INIMIGOS\
│       │   ├── emleon00.esl
│       │   ├── emleon00.backup.esl
│       │   └── emleon00.esl.lfs (presença anterior relatada)
│       └── DAT\ (pasta preparada; não se acharam r101_*.dat.lfs em St1)
├── 03_MODELOS\
├── 04_TEXTURAS\
│   └── r101\
│       ├── ImagePack\44000101.pack.lfs
│       └── ImagePackHD\
│           ├── 44000101.pack.lfs
│           ├── 44000101.pack
│           ├── 44000101.pack.idxpack
│           └── 44000101\ (140 DDS + 155 TGA)
├── 05_AUDIO\
├── 06_CODIGO\
│   └── Preparar-RE4QuadX.ps1
├── 07_TESTES\
│   ├── ESL\emleon00.esl          # versão isolada: registro 0x16 somente
│   ├── BUILD\emleon00.esl       # cópia para compactar
│   ├── BUILD\emleon00.esl.lfs   # build V1, 3314 bytes
│   ├── VALIDACAO\emleon00.esl   # round-trip, 8160 bytes
│   ├── BACKUP_STEAM\emleon00.esl.lfs # backup do arquivo Steam pré-instalação
│   └── logs\...
├── 08_RELEASES\
└── QUADX_GAME_ROOT\
    └── BIO4\
        ├── St1\r101\0000.SMD
        ├── St1\r101\0000.SMX
        └── ImagePackHD\
            ├── 44000101.pack
            ├── 44000101.pack.idxpack
            └── 44000101\ (140 DDS + 155 TGA)
```

**Cuidado:** outros caminhos/pastas existiram em versões iniciais (`F:\RE4_Aftermath`, `F:\RE4_MOD_PROJECT\Bin32`, `BIO4`). Não tratá-los como cópias sincronizadas do jogo.

---

## 3. Descobertas técnicas confirmadas

### 3.1 Extração da sala r101

- Na Steam, `BIO4\St1` contém `r101.udas.lfs`, **não** os arquivos `r101_*.dat.lfs` procurados em tentativa anterior; a busca retornou zero arquivos.
- `re4lfs.exe <arquivo.udas.lfs>` descompactou com sucesso e gerou `r101.udas` (aprox. 9.814 KiB; tamanho exibido 9.814 KB no Explorer).
- JADERLINK DAT/UDAS Tool extraiu esse contêiner e criou índice `r101.idxj`, pasta `r101\` com registros como `r101_004.SMD` (6.896.704 bytes), `r101_005.SMX` (8.224 bytes), `.ETS`, `.ITA`, `.AEV`, `.CAM`, `.LIT`, `.EFF` e muitos outros.
- O QuadX esperava, em leitura de room descompactada: `BIO4\St1\r101\0000.SMD` e `0000.SMX`. Foi criada **cópia experimental** dos arquivos SMD/SMX extraídos com esses nomes no diretório `QUADX_GAME_ROOT`, com verificação SHA-256 igual à origem. **Isso funcionou para visualização nesse caso, mas não presumir que renomeação é universalmente correta para outras rooms/formatos.**

### 3.2 Texturas e renderização

- Arquivo identificado para `r101`: `44000101.pack.lfs`, existente em `BIO4\ImagePack` (1.591.362 bytes) e `BIO4\ImagePackHD` (11.218.026 bytes).
- `re4lfs` gerou `44000101.pack` em ImagePackHD (27.737.324 bytes). JADERLINK UHD PACK Tool v1.0.8 extraiu **295 texturas: 140 `.dds` e 155 `.tga`** e gerou `44000101.pack.idxpack` (100 bytes).
- Inicialmente QuadX mostrava cena branca/cinza; wireframe mostrava geometria, sinal de que a renderização de materiais era o problema.
- O usuário preparou em `QUADX_GAME_ROOT\BIO4\ImagePackHD` a pasta `44000101` com imagens extraídas **e** copiou o `44000101.pack` e `44000101.pack.idxpack` do diretório de trabalho para a raiz `ImagePackHD`.
- **Após essa configuração, screenshot confirmou a vila renderizada com as texturas HD** no QuadX. A associação exata interna entre PACK/index/texturas não foi provada por inspeção de código; preservar essa configuração funcional.
- Warning `Path for 'xFile' null or invalid` e `Failed to find 3D model ... .pmd` permanecem; dizem respeito à pré-visualização de modelos de inimigos/objetos e **não bloquearam** a renderização da vila.

### 3.3 Importação ESL no QuadX

- UI `File → Import → Enemy ESL File (Little Endian)` importou com sucesso `emleon00.esl` na versão UHD.
- A lista possui registros de diferentes salas (`R100`, `R101`, `R104`, `R108` etc.). **Não editar registro de outra sala por engano**; olhar Room ID.
- `Enemies (ESL)` é representado visualmente por caixas/volumes vermelhos no editor, independentemente de xFile.
- UI `File → Export → Enemy ESL File` exporta para o **mesmo arquivo/caminho de origem** neste caso, sem pedir destino, e o console mostrou `File exported successfully: emleon00.esl` às **23:17:10 e 23:17:50 em 17/11/2026**.
- **Importante:** a versão exportada pelo QuadX tinha 8.192 bytes (256 registros de 32 bytes), enquanto o backup de trabalho tinha **8.160 bytes (255 registros)**. Os 32 bytes finais adicionais eram todos `00`. Não usar essa versão de 8.192 bytes diretamente como build final sem justificar.
- Comparação binária mostrou 14 offsets diferentes dentro dos 8.160 bytes, em **três registros**: `0x15`, `0x16`, `0xFB`. Para isolar o experimento, foi reconstruído um arquivo novo usando o backup original como base, copiando **apenas os 32 bytes do registro `0x16`** exportado. Resultado: 8.160 bytes, **somente 5 bytes alterados**, zero alterações fora do registro.

### 3.4 Primeiro Ganado alterado — tarefa comprovada

**Sala:** `R101` / Village Center  
**Registro ESL:** índice `0x16` (decimal 22)  
**Tipo de inimigo conforme QuadX:** `0x1503`, **Don Esteban (GANADO)**  
**Ativo:** `Is Enable = True`  
**Vida exibida:** `800`  
**Rotação Y:** `-6628` (valor bruto do editor, não converter automaticamente em graus)

| Campo | Antes | Depois V1 |
|---|---:|---:|
| Position X | -610 | **-1959** |
| Position Y | 0 | **66** |
| Position Z | -84 | **790** |
| Rotation Y | -6628 | -6628 |
| HP | 800 | 800 |

**Formato observado:** registros ESL de 32 bytes (little-endian); o registro `0x16` começa em `0x16*32 = 0x02C0`. Campos das coordenadas `Int16` em `registro + 12` (X), `+14` (Y), `+16` (Z) foram confirmados pelo script de validação e reimportação no QuadX. **Não extrapolar esses offsets para outros tipos de arquivo.**

Arquivos:

```text
F:\RE4_MOD_PROJECT\02_MAPAS\r101\INIMIGOS\emleon00.backup.esl   # 8160 B, antes da edição no QuadX
F:\RE4_MOD_PROJECT\02_MAPAS\r101\INIMIGOS\emleon00.esl          # 8192 B, export geral do QuadX
F:\RE4_MOD_PROJECT\07_TESTES\ESL\emleon00.esl                   # 8160 B, apenas registro 0x16 alterado
F:\RE4_MOD_PROJECT\07_TESTES\BUILD\emleon00.esl.lfs             # 3314 B, build V1 testada
```

### 3.5 Compactação LFS e round-trip

- `re4lfs.exe <arquivo.esl>` compactou 8.160 B em `emleon00.esl.lfs` com **3.314 bytes**, 1 chunk.
- `re4lfs.exe <arquivo.esl.lfs> <caminho_de_saida.esl>` descompactou para 8.160 B. **SHA-256 do ESL de origem e do ESL pós-descompactação foram idênticos.**
- **O tamanho comprimido não precisa ser igual ao original**: na Steam, o arquivo pré-instalação tinha **3.310 bytes**; build V1 **3.314 bytes**. A validação correta do conteúdo foi feita por round-trip, não por tamanho comprimido.

### 3.6 Instalação e teste in-game — principal marco do projeto

- Arquivo do jogo utilizado: `F:\Steam\steamapps\common\Resident Evil 4\BIO4\Etc\emleon00.esl.lfs`.
- Antes da instalação do mod, criado backup em `F:\RE4_MOD_PROJECT\07_TESTES\BACKUP_STEAM\emleon00.esl.lfs`, e hash conferido com arquivo então instalado.
- Build V1 compactada instalada temporariamente sobre o arquivo `BIO4\Etc\emleon00.esl.lfs`; hash da instalação e do build comparados como idênticos.
- **Teste no jogo em 17/11/2026:** screenshot mostrou Leon no cenário da vila e o usuário confirmou que o Ganado Don Esteban **apareceu na posição alterada**, **sem crash**. **Problema observado: o Ganado apareceu um pouco acima do chão**, indicando ajuste necessário do Y e/ou terreno/navmesh.
- **Situação atual da Steam:** a última operação relatada foi a instalação da build V1; **não há confirmação de restauração posterior.** Assumir que o jogo **pode permanecer modificado**. Antes de qualquer nova instalação, comparar hashes do arquivo da Steam com a build atual e o backup, não assumir que o backup corresponde ao arquivo atualmente instalado.
- Ainda **não foi validado completamente** comportamento de combate, pathfinding, AI, eventos do sino ou experiência inteira.

---

## 4. Estado atual / próxima tarefa concreta

**Marco atingido:** primeira prova de conceito jogável (edição de um registro ESL, isolamento binário, compactação/round-trip e carregamento in-game).

**Próxima tarefa: `RE4-014 — Corrigir altura do Don Esteban`**.

A build V1 usa posição `(-1959, 66, 790)`. O inimigo surge levemente acima do solo na posição escolhida. Proposta anterior foi testar `Y = 0` preservando X/Z, **mas esse valor é hipótese**, não foi medido no terreno. Melhor estratégia:

1. Inspecionar o ponto `(-1959, ?, 790)` no QuadX, se possível com ferramentas de câmera/altura; verificar piso real naquele X/Z e se há colisão/superfícies sobrepostas.
2. Criar **V2 separada**, sem sobrescrever V1 nem backups, alterando **somente o `Int16` de Y no registro `0x16`**, confirmar os bytes alterados.
3. Compactar V2, descompactar para uma pasta de validação e comparar SHA-256 com o ESL V2.
4. Confirmar arquivo instalado e backup imutável. Só então instalar em modo reversível com registro do hash pré-instalação e rollback.
5. Testar no jogo: altura ao spawn, estabilidade, movimento, detecção e ataque. Se `Y=0` enterrar o inimigo, rever estimativa. Registre screenshots, coordenadas e resultado em tabela de experimentos.

Exemplo de atualização **somente do bytefield Y**, sem disparar escrita no arquivo fonte (é exemplo a revisar/rodar no ambiente local; não executar automaticamente):

```powershell
$ErrorActionPreference = 'Stop'
$source = 'F:\RE4_MOD_PROJECT\07_TESTES\ESL\emleon00.esl'
$targetDir = 'F:\RE4_MOD_PROJECT\07_TESTES\V2'
$target = Join-Path $targetDir 'emleon00.esl'
if (!(Test-Path -LiteralPath $source -PathType Leaf)) { throw 'Fonte ausente' }
if (Test-Path -LiteralPath $target) { throw 'Destino ja existe' }
$data = [System.IO.File]::ReadAllBytes($source)
if ($data.Length -ne 8160) { throw 'Tamanho inesperado' }
$recordOffset = 0x16 * 32
$yOffset = $recordOffset + 14
$x = [BitConverter]::ToInt16($data, $recordOffset + 12)
$y = [BitConverter]::ToInt16($data, $yOffset)
$z = [BitConverter]::ToInt16($data, $recordOffset + 16)
if ($x -ne -1959 -or $y -ne 66 -or $z -ne 790) { throw 'Origem divergente' }
$newY = [BitConverter]::GetBytes([int16]0) # TESTE HIPOTETICO, nao terreno medido
$data[$yOffset] = $newY[0]
$data[$yOffset + 1] = $newY[1]
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
[System.IO.File]::WriteAllBytes($target, $data)
# Reabrir e validar X/Y/Z, tamanho e diferencas antes de comprimir.
```

**Evitar:** repetição do script de build V1 que falha com arquivos já existentes; usar novos diretórios de versões ou idempotência segura com comparação de hashes; nunca usar `-Force` indiscriminadamente em arquivos de jogo/backups.

---

## 5. Fluxo técnico consolidado para futuros ESL

```text
Steam original (arquivos proprietários)
  ↓ copiar para workspace e fazer backup SHA-256
BIO4\Etc\emleon00.esl.lfs
  ↓ re4lfs.exe (descompactar)
emleon00.esl
  ↓ QuadX Import → Enemy ESL File (Little Endian)
  ↓ identificar room + index + tipo + ativo + posicao
  ↓ alteração mínima, documentar coords anteriores/novas
  ↓ QuadX Export → Enemy ESL File (destino pode ser o caminho de origem!)
emleon00.esl exportado (verificar tamanho e diff)
  ↓ reconstrução binária usando arquivo original como base, se necessário
ESL isolado 8160 B — somente registros aprovados
  ↓ re4lfs.exe para compactar
emleon00.esl.lfs
  ↓ re4lfs.exe para descompactar em pasta nova + SHA-256 roundtrip
  ↓ backup seguro + instalacao reversivel / alternativa documentada
BIO4\Etc\emleon00.esl.lfs (instalado temporariamente)
  ↓ executar RE4 e validar in-game, screenshots e log
  ↓ restaurar backup quando apropriado
```

**Critérios de aceite de uma modificação ESL:**
- Houve alteração somente nos registros/campos planejados.
- O conteúdo foi reimportado com sucesso no QuadX (quando relevante).
- Arquivo LFS passa round-trip binário.
- O jogo carrega sem travar e o inimigo aparece na sala esperada.
- Coordenada vertical, colisão, AI/movimento e gameplay foram observados.
- Existe rollback testável e registro de hash.

**PowerShell — cuidados especiais:**
- Comandos com `if {...} else {...}` precisam ser executados **como um bloco completo**: o usuário enfrentou erro `'else' não é reconhecido` quando executou o `else` isoladamente.
- Nunca deixar placeholder literal como `COLE_AQUI_O_CAMINHO_DO_ESL_EXPORTADO` e depois interpretar hash `$null` como sucesso. Ocorreu anteriormente uma falsa comparação positiva; scripts futuros precisam validar todos os caminhos e **interromper** no primeiro erro.
- `Get-FileHash` compara dados do arquivo; se compactações diferirem de tamanho, não implica erro. Validar conteúdo via extração de round-trip.
- Verificar interpretação little-endian e valores `Int16` antes de fazer patch manual.

---

## 6. Possibilidades, limitações e prioridades do mod

### Recursos desejados

- Alterar **posicionamento e composição dos inimigos** por sala, em ondas e encontros.
- Alterar **objetos de cenário** (casas, cercas, barricadas, torre, itens), reutilizando modelos e cenários originais.
- Alterar **texturas** e paleta visual para transmitir vila fortificada/contaminação e clima noturno.
- Ajustar **iluminação** quando os formatos e ferramentas suportarem; avaliar jogos de luz e renderização antes de prometer ciclo de dia/noite.
- Criar **elementos interativos** (torre, documentos, sino), transições, condições e **eventos de fase**.
- Criar **novos personagens** e novas variantes de Ganados por composição/edição de modelos, testes de animação, hitbox, IA e compatibilidade.
- Criar **textos e documentos**, diálogos Leon↔Hunnigan e cenas ilustradas. Cutscenes roteirizadas com ferramentas compatíveis são fase de pesquisa posterior.

### Riscos conhecidos

- QuadX é editor de dados do jogo, **não engine completa**; criar campanha com triggers, AI customizada ou cutscenes pode exigir ferramentas adicionais e pesquisa em formatos específicos.
- Novos spawns podem esbarrar em **limites de registros ESL (255)** e limites internos de IA/quantidade simultânea; não assumir que ~42 Ganados podem estar vivos ao mesmo tempo; testar ondas/condições de spawn.
- Novas posições podem causar inimigo flutuando, enterrado, preso em barreiras, fora da navmesh, em eventos que não o ativam. Testar física e jogabilidade real.
- Integração do `xFile` não está pronta; modelos 3D de inimigos são genéricos no QuadX.
- Ao reconstruir `UDAS` para editar `.AEV`, `.ITA`, `.ETS`, `.LIT`, etc., a etapa de repack e instalação deve ser pesquisada e testada individualmente, mantendo índices/ordem e backups; não inferir que modificar só arquivo extraído seja suficiente.
- O comportamento dos mapas customizados, entradas/saídas e scripts ainda não foi validado.
- Para compartilhar o mod publicamente, **não redistribuir arquivos completos proprietários da Steam**.

### Backlog proposto, com status real

| ID | Trabalho | Status comprovado |
|---|---|---|
| RE4-001 | Instalar jogo UHD, QuadX, Tweaks e ferramentas | **Concluído** |
| RE4-002 | Extrair room `r101` via LFS + DAT/UDAS | **Concluído** |
| RE4-003 | Visualizar geometria SMD/SMX | **Concluído** |
| RE4-004 | Extrair texturas HD PACK | **Concluído** (295) |
| RE4-005 | Mostrar vila HD no QuadX | **Concluído** |
| RE4-006 | Importar ESL Little Endian e mapear registros R101 | **Concluído** |
| RE4-007 | Reposicionar Don Esteban (`0x16`) | **Concluído no editor** |
| RE4-008 | Exportar, comparar diff e isolar registro | **Concluído** |
| RE4-009 | Compactar, round-trip LFS e hash | **Concluído** |
| RE4-010 | Instalar teste reversível e iniciar jogo | **Concluído para V1** |
| RE4-011 | Confirmar novo spawn in-game | **Concluído**, mas Y flutuante |
| **RE4-014** | Corrigir Y/altura e validar AI do Don Esteban | **Próxima tarefa** |
| RE4-015 | Documentar procedimento de rollback e criar instalador seguro | A fazer |
| RE4-016 | Criar conjunto de posicionamentos de patrulhas r101 | A fazer |
| RE4-017 | Investigar alterações de ITA/ETS/AEV na room r101 | A fazer |
| RE4-018 | Protótipo de documento interativo na torre | A fazer |
| RE4-019 | Protótipo do evento do sino | A fazer / pesquisa |
| RE4-020 | Variante visual simples de um Ganado e teste de animação | A fazer / pesquisa |
| RE4-021 | Mapa/roteiro detalhado do Capítulo 1 | A fazer |
| RE4-022 | PoC de transição entre salas e narrativa | A fazer / pesquisa |

Números de task são **referências internas propostas**; no histórico houve numeração inconsistente; ao adotar tracker real, normalizar IDs em `01_DOCUMENTACAO/backlog.md`.

---

## 7. Sugestão de organização de repositório Git/Codex

**Não reorganizar arquivos binários existentes sem aprovação**. O projeto já tem pastas numeradas; adicionar gradualmente estrutura de automação:

```text
F:\RE4_MOD_PROJECT\
├── AGENTS.md                  # este arquivo, instruções para Codex
├── README.md                  # apresentação / setup / situação atual
├── .gitignore                 # Steam, extrações, assets proprietários, builds, backups
├── 01_DOCUMENTACAO\
│   ├── visao-produto.md
│   ├── roteiro.md
│   ├── backlog.md
│   ├── mapa-salas.md
│   ├── experimentos.md
│   └── decisoes.md
├── 06_CODIGO\
│   ├── scripts\
│   │   ├── Diagnosticar-Ambiente.ps1
│   │   ├── Validar-ESL.ps1
│   │   ├── Criar-PatchESL.ps1
│   │   ├── Build-LFS.ps1
│   │   ├── Instalar-ModTeste.ps1
│   │   └── Restaurar-Original.ps1
│   └── tests\
├── 07_TESTES\                  # dados binários + logs + screenshots (não Git)
└── 08_RELEASES\                # apenas patches redistribuíveis
```

**Exemplo de `.gitignore` a revisar antes de criar:**

```gitignore
# Arquivos originais/extraídos do RE4 e assets proprietários
*.udas
*.udas.lfs
*.dat
*.dat.lfs
*.pack
*.pack.lfs
*.idxpack
*.idxj
*.smd
*.smx
*.dds
*.tga
*.esl
*.esl.lfs
*.pm[dx]
*.exe
*.dll
# Build, testes e backups locais
07_TESTES/
QUADX_GAME_ROOT/
02_MAPAS/*/originais/
02_MAPAS/*/extracao_separada/
```

**Obs.:** `.gitignore` acima é ilustrativo e pode precisar de exceções se forem criados **patches redistribuíveis próprios** com extensões similares; não simplesmente executar `git add .` em projeto já existente. Manter scripts, docs e manifestos no repositório.

### Primeiro pedido útil para Codex

> Leia o `AGENTS.md` inteiro. Faça um inventário **somente leitura** do workspace real e confirme quais caminhos existem. Depois proponha uma implementação de pipeline PowerShell 5.1 idempotente para (1) gerar variante V2 de `emleon00.esl` preservando só registro `0x16`, (2) fazer build/round-trip LFS, (3) registrar hashes e (4) preparar instalação/rollback seguro sem alterar a pasta Steam até aprovação. Produza scripts versionáveis, testes e README; não invente comandos nem formatos. Comece validando que V1 e backup estão íntegros.

---

## 8. Fontes técnicas de referência

São URLs citadas nas conversas e/ou repositórios públicos das ferramentas. **As versões e o comportamento atual devem ser verificados** antes de decisões dependentes de implementação:

- Re4QuadX (código-fonte): https://github.com/r3nzk/Re4QuadX
- QuadX Wiki — Setup: https://github.com/r3nzk/Re4QuadX/wiki/Setup
- QuadX Wiki — Automation and Tools: https://github.com/r3nzk/Re4QuadX/wiki/Automation-and-Tools
- JADERLINK DAT/UDAS Tool: https://github.com/JADERLINK/JADERLINK_DATUDAS_TOOL
- JADERLINK UHD PACK Tool: https://github.com/JADERLINK/RE4-UHD-PACK-TOOL
- JADERLINK GCA Tool (RE4 2007, não necessário para UHD): https://github.com/JADERLINK/RE4-2007-GCA-TOOL
- emoose RE4 research e re4lfs: https://github.com/emoose/re4-research
- RE4 Tweaks: https://github.com/nipkownix/re4_tweaks
- RE4 Tweaks Wiki — Modding Enhancements: https://github.com/nipkownix/re4_tweaks/wiki/Modding-Enhancements

**Observação de precisão:** em etapas anteriores algumas instruções sugeriram caminhos e relações de arquivos sem prova no código-fonte. Ao atuar como Codex, considerar essas hipóteses **não verificadas** até inspecionar arquivos, documentação ou implementação. O que está objetivamente confirmado é o resultado prático: QuadX mostrou a vila com texturas e o jogo executou com o ESL V1 modificado.

---

## 9. Registro dos problemas resolvidos e das lições

1. **QuadX não conseguia abrir rooms no layout original LFS:** o editor buscava `St1\r101\0000.SMD/SMX`; a instalação Steam tinha `r101.udas.lfs`. Resolveu-se descompactando LFS, extraindo UDAS e preparando diretório de teste separado com SMD/SMX.
2. **Erro `The extension is not valid: LFS` ao usar DAT/UDAS:** DAT/UDAS não processa `.lfs` diretamente. Primeiro descompactar via `re4lfs`, depois extrair `.udas`.
3. **Visualização cinza/branca:** geometria renderizava em wireframe; material/texture pipeline não configurado. Extração de `44000101.pack.lfs` e preparação de `.pack`, `.idxpack`, DDS/TGA em `QUADX_GAME_ROOT\BIO4\ImagePackHD` culminaram em visualização HD.
4. **xFile faltando e erros PMD:** avisos persistentes para modelos 3D de inimigos/objetos, mas sem impedir vista da vila.
5. **PowerShell não encontra PACK Tool:** executável estava em `RE4_UHD_PACK_TOOL.V.1.0.8`, não em pasta sem versão. Resolver sempre caminhos reais.
6. **Export do QuadX não mostrava diálogo:** gravou em cima do ESL de origem e adicionou 32 bytes zeros; isolou-se exclusivamente o registro de interesse sobre backup de 8.160 bytes.
7. **Três inimigos foram alterados acidentalmente no editor:** offsets revelaram mudanças em registros `0x15`, `0x16` e `0xFB`; patch isolado preservou só `0x16`.
8. **Falhas de sintaxe/comparação no PowerShell:** `else` executado separadamente e placeholder de caminho não substituído causaram erros e falso positivo. Corrigir por scripts atômicos com fail-fast.
9. **Tamanho do `.lfs` diferente do original Steam:** build compactada tinha 3.314 B contra 3.310 B original; round-trip SHA-256 conferiu conteúdo, e o jogo carregou.
10. **Primeira modificação in-game bem-sucedida com defeito de altura:** Ganado apareceu na nova localização, mas flutuando levemente; ajustar Y com teste mensurável, não presumir que Y=0 sempre corresponda ao chão.

---

## 10. Checklist antes da próxima operação de escrita

- [ ] Confirmar que está em `F:\RE4_MOD_PROJECT`, não no jogo original.
- [ ] Confirmar formatos/arquivos por tamanho e SHA-256.
- [ ] Confirmar que backup original **não será sobrescrito**.
- [ ] Confirmar qual build V1 está instalada ou se foi restaurada.
- [ ] Nomear a nova versão em diretório diferente (`V2`, `V3`...), com manifesto de hashes.
- [ ] Garantir diff binário limitado ao registro/campo desejado.
- [ ] Validar compactação por round-trip e hash.
- [ ] Não modificar a Steam sem autorização e rollback claro.
- [ ] Testar dentro do jogo com evidência visual e registrar resultado.
- [ ] Atualizar backlog, experimentos e este documento quando houver mudança confirmada.

**Fim do contexto transferível para Codex.**
