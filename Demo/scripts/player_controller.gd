extends CharacterBody2D

const FRAME_W := 64   # largura de cada frame em pixels
const NUM_LINHAS := 4  # linha 0=frente, 1=esquerda, 2=direita, 3=costas
const ANIM_ROWS: Array = [
	["walk_down",  0, false],
	["walk_left",  2, false],
	["walk_right", 1, false],
	["walk_up",    3, false],
]

@export var move_speed: float = 220.0

const DISTANCIA_FORA_DO_CAMINHO: float = 32.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var click_marker: Polygon2D = $ClickMarker
@onready var blocked_marker: Polygon2D = $BlockedMarker
@onready var sprite: AnimatedSprite2D = $Sprite

var movimento_bloqueado: bool = false
var click_marker_tween: Tween = null
var blocked_marker_tween: Tween = null
var sprite_pronto: bool = false

func _ready() -> void:
	add_to_group("player")
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	nav_agent.avoidance_enabled = false
	_configurar_sprite()

func _configurar_sprite() -> void:
	var tex: Texture2D = load("res://assets/Caio.png")
	if tex == null:
		return
	var frame_h: int = tex.get_height() / NUM_LINHAS
	var cols: int = tex.get_width() / FRAME_W
	var frames := SpriteFrames.new()
	for entry in ANIM_ROWS:
		var nome: String = entry[0]
		var linha: int = entry[1]
		frames.add_animation(nome)
		frames.set_animation_loop(nome, true)
		frames.set_animation_speed(nome, 8.0)
		for col in range(cols):
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(col * FRAME_W, linha * frame_h, FRAME_W, frame_h)
			frames.add_frame(nome, atlas)
	sprite.sprite_frames = frames
	sprite.play("walk_down")
	sprite.stop()
	sprite_pronto = true

func _unhandled_input(event: InputEvent) -> void:
	if movimento_bloqueado:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var destino: Vector2 = get_global_mouse_position()
		var ponto_alcancavel: Vector2 = NavigationServer2D.map_get_closest_point(nav_agent.get_navigation_map(), destino)
		if destino.distance_to(ponto_alcancavel) > DISTANCIA_FORA_DO_CAMINHO:
			_mostrar_feedback_bloqueado(destino)
			mover_para(ponto_alcancavel)
		else:
			_mostrar_feedback_clique(destino)
			mover_para(destino)

func bloquear_movimento() -> void:
	movimento_bloqueado = true
	nav_agent.target_position = global_position

func liberar_movimento() -> void:
	movimento_bloqueado = false

func mover_para(destino: Vector2) -> void:
	nav_agent.target_position = destino

func _mostrar_feedback_clique(destino: Vector2) -> void:
	click_marker.global_position = destino
	click_marker.visible = true
	click_marker.scale = Vector2.ONE
	click_marker.modulate = Color(1, 1, 1, 0.9)
	if click_marker_tween:
		click_marker_tween.kill()
	click_marker_tween = create_tween().set_parallel(true)
	click_marker_tween.tween_property(click_marker, "scale", Vector2(1.6, 1.6), 0.22)
	click_marker_tween.tween_property(click_marker, "modulate:a", 0.0, 0.22)
	click_marker_tween.finished.connect(_on_click_marker_tween_finished, CONNECT_ONE_SHOT)

func _on_click_marker_tween_finished() -> void:
	click_marker.visible = false

func _mostrar_feedback_bloqueado(destino: Vector2) -> void:
	blocked_marker.global_position = destino
	blocked_marker.visible = true
	blocked_marker.scale = Vector2.ONE
	blocked_marker.modulate = Color(1, 1, 1, 1)
	if blocked_marker_tween:
		blocked_marker_tween.kill()
	blocked_marker_tween = create_tween().set_parallel(true)
	blocked_marker_tween.tween_property(blocked_marker, "scale", Vector2(1.4, 1.4), 0.35)
	blocked_marker_tween.tween_property(blocked_marker, "modulate:a", 0.0, 0.35)
	blocked_marker_tween.finished.connect(_on_blocked_marker_tween_finished, CONNECT_ONE_SHOT)

func _on_blocked_marker_tween_finished() -> void:
	blocked_marker.visible = false

func _physics_process(delta: float) -> void:
	if not movimento_bloqueado:
		var input_dir: Vector2 = Input.get_vector("mover_esquerda", "mover_direita", "mover_cima", "mover_baixo")
		if input_dir != Vector2.ZERO:
			_mover_por_teclado(input_dir, delta)
			return
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		_atualizar_animacao()
		return
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = (next_pos - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
	_atualizar_animacao()

func _mover_por_teclado(input_dir: Vector2, delta: float) -> void:
	# Teclado cancela qualquer destino de clique pendente
	nav_agent.target_position = global_position
	# Restringe o movimento a malha de navegacao: projeta o proximo passo
	# no ponto mais proximo do caminho, deslizando ao longo das bordas.
	var destino: Vector2 = global_position + input_dir * move_speed * delta
	var ponto_seguro: Vector2 = NavigationServer2D.map_get_closest_point(nav_agent.get_navigation_map(), destino)
	# Mapa de navegacao ainda nao sincronizado (primeiros frames) ou ponto
	# projetado longe demais: nao move, evitando puxar o player pra fora.
	if ponto_seguro.distance_to(destino) > 96.0:
		velocity = Vector2.ZERO
		move_and_slide()
		_atualizar_animacao()
		return
	if delta > 0.0:
		velocity = (ponto_seguro - global_position) / delta
		if velocity.length() > move_speed:
			velocity = velocity.normalized() * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	_atualizar_animacao()

func _atualizar_animacao() -> void:
	if not sprite_pronto:
		return
	if velocity.length_squared() < 1.0:
		sprite.stop()
		sprite.frame = 0
		return
	var anim: String
	if abs(velocity.x) >= abs(velocity.y):
		anim = "walk_right" if velocity.x > 0 else "walk_left"
	else:
		anim = "walk_down" if velocity.y > 0 else "walk_up"
	if sprite.animation != anim:
		sprite.play(anim)
