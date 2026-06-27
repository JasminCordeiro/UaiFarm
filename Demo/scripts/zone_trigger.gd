extends Area2D

signal acao_confirmada(zone_name: String)

@export var zone_name: String = "Rocado"
@export var action_label: String = "Trabalhar"
@export var adjacency_radius: float = 90.0
@export var match3_scene: PackedScene
@export var puzzle_reward_type: String = "milho"
@export var puzzle_reward_amount: int = 15
@export var puzzle_move_limit: int = 20
@export var puzzle_score_target: int = 300

@onready var context_menu: Control = $ContextMenu
@onready var action_button: Button = $ContextMenu/ActionButton
@onready var visual: ColorRect = $Visual
@onready var radius_indicator = $RadiusIndicator
@onready var name_label: Label = $Label
@onready var status_label: Label = $StatusLabel

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
	name_label.text = zone_name
	GameState.recurso_alterado.connect(_on_recurso_alterado)
	_atualizar_visual_bloqueio()
	_atualizar_status()

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

func _atualizar_visual_bloqueio() -> void:
	var bloqueada: bool = not GameState.zona_desbloqueada(zone_name)
	visual.color = Color(0.4, 0.4, 0.4, 1) if bloqueada else Color(0.545, 0.369, 0.235, 1)
	status_label.modulate = Color(1, 0.75, 0.35) if bloqueada else Color(0.85, 1, 0.85)
	_atualizar_status()

func _atualizar_status() -> void:
	if GameState.zona_desbloqueada(zone_name):
		status_label.text = action_label
	else:
		status_label.text = "Bloqueado"

func _on_recurso_alterado(_tipo: String, _qtd: int) -> void:
	_atualizar_visual_bloqueio()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_open_menu()

func _try_open_menu() -> void:
	if puzzle_instance != null:
		return
	if not jogador_proximo:
		context_menu.hide()
		return
	if not GameState.zona_desbloqueada(zone_name):
		var info_bar = get_tree().get_first_node_in_group("info_bar")
		if info_bar:
			info_bar.mostrar_mensagem("Zona bloqueada", "%s: %s" % [zone_name, GameState.texto_requisito(zone_name)])
		return
	action_button.text = action_label
	action_button.disabled = false
	context_menu.show()

func _on_action_button_pressed() -> void:
	if not GameState.zona_desbloqueada(zone_name):
		return
	if GameState.cafe_atual < 1:
		action_button.text = "Sem cafe!"
		action_button.disabled = true
		return
	context_menu.hide()
	if player_ref:
		player_ref.bloquear_movimento()
	puzzle_instance = match3_scene.instantiate()
	puzzle_instance.win_reward_type = puzzle_reward_type
	puzzle_instance.win_reward_amount = puzzle_reward_amount
	puzzle_instance.move_limit = puzzle_move_limit
	puzzle_instance.score_target = puzzle_score_target
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
