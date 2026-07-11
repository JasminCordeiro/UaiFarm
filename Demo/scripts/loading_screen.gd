extends Control

const DURATION := 0.85
const DEFAULT_TARGET := "res://scenes/Overworld.tscn"

@onready var bar: ProgressBar = $Center/VBox/LoadingBar

func _ready() -> void:
	var target: String = GameState.cena_destino
	if target == "":
		target = DEFAULT_TARGET
	GameState.cena_destino = ""

	bar.value = 0.0
	var tween := create_tween()
	tween.tween_property(bar, "value", 100.0, DURATION) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func() -> void:
		get_tree().change_scene_to_file(target))
