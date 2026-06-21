extends Area2D

signal acao_confirmada(zone_name: String)

@export var zone_name: String = "Rocado"
@export var adjacency_radius: float = 90.0
@export var match3_scene: PackedScene

@onready var context_menu: Control = $ContextMenu
@onready var action_button: Button = $ContextMenu/ActionButton
@onready var visual: ColorRect = $Visual

var player_ref: Node2D = null
var puzzle_instance: Node = null

func _ready() -> void:
	input_event.connect(_on_input_event)
	action_button.pressed.connect(_on_action_button_pressed)
	context_menu.hide()
	player_ref = get_tree().get_first_node_in_group("player")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_open_menu()

func _try_open_menu() -> void:
	if puzzle_instance != null:
		return
	if player_ref == null:
		player_ref = get_tree().get_first_node_in_group("player")
		if player_ref == null:
			return
	if global_position.distance_to(player_ref.global_position) <= adjacency_radius:
		action_button.text = "Plantar"
		action_button.disabled = false
		context_menu.show()
		visual.modulate = Color(1.2, 1.2, 1.2)
	else:
		context_menu.hide()
		visual.modulate = Color(1, 1, 1)

func _on_action_button_pressed() -> void:
	if GameState.cafe_atual < 1:
		action_button.text = "Sem cafe!"
		action_button.disabled = true
		return
	context_menu.hide()
	visual.modulate = Color(1, 1, 1)
	puzzle_instance = match3_scene.instantiate()
	get_tree().current_scene.add_child(puzzle_instance)
	puzzle_instance.puzzle_concluido.connect(_on_puzzle_concluido)
	puzzle_instance.puzzle_falhou.connect(_on_puzzle_falhou)
	acao_confirmada.emit(zone_name)

func _on_puzzle_concluido(_recurso: String, _quantidade: int) -> void:
	_fechar_puzzle()

func _on_puzzle_falhou() -> void:
	_fechar_puzzle()

func _fechar_puzzle() -> void:
	if puzzle_instance:
		puzzle_instance.queue_free()
		puzzle_instance = null
