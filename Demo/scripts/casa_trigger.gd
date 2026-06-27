extends Area2D

const ADJACENCY_RADIUS: float = 90.0

@onready var context_menu: Control = $ContextMenu
@onready var action_button: Button = $ContextMenu/ActionButton
@onready var visual: ColorRect = $Visual
@onready var status_label: Label = $StatusLabel

var player_ref: Node2D = null
var jogador_proximo: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	input_event.connect(_on_input_event)
	action_button.pressed.connect(_on_action_button_pressed)
	context_menu.hide()
	player_ref = get_tree().get_first_node_in_group("player")
	status_label.text = "Clique para descansar"

func _process(_delta: float) -> void:
	if player_ref == null:
		player_ref = get_tree().get_first_node_in_group("player")
		return
	var perto: bool = global_position.distance_to(player_ref.global_position) <= ADJACENCY_RADIUS
	if perto != jogador_proximo:
		jogador_proximo = perto
		visual.modulate = Color(1.2, 1.2, 1.2) if perto else Color(1, 1, 1)
		status_label.modulate = Color(1, 1, 1) if perto else Color(0.8, 0.8, 0.8)
		if not perto:
			context_menu.hide()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if jogador_proximo:
			action_button.text = "Descansar"
			action_button.disabled = false
			context_menu.show()
		else:
			context_menu.hide()

func _on_action_button_pressed() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	context_menu.hide()
	get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")
