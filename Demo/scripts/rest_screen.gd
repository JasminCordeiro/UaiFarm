extends Control

const FRASES_FIOTA: Array[String] = [
	"Uai, que dia produtivo! Vamos descansar e continuar amanha, so!",
	"A terra nao mente... e nem o cansaco! Durma bem, Caio!",
	"Todo dia tem seu trabai. Amanha tem mais, pode cre!",
	"O rocado agradece o suor de hoje. Ta ficando bonito, Caio!",
	"Quem planta colhe, fia! So continuar assim...",
]

var is_transitioning: bool = false

func _ready() -> void:
	$Panel/VBoxContainer/ConfirmButton.pressed.connect(_on_confirmar)
	$Panel/VBoxContainer/CancelButton.pressed.connect(_on_cancelar)
	_atualizar_ui()

func _atualizar_ui() -> void:
	$Panel/VBoxContainer/TituloLabel.text = "Hora de descansar"
	$Panel/VBoxContainer/DiaLabel.text = "Dia %d concluido..." % GameState.dia_atual
	var idx: int = (GameState.dia_atual - 1) % FRASES_FIOTA.size()
	$Panel/VBoxContainer/FiotaLabel.text = "Dona Fiota: \"%s\"" % FRASES_FIOTA[idx]
	var proximo: int = GameState.dia_atual + 1
	$Panel/VBoxContainer/StatusLabel.text = "Ao confirmar, o cafe volta ao maximo e o Dia %d comeca." % proximo
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
	GameState.avancar_dia()
	if GameState.demo_concluida():
		get_tree().change_scene_to_file("res://scenes/EndScreen.tscn")
	else:
		GameState.definir_spawn_casa()
		get_tree().change_scene_to_file("res://scenes/Overworld.tscn")

func _on_cancelar() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	$Panel/VBoxContainer/ConfirmButton.disabled = true
	$Panel/VBoxContainer/CancelButton.disabled = true
	GameState.definir_spawn_casa()
	get_tree().change_scene_to_file("res://scenes/Overworld.tscn")
