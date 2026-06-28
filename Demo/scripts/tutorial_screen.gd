extends Control

func _ready() -> void:
	$Panel/VBoxContainer/ButtonsRow/BackButton.pressed.connect(_on_back_pressed)
	$Panel/VBoxContainer/ButtonsRow/NewGameButton.pressed.connect(_on_new_game_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_new_game_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/Overworld.tscn")
