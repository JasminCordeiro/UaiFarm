extends Area2D

signal acao_confirmada(zone_name: String)

@export var zone_name: String = "Rocado"
@export var adjacency_radius: float = 90.0
@export var match3_scene: PackedScene

@onready var context_menu: Control = $ContextMenu
@onready var action_button: Button = $ContextMenu/ActionButton
@onready var visual: ColorRect = $Visual
@onready var radius_indicator = $RadiusIndicator

var player_ref: Node2D = null
var puzzle_instance: Node = null
var jogador_proximo: bool = false

func _ready() -> void:
	input_event.connect(_on_input_event)
	action_button.pressed.connect(_on_action_button_pressed)
	context_menu.hide()
	player_ref = get_tree().get_first_node_in_group("player")
	radius_indicator.definir_raio(adjacency_radius)
	_atualizar_proximidade(false)

func _process(_delta: float) -> void:
	if puzzle_instance != null:
		return
	if player_ref == null:
		player_ref = get_tree().get_first_node_in_group("player")
		return
	var perto: bool = global_position.distance_to(player_ref.global_position) <= adjacency_radius
	if perto != jogador_proximo:
		_atualizar_proximidade(perto)
		if not perto:
			context_menu.hide()

func _atualizar_proximidade(perto: bool) -> void:
	jogador_proximo = perto
	visual.modulate = Color(1.2, 1.2, 1.2) if perto else Color(1, 1, 1)
	radius_indicator.modulate.a = 0.9 if perto else 0.3

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_open_menu()

func _try_open_menu() -> void:
	if puzzle_instance != null:
		return
	if jogador_proximo:
		action_button.text = "Plantar"
		action_button.disabled = false
		context_menu.show()
	else:
		context_menu.hide()

func _on_action_button_pressed() -> void:
	if GameState.cafe_atual < 1:
		action_button.text = "Sem cafe!"
		action_button.disabled = true
		return
	context_menu.hide()
	if player_ref:
		player_ref.bloquear_movimento()
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
	if player_ref:
		player_ref.liberar_movimento()
