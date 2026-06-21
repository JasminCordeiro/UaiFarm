extends Node2D

@export var radius: float = 90.0
@export var cor: Color = Color(1, 1, 1, 0.25)

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, cor, 2.0, true)

func definir_raio(novo_raio: float) -> void:
	radius = novo_raio
	queue_redraw()
