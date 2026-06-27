extends Control

func _ready() -> void:
	$Panel/VBoxContainer/NewGameButton.pressed.connect(_on_new_game)
	$Panel/VBoxContainer/QuitButton.pressed.connect(_on_quit)

func _on_new_game() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/Overworld.tscn")

func _on_quit() -> void:
	get_tree().quit()
