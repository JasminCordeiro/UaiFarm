extends Control

const LOADING_SCREEN := "res://scenes/LoadingScreen.tscn"
const OVERWORLD := "res://scenes/Overworld.tscn"
const CAR_SLIDE_INDEX := 2
const FIOTA_SLIDE_INDEX := 3

const SLIDES: Array[String] = [
	"Belo Horizonte, dias atuais. Desde que trocou o interior pela cidade grande, Caio vinha se sentindo cada vez mais sufocado: rotina de escritório, contas apertadas e planilhas que não faziam sentido nenhum.",
	"Até que uma carta muda tudo: seu avô falecera e deixou pra ele a Fazenda Uai, nos arredores de Conselheiro Lafaiete, MG.",
	"Foi aí que Caio percebeu: fazia tempo que não era feliz ali. Arrumou as malas e topou o desafio: hora de voltar pras raízes da família.",
	"Ao chegar, encontrou tudo abandonado: roçado seco, curral vazio, celeiro sem estoque... Foi recebido por Dona Fiota, velha amiga do avô, que cuidava do lugar havia anos.\n\"Uai, meu fio, tá na hora de arregaçar as mangas e dar vida a essa terra de novo!\" - Dona Fiota",
]

@onready var story_label: Label = $Center/PanelContainer/Margin/HBox/StoryLabel
@onready var portrait: TextureRect = $Center/PanelContainer/Margin/HBox/Portrait
@onready var click_catcher: Control = $ClickCatcher
@onready var skip_button: Button = $SkipButton
@onready var prompt: Label = $Prompt
@onready var scene_background: TextureRect = $SceneBackground
@onready var car: TextureRect = $CarLayer/Car
@onready var casa_overlay: TextureRect = $CasaOverlay

var _slide_backgrounds: Array[Texture2D] = [
	preload("res://assets/cidade-grande.png"),
	preload("res://assets/cidade-grande.png"),
	preload("res://assets/rua-viagem.png"),
	preload("res://assets/Background-Principal-Farm.png"),
]

var _index: int = -1
var _advancing: bool = false
var _car_slide_locked: bool = false
var _car_tweens: Array[Tween] = []
var _dust_timer: Timer = null

func _ready() -> void:
	click_catcher.gui_input.connect(_on_click_catcher_input)
	skip_button.pressed.connect(_on_skip)
	_animate_prompt()
	_show_slide(0)

func _animate_prompt() -> void:
	var pulse := create_tween()
	pulse.set_loops()
	pulse.tween_interval(1.4)
	pulse.tween_property(prompt, "modulate:a", 0.3, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(prompt, "modulate:a", 1.0, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_click_catcher_input(event: InputEvent) -> void:
	if _car_slide_locked:
		return
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
			or (event is InputEventScreenTouch and event.pressed):
		_advance()

func _on_skip() -> void:
	_finish()

func _advance() -> void:
	if _advancing:
		return
	if _index >= SLIDES.size() - 1:
		_finish()
		return
	_show_slide(_index + 1)

func _show_slide(index: int) -> void:
	_advancing = true
	_index = index
	_stop_car()

	var tween := create_tween()
	tween.tween_property(story_label, "modulate:a", 0.0, 0.18)
	tween.tween_callback(func() -> void:
		story_label.text = SLIDES[index]
		scene_background.texture = _slide_backgrounds[index]
		portrait.visible = index == FIOTA_SLIDE_INDEX
		casa_overlay.visible = index == FIOTA_SLIDE_INDEX
		if index == CAR_SLIDE_INDEX:
			_car_slide_locked = true
			prompt.hide()
			_play_car_crossing()
		else:
			_car_slide_locked = false
			prompt.show()
	)
	tween.tween_property(story_label, "modulate:a", 1.0, 0.25)
	tween.tween_callback(func() -> void:
		_advancing = false
	)

func _finish() -> void:
	if not is_inside_tree():
		return
	_advancing = true
	_stop_car()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func() -> void:
		GameState.cena_destino = OVERWORLD
		get_tree().change_scene_to_file(LOADING_SCREEN))

# --- Animação do carro (frame único, movimento simulado) ---

func _play_car_crossing() -> void:
	car.show()
	car.rotation_degrees = 0.0
	car.pivot_offset = car.custom_minimum_size / 2.0

	var base_y: float = size.y * 0.52 + 18.0
	var start_x: float = -car.custom_minimum_size.x - 60.0
	var end_x: float = size.x + 60.0
	car.position = Vector2(start_x, base_y)

	var move_tween := create_tween()
	move_tween.tween_property(car, "position:x", end_x, 5.5) \
		.set_trans(Tween.TRANS_LINEAR)
	move_tween.finished.connect(func() -> void:
		if _index == CAR_SLIDE_INDEX:
			car.hide()
			_car_slide_locked = false
			prompt.show()
	)
	_car_tweens.append(move_tween)

	var bob_tween := create_tween()
	bob_tween.set_loops()
	bob_tween.tween_property(car, "position:y", base_y - 3.0, 0.16) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tween.parallel().tween_property(car, "rotation_degrees", -1.4, 0.16)
	bob_tween.tween_property(car, "position:y", base_y + 3.0, 0.16) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tween.parallel().tween_property(car, "rotation_degrees", 1.4, 0.16)
	_car_tweens.append(bob_tween)

	_dust_timer = Timer.new()
	_dust_timer.wait_time = 0.2
	add_child(_dust_timer)
	_dust_timer.timeout.connect(func() -> void:
		_spawn_dust_puff()
		_spawn_speed_line()
	)
	_dust_timer.start()

func _stop_car() -> void:
	for tween in _car_tweens:
		if is_instance_valid(tween):
			tween.kill()
	_car_tweens.clear()
	if _dust_timer:
		_dust_timer.stop()
		_dust_timer.queue_free()
		_dust_timer = null
	car.hide()

func _spawn_dust_puff() -> void:
	var puff := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.55, 0.42, 0.28, 0.55)
	style.set_corner_radius_all(1000)
	puff.add_theme_stylebox_override("panel", style)
	var puff_size := Vector2(10, 10)
	puff.size = puff_size
	puff.pivot_offset = puff_size / 2.0
	puff.position = car.position + Vector2(4.0, car.custom_minimum_size.y - 18.0) - puff_size / 2.0
	puff.scale = Vector2(0.4, 0.4)
	puff.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CarLayer.add_child(puff)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(puff, "scale", Vector2(1.8, 1.8), 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(puff, "position:y", puff.position.y + 6.0, 0.55)
	tween.tween_property(puff, "modulate:a", 0.0, 0.55)
	tween.chain().tween_callback(puff.queue_free)

func _spawn_speed_line() -> void:
	var line := ColorRect.new()
	line.color = Color(1, 1, 1, 0.35)
	var line_size := Vector2(18, 2)
	line.size = line_size
	var offset_y: float = randf_range(0.15, 0.75) * car.custom_minimum_size.y
	line.position = car.position + Vector2(-line_size.x - 6.0, offset_y)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CarLayer.add_child(line)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(line, "position:x", line.position.x - 30.0, 0.3)
	tween.tween_property(line, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(line.queue_free)
