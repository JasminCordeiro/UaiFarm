extends CanvasLayer

const MAX_SCALE := 2.2
const DURATION := 0.3
const RIPPLE_SIZE := Vector2(12, 12)

func _ready() -> void:
	layer = 999
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	var scene := get_tree().current_scene
	if scene and scene.name == "RatingScreen":
		return
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
			or (event is InputEventScreenTouch and event.pressed):
		_spawn_ripple(event.position)

func _spawn_ripple(pos: Vector2) -> void:
	var ripple := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.0)
	style.border_color = Color(1, 1, 1, 0.5)
	style.set_border_width_all(2)
	style.set_corner_radius_all(1000)
	ripple.add_theme_stylebox_override("panel", style)
	ripple.size = RIPPLE_SIZE
	ripple.pivot_offset = RIPPLE_SIZE / 2.0
	ripple.position = pos - RIPPLE_SIZE / 2.0
	ripple.scale = Vector2(0.3, 0.3)
	ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ripple)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ripple, "scale", Vector2(MAX_SCALE, MAX_SCALE), DURATION) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(ripple, "modulate:a", 0.0, DURATION)
	tween.chain().tween_callback(ripple.queue_free)
