extends CanvasLayer

const FALA_TUTORIAL: String = "Uai, meu filho! O rocado ta precisando de cuidado. Anda com WASD/setas ou clique no chao, chega perto e aperta E pra trabalhar!"
const TUTORIAL_DURATION: float = 4.0

@onready var painel: Panel = $Control/Panel
@onready var nome_label: Label = $Control/Panel/VBox/NomeLabel
@onready var mensagem_label: Label = $Control/Panel/VBox/MensagemLabel
@onready var fechar_button: Button = $Control/Panel/FecharButton
@onready var portrait: TextureRect = $Control/Panel/Portrait

const PORTRAITS: Dictionary = {
	"Dona Fiota": "res://assets/dona_fiota_portrait.png",
}

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
	_atualizar_portrait(nome)
	painel.pivot_offset = painel.size / 2.0
	painel.scale = Vector2(0.7, 0.7)
	painel.modulate.a = 0.0
	painel.show()
	var pop := create_tween().set_parallel(true)
	pop.tween_property(painel, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(painel, "modulate:a", 1.0, 0.15)
	if auto_fechar:
		await get_tree().create_timer(TUTORIAL_DURATION).timeout
		if is_instance_valid(painel) and painel.visible:
			if tutorial_ativo:
				GameState.tutorial_visto = true
				tutorial_ativo = false
			painel.hide()
			portrait.hide()

func _atualizar_portrait(nome: String) -> void:
	var path: String = PORTRAITS.get(nome, "")
	if path != "":
		var tex: Texture2D = load(path)
		if tex:
			portrait.texture = tex
			portrait.show()
			return
	portrait.hide()

func _fechar() -> void:
	if tutorial_ativo:
		GameState.tutorial_visto = true
		tutorial_ativo = false
	painel.hide()
	portrait.hide()
