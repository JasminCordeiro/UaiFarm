extends Node2D

@onready var ambiente_principal: Sprite2D = $Principal
@onready var nav_principal: NavigationRegion2D = $"Principal/Acesso Principal - Casa"
@onready var ambiente_curral: Sprite2D = $"Curral-Desbloqueado"
@onready var nav_curral: NavigationRegion2D = $"Curral-Desbloqueado/Curra-Desbloqueado-Navigation"
@onready var ambiente_paiol: Sprite2D = $"Curral e Paiol-Desbloqueado"
@onready var nav_paiol: NavigationRegion2D = $"Curral e Paiol-Desbloqueado/Paiol-Desbloqueado-Navigation"

func _ready() -> void:
	GameState.recurso_alterado.connect(_on_recurso_alterado)
	_atualizar_ambiente()
	if GameState.ponto_spawn != Vector2(-1, -1):
		var player: Node2D = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = GameState.ponto_spawn
		GameState.ponto_spawn = Vector2(-1, -1)

func _on_recurso_alterado(_tipo: String, _total: int) -> void:
	_atualizar_ambiente()

func _atualizar_ambiente() -> void:
	var paiol_aberto: bool = GameState.zona_desbloqueada("Paiol")
	var curral_aberto: bool = GameState.zona_desbloqueada("Curral")

	ambiente_paiol.visible = paiol_aberto
	nav_paiol.enabled = paiol_aberto

	ambiente_curral.visible = curral_aberto and not paiol_aberto
	nav_curral.enabled = curral_aberto and not paiol_aberto

	ambiente_principal.visible = not curral_aberto and not paiol_aberto
	nav_principal.enabled = not curral_aberto and not paiol_aberto
