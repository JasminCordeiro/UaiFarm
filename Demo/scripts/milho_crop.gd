extends Area2D

signal colhido(quantidade: int)

const TEX_PLANTADO: Texture2D = preload("res://assets/Milho-Plantado.png")
const TEX_CRESCENDO: Texture2D = preload("res://assets/Milho-Crescendo.png")
const TEX_PRONTO: Texture2D = preload("res://assets/Milho.png")
# Os 3 estagios compartilham a mesma largura de base, so a altura cresce.
# Escala pensada pra caber lado a lado no espacamento de 40px das fileiras do plantio sem sobrepor.
const ESCALA_PLANTADO: Vector2 = Vector2(0.13, 0.13)
const ESCALA_CRESCENDO: Vector2 = Vector2(0.13, 0.13)
const ESCALA_PRONTO: Vector2 = Vector2(0.13, 0.13)
const RAIO_COLETA_CLIQUE: float = 90.0

@export var tempo_crescimento: float = 10.0
@export var quantidade: int = 3

var pronto: bool = false
var foi_colhido: bool = false
var em_crescimento_medio: bool = false
var tempo_restante_s: float = 0.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	tempo_restante_s = tempo_crescimento
	sprite.texture = TEX_PLANTADO
	sprite.scale = ESCALA_PLANTADO
	# offset deixa a base da planta no ponto de spawn
	sprite.offset = Vector2(0, -TEX_PLANTADO.get_height() / 2.0)
	body_entered.connect(_on_body_entered)
	input_event.connect(_on_input_event)
	# nasce com um "pop"
	scale = Vector2(0.2, 0.2)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	if pronto:
		return
	tempo_restante_s -= delta
	if tempo_restante_s <= 0.0:
		_amadurecer()
	elif not em_crescimento_medio and tempo_restante_s <= tempo_crescimento * 0.5:
		_crescer_estagio_medio()

func tempo_restante() -> int:
	return ceili(maxf(tempo_restante_s, 0.0))

func _crescer_estagio_medio() -> void:
	em_crescimento_medio = true
	sprite.texture = TEX_CRESCENDO
	sprite.scale = ESCALA_CRESCENDO
	sprite.offset = Vector2(0, -TEX_CRESCENDO.get_height() / 2.0)

func _amadurecer() -> void:
	pronto = true
	sprite.texture = TEX_PRONTO
	sprite.scale = ESCALA_PRONTO
	sprite.offset = Vector2(0, -TEX_PRONTO.get_height() / 2.0)
	var pop := create_tween()
	pop.tween_property(sprite, "scale", ESCALA_PRONTO * 1.25, 0.15)
	pop.tween_property(sprite, "scale", ESCALA_PRONTO, 0.12)
	# balanco continuo pra indicar que da pra colher
	var sway := create_tween().set_loops()
	sway.tween_property(sprite, "rotation_degrees", 6.0, 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(sprite, "rotation_degrees", -6.0, 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# se o Caio ja estiver em cima, colhe direto
	for body in get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body: Node2D) -> void:
	if pronto and not foi_colhido and body.is_in_group("player"):
		_colher()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not pronto or foi_colhido:
		return
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) <= RAIO_COLETA_CLIQUE:
		_colher()

func _colher() -> void:
	if foi_colhido:
		return
	foi_colhido = true
	GameState.adicionar_recurso("milho", quantidade)
	TextoFlutuante.criar_recurso(self, global_position + Vector2(0, -44), "milho", quantidade)
	colhido.emit(quantidade)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.05, 0.05), 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)
