extends CanvasLayer

func _ready() -> void:
	if GameState.tutorial_visto:
		queue_free()
		return
	$Panel/VBoxContainer/FecharButton.pressed.connect(_fechar)

func _fechar() -> void:
	GameState.tutorial_visto = true
	queue_free()

func fechar_apos_primeiro_puzzle() -> void:
	if not GameState.tutorial_visto:
		_fechar()
