# Viabilidade de campanha selecionável no menu principal

**Conclusão.** Uma entrada própria no menu principal é uma linha de pesquisa plausível, com viabilidade ainda indeterminada para a build local 1.1.0. O principal trabalho é iniciar uma partida com estado coerente e persistência segregada. A presença de uma nova linha visual, por si só, cobre apenas a interface.

## Evidências

- O Tweaks ativo está registrado no log como 1.9.1.0. Sua documentação descreve `-room` e `-pos` para depuração, `-load` para slot e `-gamedir` para redirecionar BIO4, além de `roominfo_new.dat` para ferramentas de salto. A documentação consultada cobre atalhos e dados de depuração. O projeto ainda precisa provar a inicialização completa de uma campanha alternativa e a localização dos saves. [RE4 Tweaks — Modding Enhancements](https://github.com/nipkownix/re4_tweaks/wiki/Modding-Enhancements)
- O boshjerns SDK 0.1.1 tem documentação local e demonstra, segundo o autor do SDK, páginas adicionais no menu de opções durante o jogo. O salto de sala é marcado como implementado com teste em jogo pendente em `FEATURES.md`. O pacote mira uma build específica e o autor relata testes da versão em jogo sem outros mods. A compatibilidade com o Tweaks e com o executável com LAA deste projeto precisa ser verificada. [Repositório do SDK](https://github.com/boshjerns/re4-boshjerns-sdk)
- `BIO4/Title` contém arquivos localizados `*_press_Start.fix.lfs`. A presença desses recursos atesta a existência de dados de apresentação do título. A ligação com a lista de ações do menu segue pendente. A pasta `BIO4/sv` observada contém `dbgfont.tga`; o local efetivo dos saves precisa de evidência independente.

## Caminhos comparados

| Caminho | Viabilidade preliminar | Prova necessária |
|---|---|---|
| Perfil externo de desenvolvimento | Melhor candidato imediato, com custo baixo. Pode selecionar uma árvore BIO4 em novo processo. | Confirmar redirecionamento, partida coerente e destino de saves/configurações. Usar salto de sala para teste pontual. |
| Reaproveitar entrada de modo existente | Indeterminada, custo médio/alto. Útil como ensaio de inicialização, com risco de herdar personagem, desbloqueios, capítulos, flags e slots do modo escolhido. | Identificar seleção, carregamento e comportamento de saves do modo. Demonstrar preservação dos modos originais antes de considerar distribuição. |
| Nova ação no menu principal | É o objetivo final. Custo alto, condicionado a identificar registro de opções e ciclo de inicialização na versão alvo, por dados ou extensão em runtime. | Adicionar uma opção selecionável, iniciar com estado próprio, isolar persistência e voltar ao título sem contaminar a sessão original. |

## Prova de conceito em etapas

1. Registrar build alvo pelo hash de `bio4.exe` e versões de Tweaks/SDK. Ler as referências do SDK sobre menus e inicialização e inventariar recursos do título para identificar se a lista e as ações têm caminho de extensão por dados.
2. Em ambiente de teste autorizado, provar primeiro um início Aftermath determinístico com sala, coordenadas de Leon, inventário, dificuldade, flags e checkpoint explicitados. Confirmar onde o jogo grava saves e em que condições Steam Cloud atua. Validar segregação usando dados descartáveis antes de qualquer save pessoal.
3. Fazer uma entrada de teste navegável por teclado e controle, com voltar/cancelar. Ligar a ação ao início validado e testar título → campanha original → título → Aftermath, repetindo na ordem inversa. Testar salvamento, carregamento, continuar, morte, troca de idioma e reinício de processo.
4. Se a alternativa por dados não oferecer uma ação independente, avaliar um componente C++ próprio e reversível, apoiado em código-fonte revisado. Só levar adiante após confirmar compatibilidade com o Tweaks, comportamento em builds desconhecidas e possibilidade de retirar o componente preservando o perfil original.

**Gate de entrega:** selecionar Aftermath no menu principal, progredir até um checkpoint, fechar e reabrir o jogo e retomar apenas o progresso correto. A campanha original e os extras devem continuar acessíveis, com controles e saves íntegros. Se a prova falhar, o capítulo ainda pode avançar com perfil separado para desenvolvimento.
