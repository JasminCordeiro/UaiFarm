extends Node2D

signal puzzle_concluido(recurso: String, quantidade: int)
signal puzzle_falhou()

const GRID_SIZE: int = 6
const CELL_SIZE: int = 64
const POINTS_PER_PIECE: int = 10
const HINT_DELAY: float = 6.0

# Peças especiais criadas por combos grandes
const SPECIAL_NONE: int = 0
const SPECIAL_LINHA_H: int = 1  # limpa a linha inteira ao ser eliminada
const SPECIAL_LINHA_V: int = 2  # limpa a coluna inteira ao ser eliminada
const SPECIAL_BOMBA: int = 3    # explode area 3x3 ao ser eliminada

const CORES_POR_TEMA: Dictionary = {
	"rocado": [
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
	],
	"curral": [
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
	],
	"celeiro": [
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
		Color(0.97, 0.94, 0.86),
	],
}

const SIMBOLOS_POR_TEMA: Dictionary = {
	"rocado": ["", "", "", "", "", ""],
	"curral": ["", "", "", "", "", "", ""],
	"celeiro": ["", "", "", "", ""],
}

# Pecas de temas que usam imagem em vez de emoji (index igual ao da cor/simbolo)
const IMG_ESPIGA_MILHO: Texture2D = preload("res://assets/EspigaMilho.png")
const IMG_ALGODAO: Texture2D = preload("res://assets/Algodao.png")
const IMG_BATATAS: Texture2D = preload("res://assets/Batatas.png")
const IMG_CANA_DE_ACUCAR: Texture2D = preload("res://assets/CanaDeAcucar.png")
const IMG_PILHA_CAFE: Texture2D = preload("res://assets/PilhaCafe.png")
const IMG_LARANJAS: Texture2D = preload("res://assets/Laranjas.png")
const IMG_MANGUEIRA: Texture2D = preload("res://assets/Mangueira.png")
const IMG_FERTILIZANTE: Texture2D = preload("res://assets/Fertilizante.png")
const IMG_REGADOR: Texture2D = preload("res://assets/Regador.png")
const IMG_ENXADA: Texture2D = preload("res://assets/Enxada.png")
const IMG_RASTELO: Texture2D = preload("res://assets/Rastelo.png")
const IMG_OVOS: Texture2D = preload("res://assets/Ovos.png")
const IMG_PINTINHO: Texture2D = preload("res://assets/Pintinho.png")
const IMG_BEZERRINHO: Texture2D = preload("res://assets/Bezerrinho.png")
const IMG_BACON: Texture2D = preload("res://assets/Bacon.png")
const IMG_JARRO_LEITE: Texture2D = preload("res://assets/JarroLeite.png")
const IMG_RACAO: Texture2D = preload("res://assets/Racao.png")
const IMG_PORQUINHO: Texture2D = preload("res://assets/Porquinho.png")
const IMAGENS_POR_TEMA: Dictionary = {
	"rocado": [IMG_ESPIGA_MILHO, IMG_ALGODAO, IMG_BATATAS, IMG_CANA_DE_ACUCAR, IMG_PILHA_CAFE, IMG_LARANJAS],
	"curral": [IMG_OVOS, IMG_PINTINHO, IMG_BEZERRINHO, IMG_BACON, IMG_JARRO_LEITE, IMG_RACAO, IMG_PORQUINHO],
	"celeiro": [IMG_MANGUEIRA, IMG_FERTILIZANTE, IMG_REGADOR, IMG_ENXADA, IMG_RASTELO],
}

const IMG_COLHEITADEIRA: Texture2D = preload("res://assets/Colheitadeira.png")
const IMG_TESOURA: Texture2D = preload("res://assets/Tesoura.png")

@export var tema: String = "rocado"
@export var move_limit: int = 20
@export var score_target: int = 300
@export var win_reward_type: String = "milho"
@export var win_reward_amount: int = 15
# Quando falso, a recompensa não entra direto no inventário:
# a zona planta o recurso no campo pra ser colhido depois
@export var credito_direto: bool = true

var _cores: Array = []
var _simbolos: Array = []

@onready var board_container: Node2D = $UI/BoardContainer
@onready var score_label: Label = $UI/ScoreLabel
@onready var moves_label: Label = $UI/MovesLabel
@onready var banner_panel: Panel = $UI/BannerPanel
@onready var banner_label: Label = $UI/BannerPanel/Margin/VBoxContainer/BannerLabel
@onready var retry_button: Button = $UI/BannerPanel/Margin/VBoxContainer/RetryButton
@onready var back_button: Button = $UI/BannerPanel/Margin/VBoxContainer/BackButton
@onready var exit_button: Button = $UI/ExitButton

var grid: Array = []
var special_grid: Array = []
var piece_nodes: Array = []
var moves_remaining: int = 0
var score: int = 0
var is_busy: bool = false
var game_over: bool = false
var selected_cell: Vector2i = Vector2i(-1, -1)
var resultado_pendente: Dictionary = {}
var progress_bar: ProgressBar = null
var hint_timer: float = 0.0
var hint_cells: Array = []
var hint_tween: Tween = null

func _ready() -> void:
	_cores = CORES_POR_TEMA.get(tema, CORES_POR_TEMA["rocado"])
	_simbolos = SIMBOLOS_POR_TEMA.get(tema, SIMBOLOS_POR_TEMA["rocado"])
	retry_button.pressed.connect(_on_retry_pressed)
	back_button.pressed.connect(_on_back_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	_criar_barra_progresso()
	_garantir_solo()
	GameState.consumir_cafe()
	_iniciar_jogo()
	Music.pause()

func _exit_tree() -> void:
	Music.resume()

func _criar_barra_progresso() -> void:
	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0
	progress_bar.show_percentage = false
	progress_bar.position = Vector2(448, 88)
	progress_bar.size = Vector2(GRID_SIZE * CELL_SIZE, 14)
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.95, 0.75, 0.2)
	fill.set_corner_radius_all(6)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.1, 0.06, 0.85)
	bg.set_corner_radius_all(6)
	progress_bar.add_theme_stylebox_override("fill", fill)
	progress_bar.add_theme_stylebox_override("background", bg)
	$UI.add_child(progress_bar)

func _iniciar_jogo() -> void:
	score = 0
	moves_remaining = move_limit
	game_over = false
	is_busy = false
	selected_cell = Vector2i(-1, -1)
	resultado_pendente = {}
	banner_panel.hide()
	exit_button.show()
	_limpar_dica()
	_limpar_tabuleiro()
	_montar_grid_sem_matches()
	if _encontrar_jogada_valida().is_empty():
		_montar_grid_sem_matches()
	_instanciar_visuais()
	_atualizar_labels()

func _limpar_tabuleiro() -> void:
	for child in board_container.get_children():
		if child.name != "Background" and child.name != "SoloContainer":
			child.queue_free()
	grid.clear()
	special_grid.clear()
	piece_nodes.clear()

# Cria os "canteiros de terra arada" atrás das peças, uma vez só (persiste entre reinícios)
func _garantir_solo() -> void:
	if board_container.has_node("SoloContainer"):
		return
	var solo := Node2D.new()
	solo.name = "SoloContainer"
	board_container.add_child(solo)
	board_container.move_child(solo, 1)
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			solo.add_child(_criar_solo_da_celula(Vector2i(x, y)))

func _criar_solo_da_celula(cell: Vector2i) -> Panel:
	var canteiro := Panel.new()
	canteiro.position = Vector2(cell.x * CELL_SIZE + 1, cell.y * CELL_SIZE + 1)
	canteiro.size = Vector2(CELL_SIZE - 2, CELL_SIZE - 2)
	canteiro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.46, 0.33, 0.19)
	estilo.border_color = Color(0.30, 0.20, 0.10)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(6)
	canteiro.add_theme_stylebox_override("panel", estilo)
	return canteiro

func _montar_grid_sem_matches() -> void:
	grid = []
	special_grid = []
	for x in range(GRID_SIZE):
		var coluna: Array = []
		coluna.resize(GRID_SIZE)
		grid.append(coluna)
		var coluna_esp: Array = []
		coluna_esp.resize(GRID_SIZE)
		coluna_esp.fill(SPECIAL_NONE)
		special_grid.append(coluna_esp)
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
			var node := _criar_peca(grid[x][y], special_grid[x][y])
			node.position = _cell_to_pos(Vector2i(x, y))
			board_container.add_child(node)
			piece_nodes[x][y] = node

func _criar_peca(tipo: int, special: int = SPECIAL_NONE) -> Panel:
	var rect := Panel.new()
	rect.size = Vector2(CELL_SIZE - 6, CELL_SIZE - 6)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = _cores[tipo]
	estilo.border_color = Color(0.35, 0.24, 0.14, 0.6)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(10)
	rect.add_theme_stylebox_override("panel", estilo)
	# Peças especiais mostram só o ícone do bônus, sem o desenho do tipo por baixo
	if special != SPECIAL_NONE:
		_aplicar_visual_especial(rect, special)
		return rect
	var imagem: Texture2D = _imagem_do_tipo(tipo)
	if imagem:
		rect.add_child(_criar_icone(imagem))
	elif tipo < _simbolos.size() and _simbolos[tipo] != "":
		var lbl := Label.new()
		lbl.text = _simbolos[tipo]
		lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.add_child(lbl)
	return rect

func _imagem_do_tipo(tipo: int) -> Texture2D:
	var imagens: Array = IMAGENS_POR_TEMA.get(tema, [])
	if tipo < imagens.size():
		return imagens[tipo]
	return null

func _criar_icone(imagem: Texture2D) -> TextureRect:
	var icone := TextureRect.new()
	icone.texture = imagem
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icone

func _aplicar_visual_especial(rect: Panel, special: int) -> void:
	if special == SPECIAL_NONE:
		return
	# Ícones de colheitadeira/tesoura são exclusivos do roçado; outros temas usam o visual genérico
	if tema != "rocado":
		_aplicar_visual_especial_generico(rect, special)
		return
	if special == SPECIAL_LINHA_H or special == SPECIAL_LINHA_V:
		var icone := _criar_icone(IMG_TESOURA)
		if special == SPECIAL_LINHA_V:
			icone.pivot_offset = rect.size / 2.0
			icone.rotation = deg_to_rad(90)
		rect.add_child(icone)
	elif special == SPECIAL_BOMBA:
		rect.add_child(_criar_icone(IMG_COLHEITADEIRA))

func _aplicar_visual_especial_generico(rect: Panel, special: int) -> void:
	if special == SPECIAL_LINHA_H or special == SPECIAL_LINHA_V:
		var faixa := ColorRect.new()
		faixa.color = Color(1, 1, 1, 0.85)
		faixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if special == SPECIAL_LINHA_H:
			faixa.position = Vector2(2, rect.size.y / 2.0 - 3)
			faixa.size = Vector2(rect.size.x - 4, 6)
		else:
			faixa.position = Vector2(rect.size.x / 2.0 - 3, 2)
			faixa.size = Vector2(6, rect.size.y - 4)
		rect.add_child(faixa)
	elif special == SPECIAL_BOMBA:
		var lbl := Label.new()
		lbl.text = "*"
		lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 44)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.add_child(lbl)

func _definir_especial(cell: Vector2i, special: int) -> void:
	special_grid[cell.x][cell.y] = special
	var antigo: Panel = piece_nodes[cell.x][cell.y]
	if antigo:
		antigo.queue_free()
	var novo := _criar_peca(grid[cell.x][cell.y], special)
	novo.position = _cell_to_pos(cell)
	board_container.add_child(novo)
	piece_nodes[cell.x][cell.y] = novo
	# Pequeno "pulo" ao nascer, pra chamar atenção
	novo.pivot_offset = novo.size / 2.0
	novo.scale = Vector2(0.3, 0.3)
	var tween := create_tween()
	tween.tween_property(novo, "scale", Vector2(1.15, 1.15), 0.15)
	tween.tween_property(novo, "scale", Vector2.ONE, 0.1)

func _cell_to_pos(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE + 3, cell.y * CELL_SIZE + 3)

func _atualizar_labels() -> void:
	score_label.text = "Pontos: %d / %d" % [score, score_target]
	moves_label.text = "Movimentos: %d" % moves_remaining
	moves_label.modulate = Color(1, 0.45, 0.4) if moves_remaining <= 5 else Color(1, 1, 1)
	if progress_bar:
		progress_bar.max_value = score_target
		progress_bar.value = min(score, score_target)

# --- Input ---

func _process(delta: float) -> void:
	if game_over or is_busy or banner_panel.visible:
		return
	hint_timer += delta
	if hint_timer >= HINT_DELAY and hint_cells.is_empty():
		_mostrar_dica()

func _unhandled_input(event: InputEvent) -> void:
	if game_over or is_busy:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_limpar_dica()
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
	var node: Panel = piece_nodes[cell.x][cell.y]
	if node:
		node.modulate = Color(1.3, 1.3, 1.3) if ativo else Color(1, 1, 1)

func _is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return abs(a.x - b.x) + abs(a.y - b.y) == 1

# --- Dica e reembaralhamento ---

func _mostrar_dica() -> void:
	var jogada: Array = _encontrar_jogada_valida()
	if jogada.is_empty():
		return
	hint_cells = jogada
	var node_a: Panel = piece_nodes[jogada[0].x][jogada[0].y]
	var node_b: Panel = piece_nodes[jogada[1].x][jogada[1].y]
	if node_a == null or node_b == null:
		hint_cells = []
		return
	hint_tween = create_tween().set_loops()
	hint_tween.tween_property(node_a, "modulate", Color(1.6, 1.6, 1.2), 0.35)
	hint_tween.parallel().tween_property(node_b, "modulate", Color(1.6, 1.6, 1.2), 0.35)
	hint_tween.chain().tween_property(node_a, "modulate", Color(1, 1, 1), 0.35)
	hint_tween.parallel().tween_property(node_b, "modulate", Color(1, 1, 1), 0.35)

func _limpar_dica() -> void:
	hint_timer = 0.0
	if hint_tween:
		hint_tween.kill()
		hint_tween = null
	for cell in hint_cells:
		if _cell_valida(cell):
			var node: Panel = piece_nodes[cell.x][cell.y]
			if is_instance_valid(node):
				node.modulate = Color(1, 1, 1)
	hint_cells = []

func _encontrar_jogada_valida() -> Array:
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			for dir in [Vector2i(1, 0), Vector2i(0, 1)]:
				var a := Vector2i(x, y)
				var b: Vector2i = a + dir
				if b.x >= GRID_SIZE or b.y >= GRID_SIZE:
					continue
				_trocar_tipos(a, b)
				var valida: bool = not _find_runs().is_empty()
				_trocar_tipos(a, b)
				if valida:
					return [a, b]
	return []

func _trocar_tipos(a: Vector2i, b: Vector2i) -> void:
	var tmp = grid[a.x][a.y]
	grid[a.x][a.y] = grid[b.x][b.y]
	grid[b.x][b.y] = tmp

func _garantir_jogada_possivel() -> void:
	if not _encontrar_jogada_valida().is_empty():
		return
	_spawn_texto_flutuante(Vector2(GRID_SIZE * CELL_SIZE / 2.0, GRID_SIZE * CELL_SIZE / 2.0), "Sem jogadas!\nEmbaralhando...", Color(1, 1, 1))
	await get_tree().create_timer(0.8).timeout
	_reembaralhar()

func _reembaralhar() -> void:
	# Sorteia novos tipos (mantendo as peças especiais no lugar) até existir jogada
	var tentativas := 0
	while tentativas < 30:
		for x in range(GRID_SIZE):
			for y in range(GRID_SIZE):
				grid[x][y] = _tipo_aleatorio_sem_match(x, y)
		if not _encontrar_jogada_valida().is_empty():
			break
		tentativas += 1
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var node: Panel = piece_nodes[x][y]
			if node:
				node.queue_free()
	piece_nodes.clear()
	_instanciar_visuais()

# --- Troca e resolução ---

func _tentar_troca(a: Vector2i, b: Vector2i) -> void:
	is_busy = true
	_limpar_dica()
	_trocar_dados(a, b)
	await _animar_troca(a, b)
	if _find_runs().is_empty():
		Sfx.play_move()
		_trocar_dados(a, b)
		await _animar_troca(a, b)
		is_busy = false
	else:
		_consumir_movimento()
		await _resolver_cascata([a, b])
		is_busy = false

func _trocar_dados(a: Vector2i, b: Vector2i) -> void:
	_trocar_tipos(a, b)
	var tmp_esp = special_grid[a.x][a.y]
	special_grid[a.x][a.y] = special_grid[b.x][b.y]
	special_grid[b.x][b.y] = tmp_esp
	var tmp_node = piece_nodes[a.x][a.y]
	piece_nodes[a.x][a.y] = piece_nodes[b.x][b.y]
	piece_nodes[b.x][b.y] = tmp_node

func _animar_troca(a: Vector2i, b: Vector2i) -> void:
	var node_a: Panel = piece_nodes[a.x][a.y]
	var node_b: Panel = piece_nodes[b.x][b.y]
	var tween := create_tween().set_parallel(true)
	if node_a:
		tween.tween_property(node_a, "position", _cell_to_pos(a), 0.15)
	if node_b:
		tween.tween_property(node_b, "position", _cell_to_pos(b), 0.15)
	await tween.finished

func _consumir_movimento() -> void:
	moves_remaining -= 1
	_atualizar_labels()

func _resolver_cascata(swap_cells: Array) -> void:
	var cascata := 1
	while true:
		var runs: Array = _find_runs()
		if runs.is_empty():
			break
		await _resolver_runs(runs, swap_cells, cascata)
		swap_cells = []
		cascata += 1
	_verificar_fim_de_jogo()
	if not game_over:
		await _garantir_jogada_possivel()

func _resolver_runs(runs: Array, swap_cells: Array, cascata: int) -> void:
	Sfx.play_match()
	var matched := {}
	var contagem := {}
	for run in runs:
		for cell in run["cells"]:
			matched[cell] = true
			contagem[cell] = contagem.get(cell, 0) + 1

	# Decide quais células viram peças especiais em vez de sumir
	var novos_especiais := {}
	for cell in contagem.keys():
		if contagem[cell] >= 2:
			novos_especiais[cell] = SPECIAL_BOMBA  # interseção em L/T
	for run in runs:
		var cells: Array = run["cells"]
		if cells.size() < 4:
			continue
		var ja_tem := false
		for cell in cells:
			if novos_especiais.has(cell):
				ja_tem = true
				break
		if ja_tem:
			continue
		var alvo: Vector2i = cells[cells.size() >> 1]
		for sc in swap_cells:
			if cells.has(sc):
				alvo = sc
				break
		if cells.size() >= 5:
			novos_especiais[alvo] = SPECIAL_BOMBA
		else:
			novos_especiais[alvo] = SPECIAL_LINHA_H if run["horizontal"] else SPECIAL_LINHA_V

	# Expande a eliminação com os efeitos das peças especiais atingidas
	var eliminar := {}
	var fila: Array = matched.keys()
	while not fila.is_empty():
		var cell: Vector2i = fila.pop_back()
		if eliminar.has(cell) or novos_especiais.has(cell):
			continue
		if grid[cell.x][cell.y] == -1:
			continue
		eliminar[cell] = true
		match special_grid[cell.x][cell.y]:
			SPECIAL_LINHA_H:
				for x in range(GRID_SIZE):
					fila.append(Vector2i(x, cell.y))
			SPECIAL_LINHA_V:
				for y in range(GRID_SIZE):
					fila.append(Vector2i(cell.x, y))
			SPECIAL_BOMBA:
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						var vizinho := cell + Vector2i(dx, dy)
						if _cell_valida(vizinho):
							fila.append(vizinho)

	# Pontuação com multiplicador de cascata
	var pontos: int = eliminar.size() * POINTS_PER_PIECE * cascata
	score += pontos
	_atualizar_labels()
	_spawn_texto_pontos(eliminar.keys(), pontos, cascata)

	# Animação de "pop" das peças eliminadas
	if not eliminar.is_empty():
		var tween := create_tween().set_parallel(true)
		for cell in eliminar.keys():
			var node: Panel = piece_nodes[cell.x][cell.y]
			if node:
				node.pivot_offset = node.size / 2.0
				tween.tween_property(node, "scale", Vector2(0.05, 0.05), 0.18)
				tween.tween_property(node, "modulate:a", 0.0, 0.18)
		await tween.finished
	for cell in eliminar.keys():
		var node: Panel = piece_nodes[cell.x][cell.y]
		if node:
			node.queue_free()
		piece_nodes[cell.x][cell.y] = null
		grid[cell.x][cell.y] = -1
		special_grid[cell.x][cell.y] = SPECIAL_NONE

	# Cria as novas pecas especiais no lugar
	for cell in novos_especiais.keys():
		_definir_especial(cell, novos_especiais[cell])

	await _aplicar_gravidade()
	await _preencher_vazios()

func _spawn_texto_pontos(cells: Array, pontos: int, cascata: int) -> void:
	if cells.is_empty():
		return
	var centro := Vector2.ZERO
	for cell in cells:
		centro += Vector2(_cell_to_pos(cell)) + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
	centro /= cells.size()
	var texto := "+%d" % pontos
	var cor := Color(1, 1, 0.6)
	if cascata > 1:
		texto = "COMBO x%d  +%d" % [cascata, pontos]
		cor = Color(1, 0.6, 0.2)
	_spawn_texto_flutuante(centro, texto, cor)

func _spawn_texto_flutuante(pos_local: Vector2, texto: String, cor: Color) -> void:
	var lbl := Label.new()
	lbl.text = texto
	lbl.modulate = cor
	lbl.z_index = 10
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 24)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	lbl.add_theme_constant_override("outline_size", 6)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_container.add_child(lbl)
	lbl.position = pos_local - Vector2(60, 14)
	lbl.custom_minimum_size = Vector2(120, 28)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(lbl, "position:y", lbl.position.y - 42.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(lbl, "modulate:a", 0.0, 0.8).set_delay(0.25)
	tween.chain().tween_callback(lbl.queue_free)

func _aplicar_gravidade() -> void:
	var tween: Tween = null
	for x in range(GRID_SIZE):
		var write_y := GRID_SIZE - 1
		for y in range(GRID_SIZE - 1, -1, -1):
			if grid[x][y] != -1:
				if write_y != y:
					grid[x][write_y] = grid[x][y]
					grid[x][y] = -1
					special_grid[x][write_y] = special_grid[x][y]
					special_grid[x][y] = SPECIAL_NONE
					piece_nodes[x][write_y] = piece_nodes[x][y]
					piece_nodes[x][y] = null
					var node: Panel = piece_nodes[x][write_y]
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
				special_grid[x][y] = SPECIAL_NONE
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

# --- Detecção de matches ---

# Retorna sequências de 3+ peças iguais: [{"cells": Array[Vector2i], "horizontal": bool}, ...]
func _find_runs() -> Array:
	var runs: Array = []
	for y in range(GRID_SIZE):
		var tipo_atual = grid[0][y]
		var inicio := 0
		for x in range(1, GRID_SIZE + 1):
			var tipo = grid[x][y] if x < GRID_SIZE else -2
			if tipo != tipo_atual:
				if tipo_atual != -1 and x - inicio >= 3:
					var cells: Array = []
					for rx in range(inicio, x):
						cells.append(Vector2i(rx, y))
					runs.append({"cells": cells, "horizontal": true})
				inicio = x
				tipo_atual = tipo
	for x in range(GRID_SIZE):
		var tipo_atual = grid[x][0]
		var inicio := 0
		for y in range(1, GRID_SIZE + 1):
			var tipo = grid[x][y] if y < GRID_SIZE else -2
			if tipo != tipo_atual:
				if tipo_atual != -1 and y - inicio >= 3:
					var cells: Array = []
					for ry in range(inicio, y):
						cells.append(Vector2i(x, ry))
					runs.append({"cells": cells, "horizontal": false})
				inicio = y
				tipo_atual = tipo
	return runs

# --- Fim de jogo ---

func _verificar_fim_de_jogo() -> void:
	if score >= score_target:
		_trigger_win()
	elif moves_remaining <= 0:
		_trigger_lose()

func _trigger_win() -> void:
	game_over = true
	is_busy = true
	_limpar_dica()
	Sfx.play_win()
	resultado_pendente = {"vitoria": true, "recurso": win_reward_type, "quantidade": win_reward_amount}
	if credito_direto:
		GameState.adicionar_recurso(win_reward_type, win_reward_amount)
		_mostrar_banner("UAI! Desafio Concluído!\n+%d %s" % [win_reward_amount, GameState.nome_recurso(win_reward_type).to_lower()], false)
	else:
		_mostrar_banner("UAI! Desafio Concluído!\n%d %s plantado no campo!" % [win_reward_amount, GameState.nome_recurso(win_reward_type).to_lower()], false)

func _trigger_lose() -> void:
	game_over = true
	is_busy = true
	_limpar_dica()
	Sfx.play_lose()
	resultado_pendente = {"vitoria": false}
	_mostrar_banner("Movimentos esgotados!\nNenhum recurso ganho.", true)

func _mostrar_banner(texto: String, permitir_retry: bool) -> void:
	banner_label.text = texto
	retry_button.visible = permitir_retry
	if permitir_retry:
		retry_button.disabled = GameState.cafe_atual <= 0
		retry_button.text = "Tentar Novamente" if GameState.cafe_atual > 0 else "Sem café"
	exit_button.hide()
	banner_panel.show()

func _on_retry_pressed() -> void:
	if not GameState.consumir_cafe():
		retry_button.disabled = true
		retry_button.text = "Sem café"
		return
	_iniciar_jogo()

func _on_back_pressed() -> void:
	if resultado_pendente.get("vitoria", false):
		puzzle_concluido.emit(resultado_pendente["recurso"], resultado_pendente["quantidade"])
	elif resultado_pendente.has("vitoria"):
		puzzle_falhou.emit()

# Botão persistente (fora do banner) pra sair do desafio a qualquer momento, sem recompensa
func _on_exit_button_pressed() -> void:
	if game_over:
		return
	game_over = true
	is_busy = true
	_limpar_dica()
	resultado_pendente = {"vitoria": false}
	puzzle_falhou.emit()
