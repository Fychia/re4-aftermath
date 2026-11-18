# Plano de desenvolvimento do Capítulo 1 — A Vila

O plano adapta a especificação v0.1 lida no ZIP de conceito em `02_MAPAS`. A sequência joga do sul para o norte, da floresta até o portão rumo à fortaleza. A primeira fatia proposta concentra o teste de maior maturidade em r101. O mapa conceitual orienta composição, ritmo e pontos de interesse.

| Área | Base candidata | Protótipo e aceite |
|---|---|---|
| 1. Mirante | r100 ou r104 | Spawn de Leon em área segura, ponto de observação com vila e fortaleza legíveis e instrução de Hunnigan por texto. Avaliar silhueta distante simplificada e enquadramento fixo antes de binóculos ou cena animada. |
| 2. Descida | r100/r104 | Caminho, ponte e vegetação reaproveitados conforme inventário, primeiro encontro pequeno. Validar declives, travessia, câmera e retomada após morte. |
| 3. Posto Avançado | Limite de r101 ou sala adjacente verificada | Documento sobre Las Plagas e alerta de um Ganado. Provar leitura em interação já suportada e estado de alerta reproduzível. Torre e iluminação de madrugada entram após validar colisão e dados locais. |
| 4. Vila | r101; r103 como fonte candidata de peças rurais | Praça, estruturas existentes e rotas utilizáveis. Corrigir Don Esteban, depois testar patrulha, itens, barricadas e cerco em incrementos. C01–C18 são referências de composição. Só acrescentar moradias/telhados após prova de geometria, colisão e custo de desempenho. |
| 5. Igreja | r108 | Igreja e cemitério reconhecíveis, documento que aponta Brute e portão norte condicionado ao cerco. Validar ida, retorno e retomada antes e depois da abertura. A fortaleza aparece à distância neste capítulo. |

## Sequência de produção

1. **Fundação.** Na V2 local, manter X/Z da V1 e variar Y em builds separadas, com ponto de partida medido no terreno ou tomado de um spawn de referência. Conferir o diff do ESL e iniciar sempre do mesmo estado. Observar contato dos pés, movimento, perseguição e combate no jogo conforme o [backlog](backlog.md). Fixar a linha de base e registrar sala, build e evidência.
2. **Fatia jogável.** Validar repack de r101, uma interação de documento e um encontro curto, com início e condição única de encerramento. Adicionar travessia entre duas salas. Ao fechar esse marco, verificar entrada, progressão, reinício e saída sem bloqueio.
3. **Montagem do percurso.** Incorporar mirante, descida e igreja. Testar cada ligação no sentido planejado e registrar o comportamento ao retornar. Adicionar textos de Hunnigan e pistas pós-cerco depois de confirmar formato e persistência. Avaliar visibilidade e câmera antes de ampliar construções.
4. **Duas rotas do sino.** Localizar o evento original, seu gatilho, efeitos de IA e estado de saída. Em um ensaio curto, testar resolução por eliminações e depois interação manual. Ambas devem levar ao mesmo estado, impedir reativação e liberar o portão uma única vez. Verificar se os Ganados convergem para a igreja com os recursos existentes. Se a atração depender de lógica indisponível, levar ao autor uma adaptação baseada no encerramento comprovado do encontro.
5. **Escala e encerramento.** Tratar cerca de 42 eliminações como meta acumulada de design. Medir vivos simultâneos, tempo de quadro, aparecimento e bloqueios de IA com ondas pequenas antes de aumentar a contagem. Registrar o ponto em que o desempenho degrada ou o estado de encontro perde consistência.

## Aceite do capítulo

Leon começa no mirante e enxerga os marcos. O caminho até o posto e a vila funciona com câmera e colisão coerentes. O alerta e o combate progridem sem travamento. As duas resoluções do cerco são avaliadas de forma independente, inclusive corrida entre gatilhos, saída e retorno, morte e carregamento. Igreja e passagem norte exibem o estado esperado, com documentos legíveis e teste de restauração registrado. Durante o teste, comparar desempenho e carregamento com a mesma sala base e anotar hardware, configuração e build.
