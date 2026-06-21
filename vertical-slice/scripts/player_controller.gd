extends CharacterBody2D

@export var move_speed: float = 220.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var movimento_bloqueado: bool = false

func _ready() -> void:
	add_to_group("player")
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	nav_agent.avoidance_enabled = false

func _unhandled_input(event: InputEvent) -> void:
	if movimento_bloqueado:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mover_para(get_global_mouse_position())

func bloquear_movimento() -> void:
	movimento_bloqueado = true
	nav_agent.target_position = global_position

func liberar_movimento() -> void:
	movimento_bloqueado = false

func mover_para(destino: Vector2) -> void:
	nav_agent.target_position = destino

func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = (next_pos - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
