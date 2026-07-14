extends Node2D

const FALAS_DIA: Dictionary = {
	1: "Vamo comeca, uai! Chega perto do rocado e planta esse milho. A fazenda inteira depende dessa primeira colheita.",
	2: "Bom dia, Caio! Cafe passado fresquinho na garrafa. Junta milho pro celeiro e grao pro curral — cada canto aberto e mais vida pra fazenda!",
	3: "Ultimo dia da lida, meu fio! Mostra tudo que aprendeu e deixa essa fazenda um brinco, que seu avo ia ter orgulho.",
}

@onready var ambiente_principal: Sprite2D = $Principal
@onready var nav_principal: NavigationRegion2D = $"Principal/Acesso Principal - Casa"
@onready var ambiente_curral: Sprite2D = $"Curral-Desbloqueado"
@onready var nav_curral: NavigationRegion2D = $"Curral-Desbloqueado/Curra-Desbloqueado-Navigation"
@onready var ambiente_celeiro: Sprite2D = $"Curral e Celeiro-Desbloqueado"
@onready var nav_celeiro: NavigationRegion2D = $"Curral e Celeiro-Desbloqueado/Celeiro-Desbloqueado-Navigation"
@onready var animais_curral: Array[Node2D] = [$Vaca1, $Vaca2, $Vaca3, $Vaca4, $Vaca5, $Porco1, $Porco2, $Porco3]
@onready var transicao: ColorRect = $Transicao/ColorRect

func _ready() -> void:
	GameState.zona_desbloqueada_manualmente.connect(_on_zona_desbloqueada_manualmente)
	_aplicar_ambiente(GameState.zona_desbloqueada("Celeiro"), GameState.zona_desbloqueada("Curral"))
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
		info_bar.mostrar_mensagem("Dona Fiota", FALAS_DIA[dia], true)

func _on_zona_desbloqueada_manualmente(_zona: String) -> void:
	_transicionar_ambiente(GameState.zona_desbloqueada("Celeiro"), GameState.zona_desbloqueada("Curral"))

func _aplicar_ambiente(celeiro_aberto: bool, curral_aberto: bool) -> void:
	ambiente_celeiro.visible = curral_aberto
	nav_celeiro.enabled = curral_aberto

	ambiente_curral.visible = celeiro_aberto and not curral_aberto
	nav_curral.enabled = celeiro_aberto and not curral_aberto

	ambiente_principal.visible = not curral_aberto and not celeiro_aberto
	nav_principal.enabled = not curral_aberto and not celeiro_aberto

	for animal in animais_curral:
		animal.visible = curral_aberto

func _transicionar_ambiente(celeiro_aberto: bool, curral_aberto: bool) -> void:
	var tween := create_tween()
	tween.tween_property(transicao, "color:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func() -> void: _aplicar_ambiente(celeiro_aberto, curral_aberto))
	tween.tween_property(transicao, "color:a", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
