extends Node2D

signal puzzle_concluido(recurso: String, quantidade: int)
signal puzzle_falhou()

const GRID_SIZE: int = 6
const CELL_SIZE: int = 64
const POINTS_PER_PIECE: int = 10

const CORES_POR_TEMA: Dictionary = {
	"rocado": [
		Color(0.95, 0.85, 0.2),
		Color(0.3, 0.75, 0.3),
		Color(0.95, 0.55, 0.1),
		Color(0.3, 0.55, 0.85),
	],
	"curral": [
		Color(0.92, 0.92, 0.96),
		Color(0.85, 0.72, 0.2),
		Color(0.55, 0.33, 0.14),
	],
	"paiol": [
		Color(0.42, 0.26, 0.10),
		Color(0.62, 0.62, 0.62),
		Color(0.90, 0.80, 0.38),
		Color(0.72, 0.34, 0.10),
		Color(0.28, 0.55, 0.20),
	],
}

const SIMBOLOS_POR_TEMA: Dictionary = {
	"rocado": ["🌽", "🌿", "☀", "💧"],
	"curral": ["🥛", "🌾", "🟤"],
	"paiol":  ["🪵", "🪨", "🌾", "🔧", "🍂"],
}

@export var tema: String = "rocado"
@export var move_limit: int = 20
@export var score_target: int = 300
@export var win_reward_type: String = "milho"
@export var win_reward_amount: int = 15

var _cores: Array = []
var _simbolos: Array = []

@onready var board_container: Node2D = $BoardContainer
@onready var score_label: Label = $UI/ScoreLabel
@onready var moves_label: Label = $UI/MovesLabel
@onready var banner_panel: Panel = $UI/BannerPanel
@onready var banner_label: Label = $UI/BannerPanel/BannerLabel
@onready var retry_button: Button = $UI/BannerPanel/RetryButton
@onready var back_button: Button = $UI/BannerPanel/BackButton

var grid: Array = []
var piece_nodes: Array = []
var moves_remaining: int = 0
var score: int = 0
var is_busy: bool = false
var game_over: bool = false
var selected_cell: Vector2i = Vector2i(-1, -1)
var resultado_pendente: Dictionary = {}

func _ready() -> void:
	_cores = CORES_POR_TEMA.get(tema, CORES_POR_TEMA["rocado"])
	_simbolos = SIMBOLOS_POR_TEMA.get(tema, SIMBOLOS_POR_TEMA["rocado"])
	retry_button.pressed.connect(_on_retry_pressed)
	back_button.pressed.connect(_on_back_pressed)
	GameState.consumir_cafe()
	_iniciar_jogo()

func _iniciar_jogo() -> void:
	score = 0
	moves_remaining = move_limit
	game_over = false
	is_busy = false
	selected_cell = Vector2i(-1, -1)
	resultado_pendente = {}
	banner_panel.hide()
	_limpar_tabuleiro()
	_montar_grid_sem_matches()
	_instanciar_visuais()
	_atualizar_labels()

func _limpar_tabuleiro() -> void:
	for child in board_container.get_children():
		if child.name != "Background":
			child.queue_free()
	grid.clear()
	piece_nodes.clear()

func _montar_grid_sem_matches() -> void:
	grid = []
	for x in range(GRID_SIZE):
		var coluna: Array = []
		coluna.resize(GRID_SIZE)
		grid.append(coluna)
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			grid[x][y] = _tipo_aleatorio_sem_match(x, y)

func _tipo_aleatorio_sem_match(x: int, y: int) -> int:
	var tentativas := 0
	var tipo := randi() % _cores.size()
	while tentativas < 20:
		var esquerda_ok: bool = x < 2 or not (grid[x - 1][y] == tipo and grid[x - 2][y] == tipo)
		var acima_ok: bool = y < 2 or not (grid[x][y - 1] == tipo and grid[x][y - 2] == tipo)
		if esquerda_ok and acima_ok:
			break
		tipo = randi() % _cores.size()
		tentativas += 1
	return tipo

func _instanciar_visuais() -> void:
	piece_nodes = []
	for x in range(GRID_SIZE):
		var coluna: Array = []
		coluna.resize(GRID_SIZE)
		piece_nodes.append(coluna)
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var node := _criar_peca(grid[x][y])
			node.position = _cell_to_pos(Vector2i(x, y))
			board_container.add_child(node)
			piece_nodes[x][y] = node

func _criar_peca(tipo: int) -> ColorRect:
	var rect := ColorRect.new()
	rect.size = Vector2(CELL_SIZE - 6, CELL_SIZE - 6)
	rect.color = _cores[tipo]
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tipo < _simbolos.size():
		var lbl := Label.new()
		lbl.text = _simbolos[tipo]
		lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.add_child(lbl)
	return rect

func _cell_to_pos(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE + 3, cell.y * CELL_SIZE + 3)

func _atualizar_labels() -> void:
	score_label.text = "Pontos: %d / %d" % [score, score_target]
	moves_label.text = "Movimentos: %d" % moves_remaining

# --- Input ---

func _unhandled_input(event: InputEvent) -> void:
	if game_over or is_busy:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos: Vector2 = board_container.get_local_mouse_position()
		var cell := Vector2i(int(local_pos.x / CELL_SIZE), int(local_pos.y / CELL_SIZE))
		if _cell_valida(cell):
			_processar_clique(cell)

func _cell_valida(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GRID_SIZE and cell.y >= 0 and cell.y < GRID_SIZE

func _processar_clique(cell: Vector2i) -> void:
	if selected_cell == Vector2i(-1, -1):
		selected_cell = cell
		_set_destaque(cell, true)
		return
	if selected_cell == cell:
		_set_destaque(cell, false)
		selected_cell = Vector2i(-1, -1)
		return
	if _is_adjacent(selected_cell, cell):
		var anterior := selected_cell
		_set_destaque(anterior, false)
		selected_cell = Vector2i(-1, -1)
		_tentar_troca(anterior, cell)
	else:
		_set_destaque(selected_cell, false)
		selected_cell = cell
		_set_destaque(cell, true)

func _set_destaque(cell: Vector2i, ativo: bool) -> void:
	var node: ColorRect = piece_nodes[cell.x][cell.y]
	if node:
		node.modulate = Color(1.3, 1.3, 1.3) if ativo else Color(1, 1, 1)

func _is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return abs(a.x - b.x) + abs(a.y - b.y) == 1

# --- Troca e resolucao ---

func _tentar_troca(a: Vector2i, b: Vector2i) -> void:
	is_busy = true
	_trocar_dados(a, b)
	await _animar_troca(a, b)
	var matches := _find_all_matches()
	if matches.is_empty():
		_trocar_dados(a, b)
		await _animar_troca(a, b)
		is_busy = false
	else:
		_consumir_movimento()
		await _resolver_matches(matches)
		is_busy = false

func _trocar_dados(a: Vector2i, b: Vector2i) -> void:
	var tmp_tipo = grid[a.x][a.y]
	grid[a.x][a.y] = grid[b.x][b.y]
	grid[b.x][b.y] = tmp_tipo
	var tmp_node = piece_nodes[a.x][a.y]
	piece_nodes[a.x][a.y] = piece_nodes[b.x][b.y]
	piece_nodes[b.x][b.y] = tmp_node

func _animar_troca(a: Vector2i, b: Vector2i) -> void:
	var node_a: ColorRect = piece_nodes[a.x][a.y]
	var node_b: ColorRect = piece_nodes[b.x][b.y]
	var tween := create_tween().set_parallel(true)
	if node_a:
		tween.tween_property(node_a, "position", _cell_to_pos(a), 0.15)
	if node_b:
		tween.tween_property(node_b, "position", _cell_to_pos(b), 0.15)
	await tween.finished

func _consumir_movimento() -> void:
	moves_remaining -= 1
	_atualizar_labels()

func _resolver_matches(matches: Array) -> void:
	score += matches.size() * POINTS_PER_PIECE
	for cell in matches:
		var node: ColorRect = piece_nodes[cell.x][cell.y]
		if node:
			node.queue_free()
		piece_nodes[cell.x][cell.y] = null
		grid[cell.x][cell.y] = -1
	_atualizar_labels()
	await _aplicar_gravidade()
	await _preencher_vazios()
	var novos_matches := _find_all_matches()
	if not novos_matches.is_empty():
		await _resolver_matches(novos_matches)
	else:
		_verificar_fim_de_jogo()

func _aplicar_gravidade() -> void:
	var tween: Tween = null
	for x in range(GRID_SIZE):
		var write_y := GRID_SIZE - 1
		for y in range(GRID_SIZE - 1, -1, -1):
			if grid[x][y] != -1:
				if write_y != y:
					grid[x][write_y] = grid[x][y]
					grid[x][y] = -1
					piece_nodes[x][write_y] = piece_nodes[x][y]
					piece_nodes[x][y] = null
					var node: ColorRect = piece_nodes[x][write_y]
					if tween == null:
						tween = create_tween().set_parallel(true)
					tween.tween_property(node, "position", _cell_to_pos(Vector2i(x, write_y)), 0.15)
				write_y -= 1
	if tween != null:
		await tween.finished

func _preencher_vazios() -> void:
	var tween: Tween = null
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if grid[x][y] == -1:
				var tipo := randi() % _cores.size()
				grid[x][y] = tipo
				var node := _criar_peca(tipo)
				var pos_final := _cell_to_pos(Vector2i(x, y))
				node.position = pos_final - Vector2(0, CELL_SIZE * (y + 2))
				board_container.add_child(node)
				piece_nodes[x][y] = node
				if tween == null:
					tween = create_tween().set_parallel(true)
				tween.tween_property(node, "position", pos_final, 0.2)
	if tween != null:
		await tween.finished

func _find_all_matches() -> Array:
	var encontrados := {}
	for y in range(GRID_SIZE):
		var tipo_atual = grid[0][y]
		var inicio := 0
		for x in range(1, GRID_SIZE + 1):
			var tipo = grid[x][y] if x < GRID_SIZE else -2
			if tipo != tipo_atual:
				if tipo_atual != -1 and x - inicio >= 3:
					for rx in range(inicio, x):
						encontrados[Vector2i(rx, y)] = true
				inicio = x
				tipo_atual = tipo
	for x in range(GRID_SIZE):
		var tipo_atual = grid[x][0]
		var inicio := 0
		for y in range(1, GRID_SIZE + 1):
			var tipo = grid[x][y] if y < GRID_SIZE else -2
			if tipo != tipo_atual:
				if tipo_atual != -1 and y - inicio >= 3:
					for ry in range(inicio, y):
						encontrados[Vector2i(x, ry)] = true
				inicio = y
				tipo_atual = tipo
	return encontrados.keys()

# --- Fim de jogo ---

func _verificar_fim_de_jogo() -> void:
	if score >= score_target:
		_trigger_win()
	elif moves_remaining <= 0:
		_trigger_lose()

func _trigger_win() -> void:
	game_over = true
	is_busy = true
	GameState.adicionar_recurso(win_reward_type, win_reward_amount)
	resultado_pendente = {"vitoria": true, "recurso": win_reward_type, "quantidade": win_reward_amount}
	_mostrar_banner("UAI! Desafio Concluido!\n+%d %s" % [win_reward_amount, win_reward_type], false)

func _trigger_lose() -> void:
	game_over = true
	is_busy = true
	resultado_pendente = {"vitoria": false}
	_mostrar_banner("Movimentos esgotados!\nNenhum recurso ganho.", true)

func _mostrar_banner(texto: String, permitir_retry: bool) -> void:
	banner_label.text = texto
	retry_button.visible = permitir_retry
	if permitir_retry:
		retry_button.disabled = GameState.cafe_atual <= 0
		retry_button.text = "Tentar Novamente" if GameState.cafe_atual > 0 else "Sem cafe"
	banner_panel.show()

func _on_retry_pressed() -> void:
	if not GameState.consumir_cafe():
		retry_button.disabled = true
		retry_button.text = "Sem cafe"
		return
	_iniciar_jogo()

func _on_back_pressed() -> void:
	if resultado_pendente.get("vitoria", false):
		puzzle_concluido.emit(resultado_pendente["recurso"], resultado_pendente["quantidade"])
	elif resultado_pendente.has("vitoria"):
		puzzle_falhou.emit()
