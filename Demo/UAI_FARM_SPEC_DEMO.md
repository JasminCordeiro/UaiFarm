# Uai Farm — Especificação Técnica para a Demo (Etapa 8)

> Documento de referência para expandir o Vertical Slice (Etapa 7) em uma demo jogável de ponta a ponta. Este arquivo assume que `UAI_FARM_SPEC.md` (Etapa 7) já existe e foi implementado — não repete o que já está lá, apenas especifica o que muda/expande.

## 0. Contexto e regra de ouro

O Vertical Slice já entrega o core loop funcionando (Roçado + puzzle Match-3 + café + HUD). **Esta etapa não é recomeçar — é expandir.** Cada commit deve manter o jogo jogável; nunca quebrar o que já funciona para adicionar o que falta.

**Regra de versionamento:** o Vertical Slice **não é tocado**. Toda a expansão da demo acontece em uma pasta nova `Demo/` na raiz do repositório, irmã de `vertical-slice/`, não dentro dela. Isso preserva o histórico e o estado do vertical slice intacto como entrega da Etapa 7.

```
UaiFarm/
├── vertical-slice/        ← Etapa 7 (não tocar)
├── Demo/                  ← Etapa 8 (todo o trabalho novo aqui)
│   ├── scenes/
│   ├── scripts/
│   ├── project.godot
│   └── UAI_FARM_SPEC_DEMO.md
├── docs/
└── README.md
```

A `Demo/` parte como uma **cópia** do projeto Godot do vertical slice (mesmo `GameState.gd`, `Match3Board.tscn`, `Player.tscn`, etc. como ponto de partida), e evolui a partir daí. Não é reescrita do zero.

---

## 1. Escopo da demo (o que precisa existir ao final)

Direto dos critérios obrigatórios do roteiro da Etapa 8:

- [ ] Classificação indicativa exibida (ESRB E / Livre — já definida no High Concept, só precisa aparecer na tela inicial ou créditos)
- [ ] Tela inicial e menu
- [ ] Pelo menos uma fase jogável **integralmente** — neste caso, as 3 zonas (Roçado, Curral, Paiol) funcionais, não mockadas
- [ ] Condições de vitória e derrota funcionais (já existem no nível do puzzle; precisa adicionar a condição de vitória/derrota do "dia"/sessão)
- [ ] Tela de fim (vitória e/ou derrota do dia)
- [ ] Controles funcionais e documentados (ficará no LEIAME, fora do escopo deste arquivo)
- [ ] Tutorial implícito (balão de fala da Dona Fiota já planejado na narrativa — agora implementado de fato)
- [ ] Estável para um avaliador externo jogar sem assistência

---

## 2. Zonas — Curral e Paiol (de mockado para funcional)

Ambos seguem exatamente o mesmo padrão do Roçado, reutilizando `ZoneTrigger.tscn` e `Match3Board.tscn` (já desenhados para serem reutilizáveis via `@export match3_scene`).

### 2.1 Curral
- Ação: "Ordenhar vacas" / "Cuidar dos animais"
- Recurso gerado: `leite` e/ou `ovos`
- Parâmetros sugeridos de puzzle: tabuleiro 6×6, 20 movimentos, meta 300 pontos (mesmo baseline do Roçado nesta fase — balanceamento fino fica para depois do playtest amplo)
- Peças temáticas: balde de leite, ovo, ferradura (placeholder de cor ok se a arte não estiver pronta ainda)

### 2.2 Paiol
- Ação: "Organizar estoque" / "Processar produção"
- Recurso gerado: `madeira` e/ou consolidação dos recursos já coletados (ex.: o Paiol pode ser o local que desbloqueia upgrades de estrutura — decisão de design a confirmar com a dupla, mas tecnicamente segue o mesmo padrão de puzzle)
- Mesmos parâmetros de puzzle do Curral nesta fase inicial

### 2.3 Desbloqueio
Seguindo o que já está documentado na Etapa 6 (curva de dificuldade): Curral e Paiol ficam **bloqueados no início** e desbloqueiam conforme recursos do Roçado são acumulados (ex.: Curral desbloqueia com X milho coletado). Use os mesmos valores de exemplo já citados nos relatórios anteriores (ex.: "20 madeira, 10 milho" mencionado no mapa da demo da Etapa 6) como placeholder de balanceamento — pode ajustar depois.

**Importante:** isso substitui o comportamento mockado atual (que só mostrava "requisitos de desbloqueio" sem ação real). Agora o desbloqueio precisa funcionar de fato: ao atingir o requisito, a zona deixa de estar bloqueada e o puzzle correspondente passa a ser jogável.

---

## 3. Tela de Descansar (substituindo o botão de debug "Reset Café")

Vira uma **tela completa**, não mais um botão de debug. Especificação:

- Acionada ao clicar na Casa de Caio + confirmar ação "Descansar" (fluxo já documentado desde a Etapa 6)
- Tela de transição simples: pode ser um fade to black/dark com texto centralizado (ex.: "Dia X concluído..." → "Dia X+1") — não precisa ser elaborada visualmente nesta fase, mas precisa **substituir conceitualmente** o botão de debug
- Ao confirmar: café restaurado ao máximo, contador de dia incrementado, retorno ao Overworld
- Pode (e deve) incluir uma linha de diálogo curta da Dona Fiota mudando por dia, mesmo que de um pool pequeno de frases fixas (não precisa sistema de diálogo complexo) — reforça a continuidade narrativa sem exigir nova arquitetura

**Nota de design:** o botão de debug pode continuar existindo *escondido* (ex.: atalho de teclado em modo debug) para facilitar testes internos, mas não deve ser a forma "oficial" de descansar que o avaliador externo vê.

---

## 4. Tutorial implícito (Dona Fiota)

Já está 100% especificado na narrativa (Etapas 4 e 6) — falta só implementar:

- Balão de fala simples (Panel/Label, sem necessidade de sistema de diálogo complexo) aparece na primeira vez que o jogador entra no Overworld
- Texto: variação de "Uai, meu filho! O roçado tá precisando de cuidado. Clica nele pra começar!" (já validado nos relatórios anteriores)
- Desaparece após o jogador iniciar o primeiro puzzle do Roçado, ou após N segundos / clique do jogador para fechar
- Não precisa ramificar em diálogo condicional — é um pop-up contextual único no fluxo inicial

---

## 5. Telas novas obrigatórias

### 5.1 Tela Inicial / Menu
- Logo/título "Uai Farm" (placeholder textual é aceitável se a arte final não estiver pronta)
- Botão "Novo Jogo" → inicia o Overworld no estado inicial (Dia 1, café = 5, recursos zerados)
- Botão "Sair" (ou equivalente — sem necessidade de "Continuar"/save nesta fase, já que save está fora de escopo)
- Exibir a classificação indicativa (texto simples: "Livre / ESRB E" já resolve o critério obrigatório)

### 5.2 Tela de Fim (Vitória/Derrota do dia ou da demo)
Como o jogo não tem "game over" global (decisão de design já documentada e mantida), a "tela de fim" da demo pode ser interpretada como:
- Uma tela de **encerramento da sessão de demo** (ex.: ao completar X dias, ou ao fechar manualmente) mostrando um resumo: recursos totais coletados, dias jogados, zonas desbloqueadas
- Não precisa ser um "fim" narrativo definitivo (isso é o objetivo de longo prazo do jogo completo, fora de escopo da demo) — é só uma tela de encerramento informativa para o avaliador saber que a demo "terminou" de forma clara
- Botão para voltar à Tela Inicial

---

## 6. Fluxo completo atualizado (telas)

Expandindo o fluxograma já existente da Etapa 6/7:

```
Tela Inicial → [Novo Jogo] → Overworld (com tutorial Dona Fiota na 1ª vez)
Overworld → [clica zona desbloqueada] → Menu Contextual → Match3Board → Vitória/Derrota → volta ao Overworld
Overworld → [clica zona bloqueada] → feedback de requisito não atendido (sem abrir puzzle)
Overworld → [clica Casa] → Tela de Descansar → volta ao Overworld (dia +1, café restaurado)
Overworld → [encerrar demo manualmente ou critério definido] → Tela de Fim → volta à Tela Inicial
```

---

## 7. Plano de commits sugerido (em fases, não tudo de uma vez)

Seguindo a lógica que você definiu — esqueleto funcional primeiro, polish depois:

### Fase A — Esqueleto de fluxo (sem arte nova, só placeholders/cores)
1. Setup da pasta `Demo/` copiando a base do vertical slice
2. Tela Inicial / Menu (placeholder visual) + transição para Overworld
3. Curral funcional (reuso de ZoneTrigger + Match3Board, novo tipo de recurso)
4. Paiol funcional (idem)
5. Lógica de desbloqueio de zonas (bloqueada → desbloqueada por recurso acumulado)
6. Tela de Descansar completa (substituindo botão de debug) + contador de dia
7. Balão de tutorial da Dona Fiota na primeira entrada no Overworld
8. Tela de Fim / encerramento de sessão com resumo

### Fase B — Polish (após Fase A estar jogável de ponta a ponta)
9. Substituição de placeholders por assets visuais (sprites do Caio, NPCs, tiles de fundo) — **pendente de definição com a dupla**, código deve continuar funcionando com placeholder até lá
10. Efeitos sonoros (cliques, vitória, derrota, ambientais) — **pendente de definição com a dupla**
11. Eventual música de fundo — **pendente de definição com a dupla**
12. Ajustes de balanceamento pós-playtest amplo (Passo 4 do roteiro da Etapa 8)

> Itens 9–11 não devem bloquear o avanço da Fase A. O código deve ser estruturado para aceitar troca de assets (sprites, sons) sem refatoração — ex.: manter referências a texturas/áudio centralizadas e fáceis de substituir.

---

## 8. O que explicitamente NÃO faz parte desta etapa ainda

- Sistema de save/load (fora de escopo, igual ao vertical slice)
- NPCs com diálogo ramificado complexo (Zé do Pasto, Ana Luz) — podem ser adicionados como decoração/placeholder visual no mapa, mas lógica de missão deles é trabalho futuro além da demo, a menos que vocês decidam priorizar
- Múltiplos dias com curva de dificuldade progressiva completa (Fase intermediária/avançada da Etapa 6) — a demo pode ficar na "fase inicial" de dificuldade; progressão de dificuldade ao longo de muitos dias é trabalho futuro
- Reabertura da feira local / vitória macro (objetivo narrativo de longo prazo, não cabe no escopo de uma demo)

---

## 9. Pendências que dependem de decisão com a dupla (não travam o código)

- Definição final de áudio (efeitos + possível música) — código deve ser estruturado para receber isso depois sem refatoração grande
- Assets visuais finais (Caio, Dona Fiota, Zé do Pasto, Ana Luz, tiles de cenário) — já existem alguns concepts gerados em etapas anteriores; integração formal fica para quando o grupo decidir
- Balanceamento fino dos puzzles do Curral/Paiol (valores de movimentos/meta podem mudar após playtest amplo)
- Decisão de design sobre o papel exato do Paiol (estoque puro vs. desbloqueio de upgrades) — implementação técnica é a mesma (puzzle + recurso), mutável depois

---

## 10. Notas para o Claude Code

- Reaproveite ao máximo o código do vertical slice — `GameState.gd`, `ZoneTrigger.gd`, `Match3Board.gd`, `player_controller.gd` já são genéricos o suficiente para Curral/Paiol sem reescrita.
- Sinais (`puzzle_concluido`, `puzzle_falhou`) e o padrão de singleton continuam sendo a forma de comunicação entre cenas — não introduza acoplamento direto.
- Para a Tela de Descansar e Tela de Fim, prefira soluções simples (CanvasLayer + Panel + Label + botões) — sem necessidade de tweens elaborados ou transições complexas nesta fase.
- Centralize valores de balanceamento (metas de pontuação, movimentos, requisitos de desbloqueio) em constantes fáceis de encontrar e editar — eles vão mudar depois do playtest amplo.
- Comente no diário técnico (mesma prática da Etapa 7) qualquer decisão técnica não-trivial tomada durante a expansão — vai alimentar o post-mortem do relatório final.
- Como nos commits anteriores, prepare os arquivos e me dê os comandos `git` para eu rodar localmente — não execute commits diretamente.
