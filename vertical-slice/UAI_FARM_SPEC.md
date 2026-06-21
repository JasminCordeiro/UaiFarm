# Uai Farm — Especificação Técnica para Vertical Slice (Etapa 7)

> Documento de referência único para guiar o desenvolvimento do protótipo jogável em Godot Engine (GDScript). Este arquivo consolida o High Concept, a narrativa, as mecânicas e a fase da demo já validadas nas Etapas 3, 4 e 6 do projeto acadêmico CSI457 — Design de Jogos (UFOP).

## 0. Escopo desta etapa (Vertical Slice)

**Objetivo:** núcleo de gameplay jogável de ponta a ponta, sem arte final, sem áudio, sem narrativa completa. Apenas o verbo do jogo funcionando.

**Incluir:**
- Personagem-jogador controlável (placeholder: retângulo/sprite simples) que se move por clique no mapa
- Cenário-teste simples com 1 zona interativa clicável (Roçado)
- Puzzle Match-3 funcional standalone, acionado ao interagir com a zona
- Sistema de café (energia) com consumo e bloqueio de ação quando zerado
- Loop contínuo jogável por 30–60s sem travar

**NÃO incluir nesta etapa:**
- Menus, telas de pausa, configurações
- Arte final, áudio, música
- Curral, Paiol, NPCs, diálogos completos
- Sistema de save/load
- Múltiplos dias ou progressão de dificuldade

---

## 1. Engine e stack recomendados

- **Engine:** Godot 4.x
- **Linguagem:** GDScript
- **Navegação do personagem:** `NavigationAgent2D` + `NavigationRegion2D` para pathfinding por clique
- **Estrutura de cenas sugerida:**
  ```
  res://
    scenes/
      Overworld.tscn       # mapa principal com zonas clicáveis
      Player.tscn          # personagem controlável
      ZoneTrigger.tscn     # área clicável reutilizável (Roçado, Curral, Paiol)
      Match3Board.tscn     # puzzle standalone
      UI_HUD.tscn          # barra de café e contadores
    scripts/
      player_controller.gd
      zone_trigger.gd
      match3_board.gd
      game_state.gd        # singleton/autoload com café, recursos, dia
      hud.gd
    resources/
      tile_textures/
      piece_sprites/
  ```
- **Autoload obrigatório:** `GameState.gd` como singleton para persistir café, inventário e estado entre as cenas Overworld ↔ Match3Board sem perda de contexto.

---

## 2. Conceito do jogo (High Concept)

**Título:** Uai Farm
**Gênero:** Simulação de gestão rural 2D + puzzle Match-3
**Plataformas-alvo:** Web (browser) e Desktop (Windows/Linux)
**Faixa etária:** 12 a 45 anos
**Classificação:** Livre (ESRB E)

**Pitch:** Simulador de gestão de recursos rurais 2D que integra gerenciamento estratégico com sistemas de resolução de quebra-cabeças (Match-3). A aquisição de recursos e o progresso de construções são condicionados ao desempenho do jogador em puzzles lógicos.

**Diferenciais (USP):**
- Gamificação da espera: progresso ativo dependente de performance lógica, não de tempo passivo
- Baixa barreira de entrada: mecânicas intuitivas para sessões rápidas
- Temática regionalista: ambientação rural mineira (Brasil), evitando estereótipos negativos

**Referências e diferencial acadêmico:**
- *Stardew Valley* — estética rural e gestão, mas Uai Farm foca em puzzles em vez de simulação de tempo real
- *Candy Crush Saga* — core loop Match-3, mas os resultados são aplicados a um meta-jogo de construção

---

## 3. Narrativa (contexto para o vertical slice — usar só o essencial)

**Protagonista:** Caio Souza, 26 anos, ex-morador de Belo Horizonte que herda a Fazenda Uai de sua avó Dona Fiota, em Conselheiro Lafaiete, MG. Decide deixar a vida urbana para restaurar a propriedade.

**Tema central:** reconexão — entre o jovem e suas raízes, entre modernidade e tradição rural mineira.

**Para o vertical slice:** não é necessário implementar diálogos ou cutscenes. Apenas o gameplay puro do loop Roçado → Puzzle → Recompensa.

**NPCs (não implementar nesta etapa, apenas para contexto futuro):**
- Dona Fiota — avó/mentora, guia o jogador com balões de fala
- Zé do Pasto — vizinho pecuarista, gerencia a feira
- Ana Luz — agrônoma, desbloqueia upgrades sustentáveis

---

## 4. Modos de gameplay

### 4.1 Modo Gestão (Overworld)
- Visão 2D top-down/isométrica simplificada da fazenda
- Navegação por **point & click**: jogador clica em um ponto do mapa, o personagem (Caio) se desloca até lá via pathfinding
- Zonas interativas clicáveis: Roçado (ativo no vertical slice), Curral e Paiol (fora de escopo nesta etapa)
- Ao clicar em uma zona com o personagem adjacente, abre menu contextual com a ação disponível

### 4.2 Modo Desafio (Puzzle Match-3)
- Instanciado ao confirmar uma ação no menu contextual
- Tabuleiro **6×6** (escopo da fase inicial/tutorial)
- Modo por movimentos: limite de **20 movimentos**
- Meta de pontuação: **300 pontos**
- Peças temáticas (placeholder ok): espiga, balde, ferramenta (mínimo 3 tipos para permitir combos)
- Regras de match: troca de peças adjacentes (horizontal/vertical), elimina combos de 3+, peças caem para preencher espaços vazios

---

## 5. Tabela de mecânicas (especificação funcional completa)

| Mecânica | Input | Resposta do sistema | Condições | Feedback |
|---|---|---|---|---|
| Mover personagem | Clique no mapa | Caio se desloca até a coordenada clicada via pathfinding | Sempre disponível no Modo Gestão | Animação de caminhada; som de passos (placeholder: nenhum som no vertical slice) |
| Selecionar zona | Clique sobre zona interativa | Abre menu contextual com ações disponíveis | Caio deve estar adjacente à zona | Highlight da zona; ícone de menu aparece |
| Iniciar tarefa | Clique em ação no menu contextual | Instância de puzzle Match-3 é carregada | Jogador deve ter ao menos 1 unidade de café | Transição de tela; barra de café atualizada |
| Trocar peças (Match-3) | Clique em peça + clique em peça adjacente | Peças trocam de posição; combos de 3+ são eliminados | Só peças adjacentes (horizontal/vertical) | Animação de troca; partículas ao eliminar (placeholder ok) |
| Cumprir meta (movimentos) | Atingir pontuação-alvo dentro do limite de movimentos | Puzzle encerrado com sucesso; recursos creditados | Modo por movimentos ativo | Banner "UAI! Desafio Concluído!"; recurso aparece no inventário |
| Falhar puzzle | Automático ao esgotar movimentos sem atingir meta | Puzzle encerrado sem recompensa; energia de café consumida | Movimentos esgotados | Banner de falha; barra de café reduzida; nenhum recurso creditado |
| Tentar novamente | Clique em "Tentar Novamente" | Puzzle reiniciado com novo tabuleiro | Jogador deve ter café disponível | Barra de café reduzida mais 1 unidade; tabuleiro reembaralha |
| Gerenciar recursos | Clique no ícone de inventário | Abre tela de estoque (fora de escopo no vertical slice — pode ser apenas contador no HUD) | Sempre disponível | Painel/contador com valores |
| Descansar | Clique na casa + ação "Descansar" | Energia de café restaurada ao máximo | Sempre disponível (fora de escopo crítico — pode ser um botão de debug "Reset Café") | Barra de café cheia |

---

## 6. Sistema de energia (café) — regra central

- Energia inicial por sessão/dia: **5 unidades**
- Cada **tentativa** de puzzle (sucesso ou falha) consome **1 unidade de café**
- Quando café = 0, o jogador não pode iniciar novos puzzles
- No vertical slice, a única "saída" pode ser um botão de debug que restaura o café (a tela de Descanso completa fica para a Etapa 8/demo)
- Variável deve viver no singleton `GameState.gd` para persistir entre as cenas Overworld e Match3Board

```gdscript
# game_state.gd (autoload singleton)
extends Node

var cafe_atual: int = 5
var cafe_maximo: int = 5
var recursos: Dictionary = {
    "milho": 0,
    "madeira": 0,
    "leite": 0,
    "ovos": 0
}

func consumir_cafe() -> bool:
    if cafe_atual <= 0:
        return false
    cafe_atual -= 1
    return true

func restaurar_cafe() -> void:
    cafe_atual = cafe_maximo

func adicionar_recurso(tipo: String, quantidade: int) -> void:
    if recursos.has(tipo):
        recursos[tipo] += quantidade
```

---

## 7. Loop central (core gameplay loop)

1. **Explorar** — jogador clica no overworld, Caio se desloca
2. **Selecionar** — jogador clica na zona do Roçado (deve estar adjacente)
3. **Desafiar** — confirma ação no menu contextual, puzzle Match-3 é carregado (consome 1 café ao iniciar)
4. **Recompensar** — sucesso credita milho ao inventário; falha não credita nada
5. **Construir** *(fora de escopo no vertical slice)*
6. **Descansar** *(simplificado para botão de debug nesta etapa)*

Duração esperada de um ciclo: **3–8 minutos** em condições normais de jogo completo; no vertical slice, o foco é validar que **um ciclo isolado (passos 1–4) funciona sem travar por pelo menos 30–60 segundos contínuos**.

---

## 8. Condições de vitória/derrota (nível do puzzle — único necessário no vertical slice)

- **Vitória:** pontuação ≥ 300 dentro de 20 movimentos → credita +15 milho, fecha puzzle, retorna ao overworld
- **Derrota:** movimentos esgotados sem atingir 300 pontos → não credita recurso, consome 1 café, oferece "Tentar Novamente" (se café > 0) ou volta ao overworld
- **Sem game over global:** falhar não impede o jogador de continuar jogando — apenas o impede de iniciar puzzles quando o café chega a zero

---

## 9. Identidade visual (referência, não obrigatória no vertical slice)

> Aplicar somente se houver tempo. O vertical slice pode (e deve) usar formas geométricas simples como placeholder.

- **Paleta:** verdes (#2D5016, #4A7C2F, #A8D08D), terrosos/marrons (#8B5E3C), amarelos
- **Estilo-alvo (versões futuras):** pixel art 2D, referenciando arquitetura colonial mineira
- **Tom:** leve, acolhedor, otimista

---

## 10. Critérios de aceite do vertical slice (checklist Etapa 7)

- [ ] Personagem se move até o ponto clicado no mapa-teste (mesmo que seja um retângulo branco)
- [ ] Zona "Roçado" é clicável e abre estado de puzzle quando o personagem está perto
- [ ] Puzzle Match-3 funcional: troca peças, detecta combos de 3+, elimina e reposiciona
- [ ] Pontuação e contador de movimentos visíveis e funcionais
- [ ] Vitória (≥300 pts) e derrota (movimentos = 0) disparam corretamente
- [ ] Café é consumido a cada tentativa e bloqueia novas tentativas ao chegar a 0
- [ ] Loop pode ser jogado repetidamente por 30–60s sem crash
- [ ] Build exportável (web ou executável) e testável fora do editor

---

## 11. Notas para o Claude Code

- Priorize **fazer funcionar** antes de polir. Placeholders (ColorRect, formas geométricas) são aceitáveis para personagem, peças e cenário.
- O Match-3 é o componente de maior risco técnico — se possível, prototipá-lo primeiro e isoladamente em uma cena própria (`Match3Board.tscn`) antes de integrar à navegação do overworld.
- Use sinais (`signal`) do Godot para comunicar eventos entre cenas (ex: `puzzle_concluido(recurso, quantidade)`, `puzzle_falhou()`) em vez de acoplamento direto entre nós.
- Comente o código em português ou inglês, mas mantenha nomes de variáveis consistentes com os termos já usados neste documento (`cafe`, `recursos`, `roçado` → preferir `rocado` sem cedilha para evitar problemas de encoding em nomes de arquivo/variável).
- Não implemente sistema de save — fora de escopo nesta etapa.
