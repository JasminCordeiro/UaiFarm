extends Area2D

signal acao_confirmada(zone_name: String)

const FALAS_VITORIA: Array[String] = [
	"Uai, que serviço bonito! Tá pegando o jeito da roça, só!",
	"Ocê trabaia que é uma beleza, Caio! Continua assim!",
	"Trem bão demais! Seu avô ia ficar orgulhoso, uai!",
	"Capricho puro! A fazenda tá voltando à vida, fio!",
]

const FALAS_DERROTA: Array[String] = [
	"Ihh, não deu dessa vez... Mas desanima não, uai! Toma um golinho de café e tenta de novo.",
	"A roça ensina errando também, fio. Bola pra frente!",
	"Nem todo dia a lida rende. Amanhã cê acerta, pode cre!",
]

@export var zone_name: String = "Roçado"
@export var action_label: String = "Trabalhar"
@export var adjacency_radius: float = 90.0
@export var match3_scene: PackedScene
@export var puzzle_reward_type: String = "milho"
@export var puzzle_reward_amount: int = 15
@export var puzzle_move_limit: int = 20
@export var puzzle_score_target: int = 300
@export var puzzle_tema: String = "rocado"
@export var plantar_apos_vitoria: bool = false
@export var cena_plantacao: PackedScene
@export var plantas_por_vitoria: int = 5
@export var tempo_crescimento: float = 10.0
# Ajuste fino pra afastar o menu de partes do cenário (ex.: o telhado do Celeiro)
@export var deslocamento_menu: Vector2 = Vector2.ZERO

# Posições alinhadas aos dois canteiros de terra do Roçado (background):
# os dois canteiros tem 2 fileiras x 4 plantas cada, em linha reta (sem jitter)
const DESLOCAMENTOS_PLANTIO: Array = [
	Vector2(-76, -65), Vector2(-36, -65), Vector2(4, -65), Vector2(44, -65),
	Vector2(-76, -35), Vector2(-36, -35), Vector2(4, -35), Vector2(44, -35),
	Vector2(-76, 43), Vector2(-36, 43), Vector2(4, 43), Vector2(44, 43),
	Vector2(-76, 73), Vector2(-36, 73), Vector2(4, 73), Vector2(44, 73),
]

@onready var context_menu: Control = $ContextMenu
@onready var action_button: Button = $ContextMenu/VBox/ActionButton
@onready var upgrade_button: Button = $ContextMenu/VBox/UpgradeButton
@onready var radius_indicator = $RadiusIndicator
@onready var name_label: Label = $Label
@onready var status_label: Label = $StatusLabel

var player_ref: Node2D = null
var puzzle_instance: Node = null
var jogador_proximo: bool = false
var modo_desbloqueio: bool = false
var plantacoes: Array = []

func _ready() -> void:
	input_event.connect(_on_input_event)
	action_button.pressed.connect(_on_action_button_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	context_menu.hide()
	player_ref = get_tree().get_first_node_in_group("player")
	radius_indicator.definir_raio(adjacency_radius)
	_atualizar_proximidade(false)
	name_label.text = zone_name
	GameState.recurso_alterado.connect(_on_recurso_alterado)
	_atualizar_visual_bloqueio()
	_atualizar_status()

func _process(_delta: float) -> void:
	_atualizar_status_plantio()
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
			var info_bar = get_tree().get_first_node_in_group("info_bar")
			if info_bar:
				info_bar.fechar_por_distancia()

# --- Plantio (usado no Roçado) ---

func _limpar_plantacoes_invalidas() -> void:
	plantacoes = plantacoes.filter(func(p): return is_instance_valid(p) and not p.foi_colhido)

func _tem_plantacao_crescendo() -> bool:
	_limpar_plantacoes_invalidas()
	for planta in plantacoes:
		if not planta.pronto:
			return true
	return false

func _atualizar_status_plantio() -> void:
	if not plantar_apos_vitoria:
		return
	if _tem_plantacao_crescendo():
		var restante := 0
		for planta in plantacoes:
			if not planta.pronto:
				restante = max(restante, planta.tempo_restante())
		status_label.text = "Crescendo... %ds" % restante
	elif not plantacoes.is_empty():
		status_label.text = "Milho pronto! Colhe aí!"
	# sem plantação ativa, o texto volta pelo fluxo normal de _atualizar_status

func _plantar(total: int) -> void:
	if cena_plantacao == null or total <= 0:
		return
	var n: int = clampi(plantas_por_vitoria, 1, DESLOCAMENTOS_PLANTIO.size())
	var base: int = total / n
	var resto: int = total % n
	for i in range(n):
		var qtd: int = base + (1 if i < resto else 0)
		if qtd <= 0:
			continue
		var planta = cena_plantacao.instantiate()
		planta.quantidade = qtd
		planta.tempo_crescimento = tempo_crescimento
		# sem jitter: plantas ficam alinhadas em linha reta, seguindo a fileira do canteiro
		planta.global_position = global_position + DESLOCAMENTOS_PLANTIO[i]
		planta.colhido.connect(_on_planta_colhida)
		get_tree().current_scene.add_child(planta)
		plantacoes.append(planta)

func _on_planta_colhida(_quantidade: int) -> void:
	# quando a última planta for colhida, restaura o texto da zona
	_limpar_plantacoes_invalidas()
	if plantacoes.is_empty():
		_atualizar_status()

func _atualizar_proximidade(perto: bool) -> void:
	jogador_proximo = perto
	radius_indicator.modulate.a = 0.9 if perto else 0.3
	name_label.visible = not perto

func _atualizar_visual_bloqueio() -> void:
	var desbloqueada: bool = GameState.zona_desbloqueada(zone_name)
	var pronta_para_desbloquear: bool = not desbloqueada and GameState.requisitos_zona_atendidos(zone_name)
	if desbloqueada:
		status_label.modulate = Color(0.85, 1, 0.85)
	elif pronta_para_desbloquear:
		status_label.modulate = Color(1, 0.95, 0.5)
	else:
		status_label.modulate = Color(1, 0.75, 0.35)
	_atualizar_status()

func _atualizar_status() -> void:
	if GameState.zona_desbloqueada(zone_name):
		status_label.text = action_label
	elif GameState.requisitos_zona_atendidos(zone_name):
		status_label.text = "Pronto! Aperte E pra desbloquear"
	else:
		status_label.text = GameState.texto_progresso(zone_name)

func _on_recurso_alterado(_tipo: String, _qtd: int) -> void:
	_atualizar_visual_bloqueio()

func _confirmar_desbloqueio() -> void:
	modo_desbloqueio = false
	context_menu.hide()
	GameState.desbloquear_zona(zone_name)
	_atualizar_visual_bloqueio()
	_notificar_desbloqueio()

func _notificar_desbloqueio() -> void:
	var info_bar = get_tree().get_first_node_in_group("info_bar")
	if info_bar:
		info_bar.mostrar_mensagem("Dona Fiota", "Uai! %s desbloqueado. Agora dá pra %s!" % [zone_name, action_label.to_lower()])

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_open_menu()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interagir"):
		return
	if not jogador_proximo or puzzle_instance != null:
		return
	if player_ref and player_ref.movimento_bloqueado:
		return
	get_viewport().set_input_as_handled()
	if context_menu.visible:
		_on_action_button_pressed()
	else:
		_try_open_menu()

func _try_open_menu() -> void:
	if puzzle_instance != null:
		return
	if not jogador_proximo:
		context_menu.hide()
		return
	var info_bar_atual = get_tree().get_first_node_in_group("info_bar")
	if info_bar_atual:
		info_bar_atual.fechar_para_nova_acao()
	_posicionar_menu()
	if not GameState.zona_desbloqueada(zone_name):
		if GameState.requisitos_zona_atendidos(zone_name):
			modo_desbloqueio = true
			action_button.text = "Desbloquear"
			action_button.disabled = false
			context_menu.show()
		else:
			var info_bar = get_tree().get_first_node_in_group("info_bar")
			if info_bar:
				info_bar.mostrar_mensagem("Zona bloqueada", "%s: %s" % [zone_name, GameState.texto_requisito(zone_name)])
		return
	if _tem_plantacao_crescendo():
		var info_bar = get_tree().get_first_node_in_group("info_bar")
		if info_bar:
			info_bar.mostrar_mensagem("Dona Fiota", "Calma, uai! O milho ainda tá crescendo. Espera um cadinho que já dá pra colher.")
		return
	modo_desbloqueio = false
	action_button.text = action_label
	action_button.disabled = false
	_atualizar_upgrade_button()
	context_menu.show()

# Fica fixo no centro da zona (onde o jogador naturalmente para pra interagir),
# com um ajuste fino opcional por zona (ex.: Celeiro, pra sair de cima do telhado).
func _posicionar_menu() -> void:
	context_menu.position = deslocamento_menu

# Reforma do cercado: ação exclusiva do Curral, libera a partir da casa nível 2.
# O botão fica sempre clicável (como o Melhorar da casa): sem os requisitos,
# a Dona Fiota explica o que falta em vez de o botão simplesmente não responder.
func _atualizar_upgrade_button() -> void:
	if zone_name != "Curral" or GameState.cercado_reformado:
		upgrade_button.hide()
		return
	upgrade_button.show()
	upgrade_button.text = "Reformar cercado"

func _on_upgrade_button_pressed() -> void:
	if GameState.reformar_cercado():
		upgrade_button.hide()
		var info_bar = get_tree().get_first_node_in_group("info_bar")
		if info_bar:
			info_bar.mostrar_mensagem("Dona Fiota", "Uai, cercado novinho em folha! Ficou show de bola!")
	else:
		var info_bar = get_tree().get_first_node_in_group("info_bar")
		if info_bar:
			info_bar.mostrar_mensagem("Dona Fiota", GameState.texto_bloqueio_cercado())

func _on_action_button_pressed() -> void:
	var info_bar_atual = get_tree().get_first_node_in_group("info_bar")
	if info_bar_atual:
		info_bar_atual.fechar_para_nova_acao()
	if modo_desbloqueio:
		_confirmar_desbloqueio()
		return
	if not GameState.zona_desbloqueada(zone_name):
		return
	if _tem_plantacao_crescendo():
		context_menu.hide()
		return
	if GameState.cafe_atual < 1:
		action_button.text = "Sem café!"
		action_button.disabled = true
		var info_bar = get_tree().get_first_node_in_group("info_bar")
		if info_bar:
			info_bar.mostrar_mensagem("Dona Fiota", "O café acabou, uai! Vai pra Casa descansar que amanhã tem mais.")
		return
	context_menu.hide()
	if player_ref:
		player_ref.bloquear_movimento()
	var dif: Dictionary = GameState.dificuldade_puzzle()
	puzzle_instance = match3_scene.instantiate()
	puzzle_instance.tema = puzzle_tema
	puzzle_instance.win_reward_type = puzzle_reward_type
	puzzle_instance.win_reward_amount = puzzle_reward_amount
	puzzle_instance.move_limit = max(8, puzzle_move_limit + dif["move_delta"])
	puzzle_instance.score_target = puzzle_score_target + dif["score_delta"]
	puzzle_instance.credito_direto = not plantar_apos_vitoria
	get_tree().current_scene.add_child(puzzle_instance)
	puzzle_instance.puzzle_concluido.connect(_on_puzzle_concluido)
	puzzle_instance.puzzle_falhou.connect(_on_puzzle_falhou)
	acao_confirmada.emit(zone_name)

func _on_puzzle_concluido(_recurso: String, quantidade: int) -> void:
	_fechar_puzzle()
	if plantar_apos_vitoria and cena_plantacao:
		_plantar(quantidade)
		var info_bar = get_tree().get_first_node_in_group("info_bar")
		if info_bar:
			info_bar.mostrar_mensagem("Dona Fiota", "Milho plantado, uai! Espera um cadinho que ele cresce, aí é só o Caio passar pra colher.")
	else:
		TextoFlutuante.criar_recurso(self, global_position + Vector2(0, -60), puzzle_reward_type, quantidade)
		_falar_fiota(FALAS_VITORIA)

func _on_puzzle_falhou() -> void:
	_fechar_puzzle()
	if GameState.cafe_atual > 0:
		_falar_fiota(FALAS_DERROTA)
	else:
		var info_bar = get_tree().get_first_node_in_group("info_bar")
		if info_bar:
			info_bar.mostrar_mensagem("Dona Fiota", "O café acabou, uai! Vai pra Casa descansar que amanhã a lida continua.")

func _falar_fiota(falas: Array[String]) -> void:
	var info_bar = get_tree().get_first_node_in_group("info_bar")
	if info_bar:
		info_bar.mostrar_mensagem("Dona Fiota", falas.pick_random())

func _fechar_puzzle() -> void:
	if puzzle_instance:
		puzzle_instance.queue_free()
		puzzle_instance = null
	if player_ref:
		player_ref.liberar_movimento()
