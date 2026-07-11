extends Control

const MAIN_MENU := "res://scenes/MainMenu.tscn"

const HOLD_TIME := 0.9
const FADE_IN_TIME := 0.6
const FADE_OUT_TIME := 0.45

func _ready() -> void:
	var logo: TextureRect = $Logo
	logo.pivot_offset = logo.size / 2.0
	logo.modulate.a = 0.0
	logo.scale = Vector2(0.8, 0.8)

	var tween := create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, FADE_IN_TIME)
	tween.parallel().tween_property(logo, "scale", Vector2.ONE, FADE_IN_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(HOLD_TIME)
	tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_TIME)
	tween.tween_callback(func() -> void:
		get_tree().change_scene_to_file(MAIN_MENU))
