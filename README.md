# Uai Farm

Simulador de gestão de recursos rurais 2D que integra gerenciamento estratégico com puzzles Match-3: a aquisição de recursos e o progresso de construções são condicionados ao desempenho do jogador nos quebra-cabeças. Ambientação rural mineira (Conselheiro Lafaiete, MG).

Projeto acadêmico da disciplina **CSI457 — Design de Jogos (UFOP)**.

## Status

**Etapa 7 — Vertical Slice.** Núcleo de gameplay jogável de ponta a ponta (sem arte final, sem áudio, sem narrativa completa): personagem controlável por clique, uma zona interativa ("Roçado"), puzzle Match-3 funcional, sistema de energia (café). Detalhes completos da especificação em [`vertical-slice/UAI_FARM_SPEC.md`](vertical-slice/UAI_FARM_SPEC.md).

## Como abrir o projeto

1. Instale o [Godot Engine 4.7](https://godotengine.org/download) (versão estável).
2. Abra o Godot, clique em **Import** e selecione `vertical-slice/project.godot`.
3. Pressione **F5** para rodar o projeto (cena principal: `Overworld.tscn`).

## Como jogar (vertical slice)

- Clique no mapa para o personagem (Caio) andar até o ponto clicado.
- Ande até perto da zona marrom "Roçado" e clique nela para abrir o menu de ação.
- Confirme a ação ("Plantar") para abrir o puzzle Match-3 (consome 1 unidade de café).
- Troque peças adjacentes para formar combos de 3+; atinja 300 pontos em até 20 movimentos para vencer e ganhar milho.
- O café é limitado (5 unidades por sessão); quando chega a 0, novas tentativas são bloqueadas até usar o botão de debug "Reset Cafe" no HUD.

## Estrutura do repositório

```
UaiFarm/
├── vertical-slice/        # projeto Godot da Etapa 7
│   ├── project.godot
│   ├── UAI_FARM_SPEC.md   # especificacao tecnica completa
│   ├── scenes/
│   └── scripts/
├── .gitignore
└── README.md
```

## Stack técnica

- **Engine:** Godot 4.7
- **Linguagem:** GDScript
- **Navegação:** `NavigationAgent2D` + `NavigationRegion2D` (pathfinding por clique)
- **Estado persistente:** singleton `GameState` (autoload) para café e inventário entre cenas
