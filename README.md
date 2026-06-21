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

1. Acesse a aba de releases do projeto: [v0.1.0-vertical-slice](https://github.com/JasminCordeiro/UaiFarm/releases/tag/v0.1.0-vertical-slice)
2. Baixe o arquivo `Uai-Farm-vertical-slice-windows.zip`, como na imagem abaixo:

   <img width="1119" height="453" alt="Pagina de releases do GitHub com o asset Uai-Farm-vertical-slice-windows.zip em destaque" src="https://github.com/user-attachments/assets/babeff28-287a-4d85-9aa2-3134b30ff4a6" />

3. Extraia o `.zip` e execute o arquivo `Uai-Farm.exe`.
4. Clique no mapa para o personagem (Caio) andar até o ponto clicado.
5. Ande até perto da zona marrom "Roçado" e clique nela para abrir o menu de ação.
6. Confirme a ação ("Plantar") para abrir o puzzle Match-3 (consome 1 unidade de café).
7. Troque peças adjacentes para formar combos de 3+; atinja 300 pontos em até 20 movimentos para vencer e ganhar milho.
8. O café é limitado (5 unidades por sessão); quando chega a 0, novas tentativas são bloqueadas até usar o botão de debug "Reset Café" no HUD.

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
