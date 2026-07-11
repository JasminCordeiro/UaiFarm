extends Control

const SETTINGS_PANEL: PackedScene = preload("res://scenes/SettingsPanel.tscn")

func _ready() -> void:
	$Panel/VBoxContainer/NewGameButton.pressed.connect(_on_new_game)
	$Panel/VBoxContainer/TutorialButton.pressed.connect(_on_tutorial)
	$Panel/VBoxContainer/QuitButton.pressed.connect(_on_quit)
	$SettingsButton.pressed.connect(_on_settings_pressed)

func _on_new_game() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/StoryIntro.tscn")

func _on_tutorial() -> void:
	get_tree().change_scene_to_file("res://scenes/TutorialScreen.tscn")

func _on_quit() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	add_child(SETTINGS_PANEL.instantiate())
