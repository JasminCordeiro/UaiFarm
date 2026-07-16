extends CanvasLayer

# Ícones em pixel art: emojis não têm fallback de fonte no export Web
const RESOURCE_ICONS: Dictionary = {
	"milho": preload("res://assets/EspigaMilho.png"),
	"graos": preload("res://assets/Racao.png"),
	"leite": preload("res://assets/JarroLeite.png"),
	"ovos": preload("res://assets/Ovos.png"),
}

const COFFEE_ICON: Texture2D = preload("res://assets/coffee-energy.png")
const COFFEE_ICON_SIZE: int = 28
const SETTINGS_PANEL: PackedScene = preload("res://scenes/SettingsPanel.tscn")

@onready var topbar_panel: PanelContainer = $TopBarPanel
@onready var coffee_icons: HBoxContainer = $TopBarPanel/Margin/TopBar/CoffeeIcons
@onready var coffee_label: Label = $TopBarPanel/Margin/TopBar/CoffeeLabel
@onready var day_label: Label = $TopBarPanel/Margin/TopBar/DayLabel
@onready var inventory_label: Label = $TopBarPanel/Margin/TopBar/InventoryLabel
@onready var settings_button: Button = $TopBarPanel/Margin/TopBar/SettingsButton
@onready var reward_toast: Panel = $RewardToast
@onready var reward_icon: TextureRect = $RewardToast/HBoxContainer/RewardIcon
@onready var reward_text_label: Label = $RewardToast/HBoxContainer/RewardTextLabel

var ultimos_totais_recurso: Dictionary = {}
var reward_toast_tween: Tween = null
var reward_toast_tipo_atual: String = ""
var reward_toast_acumulado: int = 0

func _ready() -> void:
	GameState.cafe_alterado.connect(_on_cafe_alterado)
	GameState.recurso_alterado.connect(_on_recurso_alterado)
	GameState.dia_alterado.connect(_on_dia_alterado)
	settings_button.pressed.connect(_on_settings_pressed)
	_on_cafe_alterado(GameState.cafe_atual, GameState.cafe_maximo)
	_on_dia_alterado(GameState.dia_atual)
	_sincronizar_totais_recurso()
	_atualizar_inventario()
	reward_toast.hide()
	# a barra fica encolhida no conteúdo (Café/Dia/Inventário/Botão), não mais esticada pela tela
	topbar_panel.reset_size()

func _on_cafe_alterado(atual: int, maximo: int) -> void:
	while coffee_icons.get_child_count() < maximo:
		var icone := TextureRect.new()
		icone.texture = COFFEE_ICON
		icone.custom_minimum_size = Vector2(COFFEE_ICON_SIZE, COFFEE_ICON_SIZE)
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		coffee_icons.add_child(icone)
	while coffee_icons.get_child_count() > maximo:
		coffee_icons.get_child(coffee_icons.get_child_count() - 1).free()
	for i in range(maximo):
		var icone: TextureRect = coffee_icons.get_child(i)
		if i < atual:
			icone.modulate = Color(1, 1, 1, 1)
		else:
			icone.modulate = Color(0.35, 0.35, 0.35, 0.5)

func _on_dia_alterado(dia: int) -> void:
	day_label.text = "Dia %d" % dia

func _on_recurso_alterado(tipo: String, quantidade_total: int) -> void:
	var total_anterior: int = ultimos_totais_recurso.get(tipo, quantidade_total)
	if quantidade_total > total_anterior:
		_mostrar_toast_recompensa(tipo, quantidade_total - total_anterior)
	ultimos_totais_recurso[tipo] = quantidade_total
	_atualizar_inventario()

func _atualizar_inventario() -> void:
	var partes: Array = []
	for tipo in GameState.recursos.keys():
		partes.append("%s: %d" % [GameState.nome_recurso(tipo), GameState.recursos[tipo]])
	inventory_label.text = " | ".join(partes)
	# o texto muda de tamanho conforme os números crescem; reajusta a barra pro conteúdo novo
	if topbar_panel:
		topbar_panel.reset_size()

func _sincronizar_totais_recurso() -> void:
	for tipo in GameState.recursos.keys():
		ultimos_totais_recurso[tipo] = GameState.recursos[tipo]

func _mostrar_toast_recompensa(tipo: String, ganho: int) -> void:
	var em_andamento: bool = reward_toast.visible and reward_toast_tipo_atual == tipo
	reward_toast_acumulado = reward_toast_acumulado + ganho if em_andamento else ganho
	reward_toast_tipo_atual = tipo
	reward_icon.texture = RESOURCE_ICONS.get(tipo, null)
	reward_icon.visible = reward_icon.texture != null
	reward_text_label.text = "+%d %s" % [reward_toast_acumulado, GameState.nome_recurso(tipo).to_lower()]
	reward_toast.show()
	reward_toast.modulate = Color(1, 1, 1, 0)
	if reward_toast_tween:
		reward_toast_tween.kill()
	reward_toast_tween = create_tween()
	reward_toast_tween.tween_property(reward_toast, "modulate:a", 1.0, 0.12)
	reward_toast_tween.tween_interval(1.0)
	reward_toast_tween.tween_property(reward_toast, "modulate:a", 0.0, 0.22)
	reward_toast_tween.finished.connect(_on_reward_toast_tween_finished, CONNECT_ONE_SHOT)

func _on_reward_toast_tween_finished() -> void:
	reward_toast.hide()
	reward_toast_tipo_atual = ""
	reward_toast_acumulado = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_settings_pressed()

func _on_settings_pressed() -> void:
	if get_tree().paused:
		return
	var panel := SETTINGS_PANEL.instantiate()
	panel.show_game_actions = true
	get_tree().current_scene.add_child(panel)
	get_tree().paused = true
