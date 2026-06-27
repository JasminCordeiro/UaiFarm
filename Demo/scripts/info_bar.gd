extends CanvasLayer

const FALA_TUTORIAL: String = "Uai, meu filho! O rocado ta precisando de cuidado. Chega perto dele e aperta o botao pra comecar!"
const TUTORIAL_DURATION: float = 4.0

@onready var painel: Panel = $Control/Panel
@onready var nome_label: Label = $Control/Panel/HBox/NomeLabel
@onready var mensagem_label: Label = $Control/Panel/HBox/MensagemLabel
@onready var fechar_button: Button = $Control/Panel/HBox/FecharButton

var tutorial_ativo: bool = false

func _ready() -> void:
	add_to_group("info_bar")
	fechar_button.pressed.connect(_fechar)
	if not GameState.tutorial_visto:
		mostrar_mensagem("Dona Fiota", FALA_TUTORIAL, true, true)
	else:
		painel.hide()

func mostrar_mensagem(nome: String, texto: String, auto_fechar: bool = true, marcar_como_tutorial: bool = false) -> void:
	tutorial_ativo = marcar_como_tutorial
	nome_label.text = nome + ":"
	mensagem_label.text = texto
	painel.show()
	if auto_fechar:
		await get_tree().create_timer(TUTORIAL_DURATION).timeout
		if is_instance_valid(painel) and painel.visible:
			if tutorial_ativo:
				GameState.tutorial_visto = true
				tutorial_ativo = false
			painel.hide()

func _fechar() -> void:
	if tutorial_ativo:
		GameState.tutorial_visto = true
		tutorial_ativo = false
	painel.hide()
