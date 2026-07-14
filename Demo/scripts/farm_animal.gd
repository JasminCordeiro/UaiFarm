extends Node2D

@export var area_min: Vector2 = Vector2.ZERO
@export var area_max: Vector2 = Vector2(100, 100)
@export var speed: float = 26.0
@export var pause_min: float = 1.0
@export var pause_max: float = 3.0
@export var raio_separacao: float = 40.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _target: Vector2
var _pausing: bool = false
var _pause_timer: float = 0.0

func _ready() -> void:
	add_to_group("farm_animals")
	position = Vector2(randf_range(area_min.x, area_max.x), randf_range(area_min.y, area_max.y))
	_escolher_novo_alvo()

func _process(delta: float) -> void:
	if _pausing:
		_pause_timer -= delta
		if _pause_timer <= 0.0:
			_pausing = false
			_escolher_novo_alvo()
		_aplicar_separacao(delta)
		return
	var direcao: Vector2 = _target - position
	var distancia: float = direcao.length()
	if distancia < 2.0:
		_iniciar_pausa()
		return
	var movimento: Vector2 = direcao.normalized() * speed * delta
	if movimento.length() > distancia:
		movimento = direcao
	position += movimento
	_aplicar_separacao(delta)
	_atualizar_animacao(direcao)

func _aplicar_separacao(delta: float) -> void:
	var empurrao: Vector2 = Vector2.ZERO
	for outro in get_tree().get_nodes_in_group("farm_animals"):
		if outro == self:
			continue
		var diferenca: Vector2 = position - outro.position
		var dist: float = diferenca.length()
		if dist > 0.0 and dist < raio_separacao:
			empurrao += diferenca.normalized() * (raio_separacao - dist)
	if empurrao == Vector2.ZERO:
		return
	position += empurrao * 3.0 * delta
	position.x = clampf(position.x, area_min.x, area_max.x)
	position.y = clampf(position.y, area_min.y, area_max.y)

func _escolher_novo_alvo() -> void:
	_target = Vector2(randf_range(area_min.x, area_max.x), randf_range(area_min.y, area_max.y))

func _iniciar_pausa() -> void:
	_pausing = true
	_pause_timer = randf_range(pause_min, pause_max)
	sprite.stop()

func _atualizar_animacao(direcao: Vector2) -> void:
	var anim: StringName
	if abs(direcao.x) > abs(direcao.y):
		anim = &"walk_side"
		sprite.flip_h = direcao.x < 0
	else:
		anim = &"walk_down" if direcao.y > 0 else &"walk_up"
		sprite.flip_h = false
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
