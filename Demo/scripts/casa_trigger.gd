extends Area2D

const ADJACENCY_RADIUS: float = 140.0
const TEXTURAS_CASA: Array = [
	"res://assets/casa-1.png",
	"res://assets/casa-2.png",
	"res://assets/casa-3.png",
]
# Escala independente por nivel (indice 0 = casa nivel 1, etc.) — ajuste aqui pra mudar
# o tamanho de um nivel especifico sem afetar os outros
const ESCALAS_CASA: Array = [1.1, 1.1, 1.1]

@onready var context_menu: Control = $ContextMenu
@onready var action_button: Button = $ContextMenu/ActionButton
@onready var upgrade_button: Button = $ContextMenu/UpgradeButton
@onready var casa_sprite: Sprite2D = $CasaSprite
@onready var status_label: Label = $StatusLabel

var player_ref: Node2D = null
var jogador_proximo: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	input_event.connect(_on_input_event)
	action_button.pressed.connect(_on_action_button_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	GameState.casa_melhorada.connect(_on_casa_melhorada)
	context_menu.hide()
	player_ref = get_tree().get_first_node_in_group("player")
	status_label.text = "Clique para descansar"
	_atualizar_sprite()

func _process(_delta: float) -> void:
	if player_ref == null:
		player_ref = get_tree().get_first_node_in_group("player")
		return
	var perto: bool = global_position.distance_to(player_ref.global_position) <= ADJACENCY_RADIUS
	if perto != jogador_proximo:
		jogador_proximo = perto
		status_label.modulate = Color(1, 1, 1) if perto else Color(0.8, 0.8, 0.8)
		if not perto:
			context_menu.hide()
			var info_bar = get_tree().get_first_node_in_group("info_bar")
			if info_bar:
				info_bar.fechar_por_distancia()

func _atualizar_sprite() -> void:
	var idx: int = clampi(GameState.nivel_casa - 1, 0, TEXTURAS_CASA.size() - 1)
	casa_sprite.texture = load(TEXTURAS_CASA[idx])
	var escala: float = ESCALAS_CASA[idx]
	casa_sprite.scale = Vector2(escala, escala)

func _on_casa_melhorada(nivel: int) -> void:
	_atualizar_sprite()
	var info_bar = get_tree().get_first_node_in_group("info_bar")
	if info_bar:
		info_bar.mostrar_mensagem("Dona Fiota", "Uai, que capricho! A casa subiu pro nível %d!" % nivel)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if jogador_proximo:
			_abrir_menu()
		else:
			context_menu.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interagir"):
		return
	if not jogador_proximo or is_transitioning:
		return
	if player_ref and player_ref.movimento_bloqueado:
		return
	get_viewport().set_input_as_handled()
	if context_menu.visible:
		_on_action_button_pressed()
	else:
		_abrir_menu()

func _abrir_menu() -> void:
	var info_bar = get_tree().get_first_node_in_group("info_bar")
	if info_bar:
		info_bar.fechar_para_nova_acao()
	action_button.text = "Descansar"
	action_button.disabled = false
	if GameState.nivel_casa >= GameState.NIVEL_CASA_MAXIMO:
		upgrade_button.text = "Nível máximo"
		upgrade_button.disabled = true
	else:
		upgrade_button.text = "Melhorar (Nv %d)" % (GameState.nivel_casa + 1)
		upgrade_button.disabled = false
	context_menu.show()

func _on_action_button_pressed() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	context_menu.hide()
	get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")

func _on_upgrade_button_pressed() -> void:
	if GameState.melhorar_casa():
		context_menu.hide()
	else:
		var info_bar = get_tree().get_first_node_in_group("info_bar")
		if info_bar:
			info_bar.mostrar_mensagem("Dona Fiota", "Pra melhorar a casa precisa de: %s. Ainda falta coisa, uai!" % GameState.texto_custo_casa())
