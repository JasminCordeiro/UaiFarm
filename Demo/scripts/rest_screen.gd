extends Control

const FRASES_FIOTA: Array[String] = [
	"Uai, que dia produtivo! Vamos descansar e continuar amanha, so!",
	"A terra nao mente... e nem o cansaco! Durma bem, Caio!",
	"Todo dia tem seu trabai. Amanha tem mais, pode cre!",
	"O rocado agradece o suor de hoje. Ta ficando bonito, Caio!",
	"Quem planta colhe, fia! So continuar assim...",
]

func _ready() -> void:
	$Panel/VBoxContainer/ConfirmButton.pressed.connect(_on_confirmar)
	$Panel/VBoxContainer/CancelButton.pressed.connect(_on_cancelar)
	_atualizar_ui()

func _atualizar_ui() -> void:
	$Panel/VBoxContainer/DiaLabel.text = "Dia %d concluido..." % GameState.dia_atual
	var idx: int = (GameState.dia_atual - 1) % FRASES_FIOTA.size()
	$Panel/VBoxContainer/FiotaLabel.text = "Dona Fiota: \"%s\"" % FRASES_FIOTA[idx]
	var proximo: int = GameState.dia_atual + 1
	if proximo > GameState.DIAS_DA_DEMO:
		$Panel/VBoxContainer/ConfirmButton.text = "Encerrar Demo"
	else:
		$Panel/VBoxContainer/ConfirmButton.text = "Iniciar Dia %d" % proximo

func _on_confirmar() -> void:
	GameState.avancar_dia()
	if GameState.demo_concluida():
		get_tree().change_scene_to_file("res://scenes/EndScreen.tscn")
	else:
		GameState.ponto_spawn = Vector2(200, 140)  # ao lado da Casa de Caio
		get_tree().change_scene_to_file("res://scenes/Overworld.tscn")

func _on_cancelar() -> void:
	get_tree().change_scene_to_file("res://scenes/Overworld.tscn")
