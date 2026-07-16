extends Node2D

@export var area_min: Vector2 = Vector2.ZERO
@export var area_max: Vector2 = Vector2(100, 100)
@export var speed: float = 26.0
# distancia (em px) que o bicho sobe/desce ao chegar na lateral do cercado antes
# de atravessar pro outro lado, tipo um cortador de grama
@export var passo_linha: float = 28.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _target: Vector2
var _indo_direita: bool = false
var _subindo: bool = true
var _fase_vertical: bool = false

func _ready() -> void:
	add_to_group("farm_animals")
	position.x = clampf(position.x, area_min.x, area_max.x)
	position.y = clampf(position.y, area_min.y, area_max.y)
	_target = Vector2(area_min.x, position.y)

func _process(delta: float) -> void:
	var direcao: Vector2 = _target - position
	var distancia: float = direcao.length()
	if distancia < 2.0:
		_proximo_trecho()
		return
	var movimento: Vector2 = direcao.normalized() * speed * delta
	if movimento.length() > distancia:
		movimento = direcao
	position += movimento
	_atualizar_animacao(direcao)

# Alterna entre andar de lado a lado e subir/descer uma fileira, sempre em
# linha reta. Ao alcancar o topo do cercado, inverte e volta descendo pelo
# mesmo percurso; ao alcancar a base, sobe de novo — e assim por diante.
func _proximo_trecho() -> void:
	if _fase_vertical:
		_fase_vertical = false
		_indo_direita = not _indo_direita
		_target = Vector2(area_max.x if _indo_direita else area_min.x, position.y)
		return
	var proxima_linha: float = position.y - passo_linha if _subindo else position.y + passo_linha
	if _subindo and proxima_linha <= area_min.y:
		proxima_linha = area_min.y
		_subindo = false
	elif not _subindo and proxima_linha >= area_max.y:
		proxima_linha = area_max.y
		_subindo = true
	_fase_vertical = true
	_target = Vector2(position.x, proxima_linha)

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
