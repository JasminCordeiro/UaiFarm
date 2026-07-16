extends Node2D

const FALAS_DIA: Dictionary = {
	1: "Vamo comeca, uai! Chega perto do rocado e planta esse milho. A fazenda inteira depende dessa primeira colheita.",
	2: "Bom dia, Caio! Cafe passado fresquinho na garrafa. Junta milho pro celeiro e grao pro curral — cada canto aberto e mais vida pra fazenda!",
	3: "Ultimo dia da lida, meu fio! Mostra tudo que aprendeu e deixa essa fazenda um brinco, que seu avo ia ter orgulho.",
}

# Enquanto a casa nao chega no nivel maximo E o cercado nao e reformado, usa o mapa padrao.
# So troca pro mapa reformado quando os dois aprimoramentos estiverem completos.
const BG_PADRAO: Texture2D = preload("res://assets/Background-Principal-Farm.png")
const BG_CASA_E_CERCADO_REFORMADOS: Texture2D = preload("res://assets/Background-Farm-CasaNivel3-CercadoReformado.png")

@onready var animais_curral: Array[Node2D] = [$Vaca1, $Vaca2, $Vaca3, $Vaca4, $Vaca5, $Porco1, $Porco2, $Porco3]
@onready var transicao: ColorRect = $Transicao/ColorRect
@onready var background_sprite: Sprite2D = $Principal

func _ready() -> void:
	GameState.zona_desbloqueada_manualmente.connect(_on_zona_desbloqueada_manualmente)
	GameState.casa_melhorada.connect(_on_progresso_reforma)
	GameState.cercado_melhorado.connect(_on_progresso_reforma)
	_atualizar_background()
	_aplicar_ambiente(GameState.zona_desbloqueada("Curral"))
	if GameState.ponto_spawn != Vector2(-1, -1):
		var player: Node2D = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = GameState.ponto_spawn
		GameState.ponto_spawn = Vector2(-1, -1)
	_mostrar_fala_do_dia()

func _mostrar_fala_do_dia() -> void:
	var dia: int = GameState.dia_atual
	if GameState.dialogo_dia_mostrado.get(dia, false):
		return
	if dia == 1 and not GameState.tutorial_visto:
		# No dia 1 a fala de tutorial da InfoBar ja cumpre esse papel
		GameState.dialogo_dia_mostrado[dia] = true
		return
	GameState.dialogo_dia_mostrado[dia] = true
	if not FALAS_DIA.has(dia):
		return
	var info_bar = get_tree().get_first_node_in_group("info_bar")
	if info_bar:
		info_bar.mostrar_mensagem("Dona Fiota", FALAS_DIA[dia], false, true)

func _on_zona_desbloqueada_manualmente(_zona: String) -> void:
	_transicionar_ambiente(GameState.zona_desbloqueada("Curral"))

func _on_progresso_reforma(_nivel: int = -1) -> void:
	_atualizar_background()

func _atualizar_background() -> void:
	var tudo_reformado: bool = GameState.nivel_casa >= GameState.NIVEL_CASA_MAXIMO and GameState.cercado_reformado
	background_sprite.texture = BG_CASA_E_CERCADO_REFORMADOS if tudo_reformado else BG_PADRAO

func _aplicar_ambiente(curral_aberto: bool) -> void:
	for animal in animais_curral:
		animal.visible = curral_aberto

func _transicionar_ambiente(curral_aberto: bool) -> void:
	var tween := create_tween()
	tween.tween_property(transicao, "color:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func() -> void: _aplicar_ambiente(curral_aberto))
	tween.tween_property(transicao, "color:a", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
