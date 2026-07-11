extends Control

const NEXT_SCREEN := "res://scenes/LogoScreen.tscn"

var _proceeding := false

func _ready() -> void:
	_animate_intro()
	_animate_prompt()

func _animate_intro() -> void:
	var badge: Panel = $Center/VBox/Badge
	badge.pivot_offset = badge.custom_minimum_size / 2.0
	badge.scale = Vector2(0.85, 0.85)
	$Center/VBox/Title.modulate.a = 0.0
	$Center/VBox/Description.modulate.a = 0.0
	$Prompt.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(badge, "scale", Vector2.ONE, 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($Center/VBox/Title, "modulate:a", 1.0, 0.4)
	tween.tween_property($Center/VBox/Description, "modulate:a", 1.0, 0.4)
	tween.tween_property($Prompt, "modulate:a", 1.0, 0.4)

func _animate_prompt() -> void:
	var pulse := create_tween()
	pulse.set_loops()
	pulse.tween_interval(1.7)
	pulse.tween_property($Prompt, "modulate:a", 0.25, 0.7) \
		
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property($Prompt, "modulate:a", 1.0, 0.7) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _input(event: InputEvent) -> void:
	if _proceeding:
		return
	if (event is InputEventMouseButton and event.pressed) \
			or (event is InputEventScreenTouch and event.pressed):
		_proceed(get_global_mouse_position())
	elif event is InputEventKey and event.pressed and not event.echo:
		_proceed(size / 2.0)

func _proceed(from: Vector2) -> void:
	_proceeding = true
	_spawn_ripple(from)

	# Pop no selo acompanhando o clique
	var badge: Panel = $Center/VBox/Badge
	var pop := create_tween()
	pop.tween_property(badge, "scale", Vector2(1.03, 1.03), 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	pop.tween_property(badge, "scale", Vector2.ONE, 0.15)

	var out := create_tween()
	out.tween_interval(0.55)
	out.tween_property(self, "modulate:a", 0.0, 0.45)
	out.tween_callback(func() -> void:
		get_tree().change_scene_to_file(NEXT_SCREEN))

func _spawn_ripple(from: Vector2) -> void:
	# Dois círculos concêntricos expandindo a partir do clique
	for i in 2:
		var ripple := Panel.new()
		var style := StyleBoxFlat.new()
		style.bg_color = Color(1, 1, 1, 0.0)
		style.border_color = Color(1, 1, 1, 0.9 - i * 0.35)
		style.set_border_width_all(4)
		style.set_corner_radius_all(1000)
		ripple.add_theme_stylebox_override("panel", style)
		ripple.size = Vector2(24, 24)
		ripple.pivot_offset = ripple.size / 2.0
		ripple.position = from - ripple.size / 2.0
		ripple.scale = Vector2(0.1, 0.1)
		ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(ripple)

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(ripple, "scale", Vector2(7, 7), 0.5 + i * 0.15) \
			.set_delay(i * 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(ripple, "modulate:a", 0.0, 0.5 + i * 0.15) \
			.set_delay(i * 0.1)
		tween.chain().tween_callback(ripple.queue_free)
