Aqui está um documento Markdown completo e unificado reunindo e organizando todas as informações contidas nos relatórios do projeto **Uai Farm** (High Concept, Narrativa, Prototipação de Baixa Fidelidade e Vertical Slice).

---

# Documento Unificado de Projeto: Uai Farm

**Disciplina:** CS1457 - Design de Jogos (UFOP) 

**Integrantes / Autores:** Jasmin Andrade Cordeiro & Vitor Angelo dos Santos 

---

## 1. Identificação do Projeto e Visão Geral

* 
**Título do Jogo:** Uai Farm 


* 
**Plataformas:** Web (Browsers) e Desktop (Windows/Linux) 


* 
**Faixa Etária Alvo:** 12 a 45 anos 


* 
**Classificação ESRB:** E (Everyone) - Livre 


* 
**Gênero:** Simulador de gestão de recursos rurais 2D integrado com sistemas de quebra-cabeças (Match-3).



### Resumo do Gameplay

O núcleo do gameplay baseia-se na expansão e otimização de uma fazenda, onde a aquisição de recursos e o progresso de construções dependem do desempenho do jogador em módulos de puzzles lógicos. O jogo opera em dois modos integrados:

* 
**Modo Gestão (Overworld):** Visão macro da fazenda em 2D com interface baseada em *Point & Click* para seleção de áreas, movimentação e navegação em menus.


* 
**Modo Desafio (Puzzle):** Interface de Match-3 ativada ao realizar ações de produção, exigindo o cumprimento de metas para validar a coleta de recursos.



### Diferenciais de Venda (USP)

* 
**Gamificação da Espera:** Progresso ativo dependente de performance lógica em vez de tempo real passivo.


* 
**Baixa Barreira de Entrada:** Mecânicas intuitivas e controles simplificados para sessões rápidas.


* 
**Temática Regionalista:** Ambientação e estética inspiradas na cultura, arquitetura e tradições do interior rural de Minas Gerais.



### Produtos Concorrentes

| Produto | Semelhança | Diferencial Acadêmico |
| --- | --- | --- |
| **Stardew Valley** | Estética rural e gestão. 

 | Foco em puzzles em vez de simulação de tempo real. 

 |
| **Candy Crush** | Core loop Match-3. 

 | Resultados aplicados em meta-jogo de construção. 

 |

---

## 2. Narrativa e Ambientação

### Premissa e Universo

Caio Souza, de 26 anos, leva uma vida urbana monótona trabalhando com TI e planilhas em Belo Horizonte. Ele recebe uma carta informando que herdou a **Fazenda Uai**, uma propriedade rural subutilizada e deteriorada nos arredores de Conselheiro Lafaiete, MG, de sua falecida avó Dona Fiota. Caio decide deixar a cidade grande para restaurar o legado familiar, reabrir a feira local e revitalizar a comunidade.

O tema central do jogo é a **reconexão**: entre o jovem e suas raízes, entre a modernidade e a tradição rural mineira, e entre o indivíduo e a comunidade.

### Estrutura Story Spine (Kenn Adams)

* 
**Era uma vez...** Um jovem chamado Caio vivia na cidade grande, trabalhando em um emprego monótono e desconectado de suas raízes mineiras. 


* 
**Todo dia...** Caio acordava cedo, pegava o metrô lotado e passava horas em frente a planilhas, sentindo que algo importante faltava em sua vida. 


* 
**Mas um dia...** Caio recebe uma carta informando que herdou a Fazenda Uai, propriedade abandonada de sua avó Dona Fiota, nos arredores de Conselheiro Lafaiete, MG. 


* **Por causa disso (1)...** Caio decide deixar a cidade e se mudar para a fazenda, mesmo sem experiência no campo. Ao chegar, encontra tudo deteriorado: roçado abandonado, curral vazio e paiol sem estoque. 


* 
**Por causa disso (2)...** Com a ajuda dos vizinhos, Dona Fiota (avó), Zé do Pasto e a pesquisadora Ana Luz, Caio aprende as técnicas do campo, resolvendo desafios práticos em forma de puzzles Match-3. 


* **Por causa disso (3)...** Cada desafio superado gera recursos: milho, leite, ovos, madeira. Caio os usa para restaurar estruturas da fazenda e revitalizar a feira local. 


* **Até que finalmente...** A Fazenda Uai atinge plena produtividade. A feira local é restaurada, a comunidade se fortalece e Caio encontra o equilíbrio entre modernidade e tradição. 


* 
**E desde então...** Caio segue expandindo a fazenda e transmitindo os conhecimentos aprendidos aos jovens da região, perpetuando o legado de Dona Fiota. 



### Configuração do Mundo (Game World Setting)

* 
**Época:** Contemporânea, interior de Minas Gerais, anos 2020. 


* 
**Lugar:** Fazenda Uai (região de Conselheiro Lafaiete / Campo das Vertentes, MG) e arredores imediatos (feira, estrada de terra, mata). 


* 
**Estética:** Pixel art 2D com paleta quente (verdes, terrosos, amarelos), referenciando a arquitetura colonial mineira e o cerrado. 


* 
**Tom:** Leve, acolhedor e otimista, celebrando a cultura caipira sem estereótipos negativos. 


* 
**Fronteira temporal:** Ciclos de dias, estações do ano e períodos de plantio/colheita. 



### Elenco de Personagens

* 
**Caio (Avatar/Herói):** 26 anos, nascido em BH, filho de migrantes rurais. Curioso, determinado, bem-humorado, usa smartphone com tutoriais agronômicos e gírias mineiras. Sua aparência traz camisa xadrez e chapéu de palha. Seu arco vai de executor urbano passivo a gestor ativo do campo.


* 
**Dona Fiota (Mentora):** 72 anos, avó de Caio. Sábia, afetuosa e direta, fala por provérbios mineiros. Fisicamente, usa coque, avental florido e uma bengala que serve para apontar áreas no mapa. Orienta Caio à distância.


* 
**Zé do Pasto (Vizinho/Comerciante):** 50 anos, pecuarista vizinho robusto de bigode espesso e botina. Prático, negociador e inicialmente cético com tecnologias; gerencia a feira local e propõe missões secundárias.


* 
**Ana Luz (Pesquisadora Rural):** 24 anos, agrônoma em extensão universitária. Entusiasta, analítica e empática, usa óculos redondos e carrega um tablet/prancheta. Traduz conceitos técnicos e atua como ponte de upgrades avançados (compostagem, irrigação).



---

## 3. Estrutura de Mecânicas e Dinâmicas

### Tabela de Mecânicas Gerais

| Mecânica | Input | Resposta do Sistema | Condições | Feedback |
| --- | --- | --- | --- | --- |
| **Mover personagem** | Clique no mapa | Caio se desloca até a coordenada clicada.

 | Sempre disponível no Modo Gestão.

 | Animação de caminhada; som de passos.

 |
| **Selecionar zona** | Clique sobre zona interativa | Abre menu contextual com ações disponíveis.

 | Caio deve estar adjacente à zona.

 | Highlight da zona; ícone de menu aparece.

 |
| **Iniciar tarefa** | Clique em ação no menu contextual | Instância de puzzle Match-3 é carregada.

 | Jogador deve ter ao menos 1 café.

 | Transição de tela; barra de café atualizada.

 |
| **Trocar peças (Match-3)** | Clique em peça + clique em adjacente 

 | Peças trocam; combos de 3+ são eliminados.

 | Só peças adjacentes (horizontal/vertical).

 | Animação de troca; partículas; som de encaixe.

 |
| **Cumprir meta (Movimentos)** | Atingir pontuação dentro do limite 

 | Puzzle encerrado com sucesso; recursos creditados.

 | Modo por movimentos ativo.

 | Banner "UAI! Desafio Concluído!"; recurso no inventário.

 |
| **Cumprir meta (Tempo)** | Atingir pontuação antes do tempo esgotar 

 | Puzzle encerrado com sucesso; recursos creditados.

 | Modo por tempo ativo.

 | Timer visual; sons de urgência nos últimos 5 segundos.

 |
| **Falhar puzzle** | Automático ao esgotar movimentos/tempo 

 | Puzzle encerrado sem recompensa; café consumido.

 | Movimentos ou tempo esgotados.

 | Banner de falha; café -1; nenhum recurso creditado.

 |
| **Tentar novamente** | Clique em "Tentar Novamente" 

 | Puzzle reiniciado com novo tabuleiro.

 | Jogador deve ter café disponível.

 | Café -1; tabuleiro reembaralha.

 |
| **Gerenciar recursos** | Clique no ícone de inventário 

 | Abre tela de estoque com quantidades.

 | Sempre disponível no Modo Gestão.

 | Painel com ícones e contadores.

 |
| **Descansar** | Clique na casa + ação "Descansar" 

 | Café restaurado ao máximo; dia avança.

 | Sempre disponível.

 | Animação de descanso; barra cheia; dia avança.

 |

### O Loop Central

O ciclo diário consiste em seis etapas fundamentais:

1. 
**Explorar:** Navegar pelo overworld (*point-and-click*).


2. 
**Selecionar Local:** Interagir com zonas produtivas (Roçado, Curral, Paiol).


3. 
**Desafiar:** Iniciar o quebra-cabeça Match-3 (consome 1 energia de café).


4. 
**Recompensar:** Ganhar recursos no inventário em caso de sucesso.


5. 
**Construir:** Utilizar recursos obtidos para aplicar upgrades estruturais e avançar na história.


6. 
**Descansar:** Ao zerar o café, o jogador dorme na casa de Caio para recuperar as energias e avançar o dia, reiniciando o loop.



### Dinâmicas Esperadas

* 
**Gestão de Energia:** O café funciona como recurso estratégico limitante (5 por dia). Como não é possível visitar todas as áreas de uma só vez, o jogador precisa priorizar suas ações.


* 
**Risco Calculado:** Perder consome energia. Isso ensina o jogador a ponderar se deve tentar uma zona de alta recompensa com metas difíceis ou focar em caminhos seguros.


* 
**Progressão em Cascata:** Os recursos colhidos em uma área abrem o progresso de outras (ex: milho do Roçado desbloqueia o Curral, que gera leite).


* 
**Equilíbrio Rítmico:** Alterna momentos relaxantes no Modo Gestão com picos de urgência em desafios por tempo no Match-3.


* 
**Ausência de Game Over Global:** Perder puzzles atrasa os upgrades, mas não encerra a partida, mantendo a experiência casual e acessível.



---

## 4. Planejamento de Dificuldade e Progressão

* 
**Fase Inicial (Dias 1 a 3):** Apenas o Roçado está acessível. Puzzles em modo por movimentos generosos (20 movimentos), tabuleiro $6\times6$, metas baixas (300 pontos) e sem peças com efeitos negativos. Dona Fiota guia com balões de fala explicativos.


* 
**Fase Intermediária (Dias 4 a 10):** Desbloqueio do Curral e do Paiol. Tabuleiros aumentam para $7\times7$, introdução de modo por tempo, metas elevadas e peças especiais (multiplicadores e bloqueios). O custo das 5 energias de café torna-se um dilema real. Inclusão de missões secundárias via Zé do Pasto e Ana Luz.


* 
**Fase Avançada (Dias 11 em diante):** Desbloqueio de novas áreas (horta expandida, compostagem). Tabuleiros $8\times8$, forte exigência de combos e tempos curtos. Planejamento rigoroso de rotas necessário. A feira local reabre gradualmente, oferecendo feedback visual macro de progresso.



---

## 5. Implementação Técnica (Etapa 7 - Vertical Slice)

### Decisões Tecnológicas

* 
**Engine:** Godot 4.7 (estável) – escolhida por sua leveza, licença open-source gratuita, suporte nativo a 2D e exportação facilitada para Windows/Web.


* 
**Linguagem de Programação:** GDScript – integração direta com a engine e curva de aprendizado ágil.


* **Estrutura Arquitetural:**
* 
**Autoload / Singleton (`GameState`):** Concentra o estado de persistência global (energia, inventário) no caminho `scripts/autoload/game_state.gd`, evitando acoplamento direto entre as cenas de Overworld e do tabuleiro.


* 
**Sinais do Godot:** Comunicação desacoplada entre cenas (ex: `puzzle_concluido`, `puzzle_falhou`), permitindo que a cena do Match-3 (`Match3Board`) funcione e seja testada de forma totalmente isolada.


* 
**Navegação:** Implementada via `NavigationAgent2D` + `NavigationRegion2D` para pathfinding em formato point-and-click.


* 
**Gerenciamento do Grid:** Matriz 2D representada por um `Array` $6\times6$ de inteiros. Os nós visuais das peças (`ColorRect`) são gerados e sincronizados via código dinamicamente (sem TileMap), viabilizando animações fluidas de quedas, trocas e cascatas.




* 
**Dependências Externas:** Nenhuma; utiliza exclusivamente a API nativa da engine.


* 
**Organização de Pastas:** Projeto Godot isolado em `vertical-slice/` com diretórios `scenes/` e `scripts/` divididos. Builds executáveis ficam fora do controle de versão e são integrados via GitHub Releases.



### Bugs Encontrados e Resolvidos na Etapa

1. 
**Tween sem Tweeners:** A lógica de gravidade e preenchimento criava instâncias de animações mesmo quando nenhuma peça precisava cair, gerando logs de erro. *Solução:* Instanciação lazy (apenas sob demanda real).


2. 
**Disparo Precoce do Fim do Puzzle:** Sinais de vitória/derrota eram emitidos imediatamente, fazendo o Overworld destruir o puzzle antes que o jogador visualizasse o banner de resultado. *Solução:* Adiamento do sinal para o clique no botão "Voltar".


3. 
**Build Exportada Sem PCK:** Arquivo de dados (.pck) separado do executável principal (.exe) gerava falhas por perdas acidentais em limpezas. *Solução:* Ativação da flag "Embed PCK" nas configurações de exportação.


4. 
**Sobreposição Visual de Personagem:** O `ColorRect` do cenário da zona interativa "Roçado" cobria o sprite do jogador ao se aproximar. *Solução:* Fixação do `z_index` do Caio acima dos elementos do cenário.


5. 
**Movimentação Indesejada Durante o Puzzle:** Cliques nas peças do Match-3 vazavam para o mapa, movendo Caio de forma invisível por trás do tabuleiro. *Solução:* Bloqueio explícito de inputs de pathfinding enquanto o minigame estiver ativo.



---

## 6. Resultados de Playtests e Validações

### Testes do Protótipo em Papel (Etapa 6)

Realizados com dois usuários: **Arthur Coelho** e **Guilherme Ferreira**. Ambos avaliaram o ritmo do jogo positivamente ("Tranquilo" e "Envolvente").

* **Pontos de Aprendizado:**
1. O custo prévio de café não estava claro (esperavam que só cobrasse em caso de erro).


2. Ausência de demarcação visual nas bordas gerava confusão sobre os limites exploráveis.


3. O linguajar e tom regional de Minas Gerais aplicados no texto foram amplamente elogiados.





### Testes da Vertical Slice Digital (Etapa 7)

Realizados em 21/06/2026 com três perfis distintos:

* 
**Testador 1 (Homem, 24 anos):** Alta familiaridade com casuais e simuladores. Achou o visual calmo e organizado, mas sentiu falta de aplicação prática imediata para os recursos coletados. (Sessão: 3 min) .


* 
**Testadora 2 (Mulher, 52 anos):** Perfil de jogadora mobile casual (Candy Crush). Teve dificuldades com a mecânica inicial de clique para andar e demorou para notar o círculo de proximidade do Roçado. (Sessão: 12 min) .


* 
**Testador 3 (Menino, 9 anos):** Jogador experiente (Minecraft/Roblox). Achou o puzzle lento, tentou clicar freneticamente no botão de debug "Reset Café" achando que era mecânica real de descanso e pediu para construir cercados de galinha. (Sessão: 15 min) .



### Plano de Ajustes para a Próxima Etapa (Etapa 8 - Demo Completa)

Com base nas falhas e sugestões coletadas, o grupo planejou as seguintes prioridades para a próxima entrega:

1. 
**Direcionamento e Tutorial:** Inclusão de um indicador de texto ou balão de fala com Dona Fiota logo no início do dia para direcionar o primeiro passo do jogador.


2. 
**Feedback no Clique do Overworld:** Adição de efeitos visuais ou mudança no cursor para evidenciar onde o jogador clicou no chão, além de aumentar o contraste do anel de interação das zonas.


3. 
**Propósito para os Recursos:** Adicionar uma consequência prática imediata ao milho colhido para saciar o desejo de progresso do jogador (mesmo que por meio de um sistema simples ou placeholder de upgrade).


4. 
**Abertura do Curral ou Paiol:** Priorizar a estruturação básica de novas zonas no mapa para reduzir a falsa expectativa gerada pelos contadores do HUD.


5. 
**Ação de Descanso Real:** Substituir o botão de debug "Reset Café" pela mecânica real da tela de descanso e avanço de dia para evitar confusão de interface.


6. 
**Balanceamento e Curva de Ritmo:** Validar com mais testes se a pontuação e velocidade do Match-3 atendem bem tanto a públicos mais velhos quanto mais novos antes de realizar alterações drásticas.


7. 
**Impacto Visual de Progresso:** Adição de feedbacks estéticos graduais no cenário da fazenda à medida que o estoque de materiais cresce.