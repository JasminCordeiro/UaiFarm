extends CanvasLayer

const MAIN_MENU := "res://scenes/MainMenu.tscn"

var show_game_actions: bool = false

@onready var music_button: Button = $Center/PanelContainer/Margin/VBoxContainer/MusicRow/MusicButton
@onready var sfx_button: Button = $Center/PanelContainer/Margin/VBoxContainer/SfxRow/SfxButton
@onready var game_actions: VBoxContainer = $Center/PanelContainer/Margin/VBoxContainer/GameActions
@onready var return_menu_button: Button = $Center/PanelContainer/Margin/VBoxContainer/GameActions/ReturnMenuButton
@onready var quit_button: Button = $Center/PanelContainer/Margin/VBoxContainer/GameActions/QuitButton
@onready var close_button: Button = $Center/PanelContainer/Margin/VBoxContainer/CloseButton
@onready var dim: ColorRect = $Dim

func _ready() -> void:
	music_button.pressed.connect(_on_music_pressed)
	sfx_button.pressed.connect(_on_sfx_pressed)
	return_menu_button.pressed.connect(_on_return_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_button.pressed.connect(_on_close_pressed)
	dim.gui_input.connect(_on_dim_input)
	game_actions.visible = show_game_actions
	close_button.text = "Continuar Jogando" if show_game_actions else "Fechar"
	_refresh_buttons()

func _refresh_buttons() -> void:
	music_button.text = "Desligada" if AudioSettings.music_muted else "Ligada"
	sfx_button.text = "Desligados" if AudioSettings.sfx_muted else "Ligados"

func _on_music_pressed() -> void:
	AudioSettings.toggle_music()
	_refresh_buttons()

func _on_sfx_pressed() -> void:
	AudioSettings.toggle_sfx()
	_refresh_buttons()

func _on_return_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_close_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_dim_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
			or (event is InputEventScreenTouch and event.pressed):
		get_tree().paused = false
		queue_free()
