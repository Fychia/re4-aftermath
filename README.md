# Resident Evil 4: Aftermath

Projeto independente de campanha para Resident Evil 4 Ultimate HD Edition (Steam, 2014). O primeiro capítulo, A Vila, começa na floresta e segue em direção à região ocupada por Brute.

| Área | Estado |
| --- | --- |
| Mirante | A MAP-002 v001 altera terreno e colisão de r100. O cenário abriu em jogo com artefatos de material. A travessia e o percurso completo seguem em validação. |
| Inimigos | A edição V1 de Don Esteban em r101 foi confirmada no jogo. |
| Menu | O fluxo independente de Aftermath é testável em PowerShell/WinForms. A integração ao título UHD está pendente. |
| Introdução | A candidata Alpha apresenta nove cartões de texto externos com opção de pular. |

## Desenvolvimento

Use Windows PowerShell 5.1 e uma cópia própria do jogo. Os scripts usam caminhos locais que precisam corresponder ao ambiente de desenvolvimento. O diagnóstico descreve a cadeia de ferramentas e as dependências.

- [Diagnóstico técnico](01_DOCUMENTACAO/DIAGNOSTICO_TECNICO.md)
- [Mapa, build e restauração](01_DOCUMENTACAO/MAP-002.md)
- [Protótipo do menu](01_DOCUMENTACAO/MENU-001.md)
- [Arquitetura](01_DOCUMENTACAO/ARQUITETURA.md) e [backlog](01_DOCUMENTACAO/backlog.md)

O repositório versiona fontes, scripts e documentação. Recursos proprietários, executáveis, extrações, backups e builds locais ficam no workspace e devem ser reconstruídos a partir da instalação do desenvolvedor.
