extends Node2D

func _ready() -> void:
	if GameState.ponto_spawn != Vector2(-1, -1):
		var player: Node2D = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = GameState.ponto_spawn
		GameState.ponto_spawn = Vector2(-1, -1)
