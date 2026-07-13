extends CanvasLayer

func _ready() -> void:
	$Center/Panel/VBoxContainer/BackButton.pressed.connect(_on_voltar)
	_montar_resumo()

func _montar_resumo() -> void:
	var dias_jogados: int = GameState.dia_atual - 1
	$Center/Panel/VBoxContainer/TituloLabel.text = "Demo Concluida!"
	$Center/Panel/VBoxContainer/DiasLabel.text = "Dias jogados: %d" % dias_jogados

	var partes: Array = []
	for tipo in GameState.recursos.keys():
		if GameState.recursos[tipo] > 0:
			partes.append("  %s: %d" % [tipo.capitalize(), GameState.recursos[tipo]])
	if partes.is_empty():
		$Center/Panel/VBoxContainer/RecursosLabel.text = "Recursos coletados: nenhum"
	else:
		$Center/Panel/VBoxContainer/RecursosLabel.text = "Recursos coletados:\n" + "\n".join(partes)

	var zonas: Array[String] = ["Rocado"]
	if GameState.zona_desbloqueada("Curral"):
		zonas.append("Curral")
	if GameState.zona_desbloqueada("Celeiro"):
		zonas.append("Celeiro")
	$Center/Panel/VBoxContainer/ZonasLabel.text = "Zonas visitaveis: " + ", ".join(zonas)

func _on_voltar() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
