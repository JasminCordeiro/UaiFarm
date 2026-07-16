class_name TextoFlutuante
extends Node2D

const FONTE: FontFile = preload("res://assets/fonts/Pixellari.ttf")

const ICONES: Dictionary = {
	"milho": "🌽",
	"graos": "🌾",
	"leite": "🥛",
	"ovos": "🥚",
}

static func criar_recurso(contexto: Node, posicao_global: Vector2, tipo: String, quantidade: int) -> void:
	var icone: String = ICONES.get(tipo, "")
	criar(contexto, posicao_global, ("+%d %s %s" % [quantidade, GameState.nome_recurso(tipo).to_lower(), icone]).strip_edges())

static func criar(contexto: Node, posicao_global: Vector2, texto: String) -> void:
	var no := TextoFlutuante.new()
	no.z_index = 100
	var label := Label.new()
	label.text = texto
	label.add_theme_font_override("font", FONTE)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1, 0.945098, 0.803922))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	no.add_child(label)
	contexto.get_tree().current_scene.add_child(no)
	no.global_position = posicao_global
	label.position = -label.get_minimum_size() / 2.0
	var tween := no.create_tween().set_parallel(true)
	tween.tween_property(no, "position:y", no.position.y - 46.0, 0.9) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(no, "modulate:a", 0.0, 0.35).set_delay(0.55)
	tween.chain().tween_callback(no.queue_free)
