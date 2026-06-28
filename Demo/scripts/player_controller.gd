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

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var click_marker: Polygon2D = $ClickMarker
@onready var sprite: AnimatedSprite2D = $Sprite

var movimento_bloqueado: bool = false
var click_marker_tween: Tween = null
var sprite_pronto: bool = false

func _ready() -> void:
	add_to_group("player")
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	nav_agent.avoidance_enabled = false
	_configurar_sprite()

func _configurar_sprite() -> void:
	var tex: Texture2D = load("res://assets/caio.png")
	if tex == null:
		return
	var frame_h := int(tex.get_height() / NUM_LINHAS)
	var cols := int(tex.get_width() / FRAME_W)
	print("caio.png: %dx%d | frame: %dx%d | %d colunas" % [tex.get_width(), tex.get_height(), FRAME_W, frame_h, cols])
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

func _physics_process(_delta: float) -> void:
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
