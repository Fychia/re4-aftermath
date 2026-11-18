# Diagnóstico técnico do workspace

**Data:** 18/11/2026, America/Sao_Paulo. Inspeção de arquivos, logs, conteúdo do ZIP, metadados e SHA-256 em modo somente leitura. O teste jogável é evidência histórica fornecida pelo autor.

## Documentação e código

- [AGENTS.md](../AGENTS.md) está na raiz. Na leitura inicial, o arquivo estava em `JORNADA`. Foram lidos também os relatos `MinhaJornada001.txt` e `MinhaJornada002.txt` e o procedimento `Como desinstalar o mod.txt`.
- A especificação `01_DOCUMENTACAO/LEVEL_DESIGN/CH01_A_VILA_LEVEL_DESIGN.md` foi lida integralmente dentro de [RE4_Aftermath_Capitulo_01_Conceito.zip](../02_MAPAS/RE4_Aftermath_Capitulo_01_Conceito.zip). O ZIP inclui o mapa em PNG, PDF e SVG. Há também um PDF avulso em `02_MAPAS`. [roteiro.txt](roteiro.txt) e [brute.txt](brute.txt) são referências narrativas. Para a localização do cientista, o AGENTS registra a decisão posterior de transferência do castelo para a ilha.
- [Preparar-RE4QuadX.ps1](../06_CODIGO/Preparar-RE4QuadX.ps1) é o único script encontrado no projeto. Copia insumos, descompacta LFS, extrai contêineres e emite logs. Os dois logs em `07_TESTES/logs` registram extração e reaproveitamento. O script fixa `St1`, aceita saídas existentes por presença e continua após aviso do DAT/UDAS. Mesmo com `-SkipExtraction`, pode criar pastas, cópias e log. O nome do parâmetro descreve a extração, portanto o script ficou fora da inspeção em modo somente leitura. O código de patch ESL citado no histórico não foi encontrado como script salvo.
- `03_MODELOS`, `05_AUDIO` e `08_RELEASES` estão vazios na inspeção. `02_MAPAS/r101/DAT` é uma pasta de preparação, sem DAT extraído em r101.

## Ferramentas disponíveis

| Ferramenta | Evidência e uso |
|---|---|
| QuadX 1.0.1 | `F:/RE4QuadX.v1.0.1_x64/Release/Re4QuadX.exe`. Visualização e edição ESL já demonstradas pelo autor. Prévia de PMD depende do xFile, ainda ausente na configuração relatada. |
| RE4 Tweaks | Steam `Bin32/dinput8.dll`, INI, log e pasta `re4_tweaks`. Log registra 1.9.1.0-7cfcf5c4-master e jogo 1.1.0. |
| re4lfs | `F:/Tools/re4-research_build-1.2a/re4lfs.exe` e dependência `xcompress64.dll`. Também há 1.3a em `F:/re4-research_build-1.3a`. Reproduzir a partir da versão histórica 1.2a. As duas distribuições trazem re4sym e re4resample. |
| DAT/UDAS Tool 1.0.4 | `F:/Tools/JADERLINK_DATUDAS_TOOL.V.1.0.4`, com executável e wrappers de extração/reempacotamento IDX/IDXJ. O suporte a repack vem da documentação da ferramenta. O carregamento de um UDAS reconstruído segue pendente localmente. |
| UHD PACK Tool 1.0.8 | `F:/Tools/RE4_UHD_PACK_TOOL.V.1.0.8`, com executável e batch de extração/repack. Extração HD demonstrada. |
| GCA 1.1 | `F:/Tools/RE4_2007_GCA_TOOL-V.1.1`. Utilitário para PC 2007, fora do fluxo UHD verificado. |
| PowerShell e Git | Windows PowerShell 5.1 confirmado. Git existe no Team Explorer do Visual Studio Community 18, fora do PATH. O repositório local foi inicializado após a inspeção, com inclusão explícita de fontes próprias. |
| Editores e SDK | Blender em `F:/blender.exe`, Visual Studio Community 18 e VS Code localizados. GIMP consta do histórico sem caminho confirmado. O pacote `F:/re4-boshjerns-sdk-0.1.1` contém documentação e instaladores. Sua compatibilidade com esta instalação permanece pendente. |

[QuadX](https://github.com/r3nzk/Re4QuadX/blob/main/README.md) · [DAT/UDAS Tool](https://github.com/JADERLINK/JADERLINK_DATUDAS_TOOL) · [RE4 Tweaks](https://github.com/nipkownix/re4_tweaks) · [boshjerns SDK](https://github.com/boshjerns/re4-boshjerns-sdk)

## Recursos extraídos e candidatos

- `02_MAPAS/r101` tem `r101.udas.lfs` (3.428.292 B), `r101.udas` (10.049.280 B), `r101.idxJ` (1.272 B) e duas extrações de 40 arquivos, em `r101/` e `extracao_separada/r101/`. Contêm CAM, SAT, LIT, SMD, SMX, SHD, EFF, TEX, ITM, ETM, ETS, EAR, SAR, EAT, AEV, RTP, MDT, CNS, STB, FSE, ESE, OSD, BLK, EVS, DRA, BIN, TPL, ITA, DSE, EMI, UWF, SND e HEX. Preservar entradas auxiliares e ordem no repack. Em r101 foi localizado UDAS e a busca em `St1` por DAT correspondentes veio vazia.
- `INIMIGOS` contém dez LFS de ESL (`emleon00` a `emleon09`), export do editor e backup ESL descompactado. `emleon00` contém registros de mais de uma sala.
- `04_TEXTURAS/r101` tem PACK normal comprimido e descomprimido, além de PACK HD comprimido, descomprimido e IDXPACK HD. A extração HD contém 140 DDS e 155 TGA. O ambiente QuadX tem as mesmas contagens, PACK e índice. Os SHA-256 de `0000.SMD` e `0000.SMX` coincidem com `r101_004.SMD` e `r101_005.SMX`, respectivamente. O histórico registra a renderização HD bem-sucedida.
- Na Steam, `BIO4/St1` contém os UDAS LFS de r100, r101, r103, r104 e r108. r100 tem também `r100_00.dat.lfs` a `r100_04.dat.lfs`. Há PACK normal e HD com sufixos nominais 100, 101, 103, 104 e 108. A associação de material foi demonstrada para r101. As demais salas candidatas ainda precisam de dependências, texturas e transições validadas.

## Alteração e backups

| Arquivo ou grupo | Bytes | SHA-256 |
|---|---:|---|
| Steam `BIO4/Etc/emleon00.esl.lfs` e `07_TESTES/BUILD/emleon00.esl.lfs` | 3.314 | `3C50AFE9B6EF403D4212EDD8D653C55E7DB5BF1617BCD3F1319EFF4D0B422998` |
| `07_TESTES/BACKUP_STEAM/emleon00.esl.lfs` e `02_MAPAS/r101/INIMIGOS/emleon00.esl.lfs` | 3.310 | `3711B09CD45AC5D7D35D1C5A345097013D980EEB4D9F17AEC6B9EA3A0721C3DE` |
| `02_MAPAS/r101/INIMIGOS/emleon00.backup.esl` | 8.160 | `B9DB8C27C6A69279ACF8C2038A4C502F0590DC03DAA2596EA228745B5EA4D386` |
| `07_TESTES/{ESL,BUILD,VALIDACAO}/emleon00.esl` | 8.160 | `56C22CC65DA13FF3DECE9F6595613BE1A80777362B133D82644173F72728295F` |
| Steam `BIO4/St1/r101.udas.lfs` e `02_MAPAS/r101/originais/r101.udas.lfs` | 3.428.292 | `2EDD7C56E65D6F24D8023673E3A6E4D0988CE3971B41044A873F54F11C14A9E8` |

A **V1 permanece instalada**. O diff com o backup ESL mostra cinco bytes alterados (`0x02CC`, `0x02CD`, `0x02CE`, `0x02D0`, `0x02D1`), todos no registro `0x16`. O Don Esteban passou de (-610, 0, -84) para (-1959, 66, 790), com coordenadas little-endian. Já o export geral tem 8.192 B, mudanças em três registros e 32 bytes adicionais registrados no histórico. Os hashes das três cópias ESL validam o artefato guardado do round-trip histórico. O autor confirmou spawn na posição alterada, sem crash e com flutuação leve.

`Bin32/bio4.exe.bak` existe com 9.139.840 B. O cabeçalho PE confirma Large Address Aware ligado no executável ativo e desligado no backup. O backup de restauração do ESL, o ESL base e a cópia do UDAS são insumos distintos. O procedimento histórico de restauração confere o hash após a cópia. Antes de automatizá-lo, conferir também os hashes esperados de entrada e da instalação presente e prever recuperação em caso de interrupção.

## O que falta para novas áreas

Mapear, por sala, entradas e saídas, posições de chegada, geometria e materiais, superfícies de colisão, conectividade de IA, câmeras, iluminação, itens, eventos, áudio e referências globais de progressão. Provar um repack sem edição antes de alterar conteúdo. Adicionar um objeto reaproveitado por vez e validar caminhada, câmera e colisão. Uma sala com ID próprio exige prova separada de registro e carregamento no jogo, transições e save/load.

O Git localizado está acessível pelo caminho completo do executável. Para dados e testes da primeira fatia, a cadeia instalada é suficiente. Um conversor UHD específico de geometria/colisão será necessário **se** o protótipo sair da edição de entidades e exigir malha nova e as ferramentas atuais falharem nesse ciclo. Um editor de textos ou eventos só entra se uma interação de referência exigir formato que o QuadX e os utilitários atuais não cubram. Visual Studio/C++ e um SDK entram apenas se os testes do menu exigirem extensão em runtime. Blender fica disponível para produção de geometria e ajustes visuais após validar conversão. O [backlog](backlog.md) registra esses pontos de decisão.
