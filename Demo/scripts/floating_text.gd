class_name TextoFlutuante
extends Node2D

const FONTE: FontFile = preload("res://assets/fonts/Pixellari.ttf")

# Ícones em pixel art: emojis não têm fallback de fonte no export Web
const ICONES: Dictionary = {
	"milho": preload("res://assets/EspigaMilho.png"),
	"graos": preload("res://assets/Racao.png"),
	"leite": preload("res://assets/JarroLeite.png"),
	"ovos": preload("res://assets/Ovos.png"),
}

static func criar_recurso(contexto: Node, posicao_global: Vector2, tipo: String, quantidade: int) -> void:
	criar(contexto, posicao_global, "+%d %s" % [quantidade, GameState.nome_recurso(tipo).to_lower()], ICONES.get(tipo))

static func criar(contexto: Node, posicao_global: Vector2, texto: String, icone: Texture2D = null) -> void:
	var no := TextoFlutuante.new()
	no.z_index = 100
	var caixa := HBoxContainer.new()
	caixa.add_theme_constant_override("separation", 6)
	if icone:
		var img := TextureRect.new()
		img.texture = icone
		img.custom_minimum_size = Vector2(26, 26)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		caixa.add_child(img)
	var label := Label.new()
	label.text = texto
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONTE)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1, 0.945098, 0.803922))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	caixa.add_child(label)
	no.add_child(caixa)
	contexto.get_tree().current_scene.add_child(no)
	no.global_position = posicao_global
	caixa.position = -caixa.get_minimum_size() / 2.0
	var tween := no.create_tween().set_parallel(true)
	tween.tween_property(no, "position:y", no.position.y - 46.0, 0.9) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(no, "modulate:a", 0.0, 0.35).set_delay(0.55)
	tween.chain().tween_callback(no.queue_free)
