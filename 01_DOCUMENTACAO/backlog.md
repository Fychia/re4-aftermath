# Backlog técnico

Os IDs já usados no AGENTS foram preservados quando aplicáveis. P0 desbloqueia testes seguros e reproduzíveis. P1 entrega a primeira fatia jogável. P2 amplia o capítulo e pesquisa o menu. P3 depende dos resultados de geometria ou integração. A ordem abaixo indica dependências.

| Prioridade | ID | Trabalho e aceite | Dependência |
|---|---|---|---|
| P0 | RE4-023 | Concluído. Inicializar Git e versionar as fontes próprias com conferência dos caminhos incluídos. | Git do Visual Studio |
| P0 | RE4-015 | Automatizar baseline, build e round-trip ESL em PS 5.1. Reproduzir o payload V1 por hash. Ensaiar rollback em arquivos descartáveis e verificar integridade após execução interrompida. | Backups identificados |
| P0 | RE4-024 | Provar perfil de teste isolado com Tweaks. Confirmar precedência de dados e destino de saves, configurações e logs. | Sessão de teste autorizada |
| P0 | RE4-014 | Corrigir altura de Don Esteban. Comparar variantes só de Y, registrar o contato dos pés, movimento, combate, reinício e reentrada. | RE4-015, RE4-024 ou teste reversível autorizado |
| P1 | RE4-021 | Fichar r100/r101/r103/r104/r108 e escolher correspondência das cinco áreas. Registrar dependências, transições candidatas e roteiro legível de objetivos. | Arquivos locais |
| P1 | RE4-017 | Validar repack UDAS sem edição e depois editar um único componente de referência por vez (ITA, ETS ou AEV). Aceite por diff, reextração e carregamento. | RE4-024 |
| P1 | RE4-016 | Reposicionar pequeno grupo de patrulha e verificar ativação, colisão, navegação e capacidade de recuperação. | RE4-014 |
| P1 | RE4-018 | Prototipar documento e alerta no posto. A interação ocorre uma vez e pode ser retomada pelo checkpoint. | RE4-017 |
| P1 | RE4-022 | Provar ligação entre salas reaproveitadas. Testar entrada correta, retorno, morte e save/load. | RE4-021, RE4-017 |
| P1 | RE4-019 | Rastrear evento original do sino e validar uma condição de encerramento com poucos inimigos. Verificar áudio, IA e liberação da saída. | RE4-017, RE4-016 |
| P2 | RE4-025 | Integrar cinco áreas e provar as duas rotas do cerco. Medir concorrência, escala em ondas e convergência do estado. | RE4-018, RE4-022, RE4-019 |
| P2 | RE4-026 | Pesquisar inicialização e persistência pelo menu. Provar seleção com retorno ao título e saves segregados. | RE4-024, início de campanha definido |
| P3 | RE4-020 | Validar uma variante visual com renderização, animação e colisão compatíveis. | Fluxo de modelo demonstrado |
| P3 | RE4-027 | Investigar geometria/colisão próprias e registro de novo ID de sala. Provar cada capacidade separadamente. | RE4-017, RE4-022 |

RE4-001 a RE4-011 formam a linha de base histórica, da configuração de ferramentas ao spawn V1 in-game. A V1 ainda tem o defeito de altura tratado em RE4-014.
