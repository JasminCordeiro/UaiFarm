extends CharacterBody2D

@export var move_speed: float = 220.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var click_marker: Polygon2D = $ClickMarker

var movimento_bloqueado: bool = false
var click_marker_tween: Tween = null

func _ready() -> void:
	add_to_group("player")
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	nav_agent.avoidance_enabled = false

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
		return
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = (next_pos - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
