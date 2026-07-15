extends CanvasLayer

const FALA_TUTORIAL: String = "Uai, meu filho! O rocado ta precisando de cuidado. Anda com WASD/setas ou clique no chao, chega perto e aperta E pra trabalhar!"

@onready var click_catcher: Control = $Control/ClickCatcher
@onready var painel: Panel = $Control/Panel
@onready var nome_label: Label = $Control/Panel/VBox/NomeLabel
@onready var mensagem_label: Label = $Control/Panel/VBox/MensagemLabel
@onready var fechar_button: Button = $Control/Panel/FecharButton
@onready var portrait: TextureRect = $Control/Panel/Portrait

const PORTRAITS: Dictionary = {
	"Dona Fiota": "res://assets/dona_fiota_portrait.png",
}

var tutorial_ativo: bool = false
var fechar_no_movimento: bool = false

func _ready() -> void:
	add_to_group("info_bar")
	fechar_button.pressed.connect(_fechar)
	click_catcher.gui_input.connect(_on_click_catcher_input)
	if not GameState.tutorial_visto:
		mostrar_mensagem("Dona Fiota", FALA_TUTORIAL, true, true)
	else:
		painel.hide()

func _input(event: InputEvent) -> void:
	if not fechar_no_movimento or not painel.visible:
		return
	if event is InputEventMouseMotion:
		_fechar()
	elif event.is_action_pressed("mover_cima") or event.is_action_pressed("mover_baixo") \
			or event.is_action_pressed("mover_esquerda") or event.is_action_pressed("mover_direita"):
		_fechar()

func _on_click_catcher_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) \
			or (event is InputEventScreenTouch and event.pressed):
		_fechar()

func mostrar_mensagem(nome: String, texto: String, marcar_como_tutorial: bool = false, fechar_ao_mover: bool = false) -> void:
	tutorial_ativo = marcar_como_tutorial
	fechar_no_movimento = fechar_ao_mover
	nome_label.text = nome + ":"
	mensagem_label.text = texto
	_atualizar_portrait(nome)
	painel.pivot_offset = painel.size / 2.0
	painel.scale = Vector2(0.7, 0.7)
	painel.modulate.a = 0.0
	painel.show()
	click_catcher.show()
	var pop := create_tween().set_parallel(true)
	pop.tween_property(painel, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(painel, "modulate:a", 1.0, 0.15)

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
	fechar_no_movimento = false
	painel.hide()
	portrait.hide()
	click_catcher.hide()

func fechar_por_distancia() -> void:
	if tutorial_ativo or not painel.visible:
		return
	painel.hide()
	portrait.hide()
	click_catcher.hide()

func fechar_para_nova_acao() -> void:
	if not painel.visible:
		return
	_fechar()
