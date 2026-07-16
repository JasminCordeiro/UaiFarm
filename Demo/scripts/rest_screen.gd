extends Control

const FRASES_FIOTA: Array[String] = [
	"Uai, que dia produtivo! Vamos descansar e continuar amanhã, só!",
	"A terra não mente... e nem o cansaço! Durma bem, Caio!",
	"Todo dia tem seu trabai. Amanhã tem mais, pode cre!",
	"O roçado agradece o suor de hoje. Tá ficando bonito, Caio!",
	"Quem planta colhe, fia! Só continuar assim...",
]

var is_transitioning: bool = false

@onready var crickets_player: AudioStreamPlayer = $CricketsPlayer

func _ready() -> void:
	$Panel/VBoxContainer/ConfirmButton.pressed.connect(_on_confirmar)
	$Panel/VBoxContainer/CancelButton.pressed.connect(_on_cancelar)
	_atualizar_ui()
	# Enquanto o jogador decide, a musica do dia para e so o som de grilos toca
	Music.pause()
	if crickets_player.stream is AudioStreamMP3:
		crickets_player.stream.loop = true
	crickets_player.play()

func _atualizar_ui() -> void:
	$Panel/VBoxContainer/TituloLabel.text = "Hora de descansar"
	$Panel/VBoxContainer/DiaLabel.text = "Dia %d concluído..." % GameState.dia_atual
	var idx: int = (GameState.dia_atual - 1) % FRASES_FIOTA.size()
	$Panel/VBoxContainer/FiotaLabel.text = "Dona Fiota: \"%s\"" % FRASES_FIOTA[idx]
	var proximo: int = GameState.dia_atual + 1
	$Panel/VBoxContainer/StatusLabel.text = "Ao confirmar, o café volta ao máximo e o Dia %d começa." % proximo
	if proximo > GameState.DIAS_DA_DEMO:
		$Panel/VBoxContainer/ConfirmButton.text = "Encerrar Demo"
	else:
		$Panel/VBoxContainer/ConfirmButton.text = "Iniciar Dia %d" % proximo
	$Panel/VBoxContainer/ConfirmButton.disabled = false
	$Panel/VBoxContainer/CancelButton.disabled = false

func _on_confirmar() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	$Panel/VBoxContainer/ConfirmButton.disabled = true
	$Panel/VBoxContainer/CancelButton.disabled = true
	crickets_player.stop()
	GameState.avancar_dia()
	if GameState.demo_concluida():
		# Fim da demo: sem som de galo, so a musica ambiente volta a tocar
		Music.resume()
		get_tree().change_scene_to_file("res://scenes/EndScreen.tscn")
	else:
		Sfx.play_descanso()  # a musica do dia volta a tocar sozinha quando esse som terminar
		GameState.definir_spawn_casa()
		get_tree().change_scene_to_file("res://scenes/Overworld.tscn")

func _on_cancelar() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	$Panel/VBoxContainer/ConfirmButton.disabled = true
	$Panel/VBoxContainer/CancelButton.disabled = true
	crickets_player.stop()
	Music.resume()
	GameState.definir_spawn_casa()
	get_tree().change_scene_to_file("res://scenes/Overworld.tscn")
