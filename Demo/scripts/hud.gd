extends CanvasLayer

const RESOURCE_ICONS: Dictionary = {
	"milho": "🌽",
	"madeira": "🪵",
	"leite": "🥛",
	"ovos": "🥚",
}

@onready var coffee_bar: ProgressBar = $TopBar/CoffeeBar
@onready var coffee_label: Label = $TopBar/CoffeeLabel
@onready var day_label: Label = $TopBar/DayLabel
@onready var inventory_label: Label = $TopBar/InventoryLabel
@onready var encerrar_button: Button = $TopBar/EncerrarButton
@onready var reward_toast: Panel = $RewardToast
@onready var reward_icon_label: Label = $RewardToast/HBoxContainer/RewardIconLabel
@onready var reward_text_label: Label = $RewardToast/HBoxContainer/RewardTextLabel

var ultimos_totais_recurso: Dictionary = {}
var reward_toast_tween: Tween = null

func _ready() -> void:
	GameState.cafe_alterado.connect(_on_cafe_alterado)
	GameState.recurso_alterado.connect(_on_recurso_alterado)
	GameState.dia_alterado.connect(_on_dia_alterado)
	encerrar_button.pressed.connect(_on_encerrar_pressed)
	_on_cafe_alterado(GameState.cafe_atual, GameState.cafe_maximo)
	_on_dia_alterado(GameState.dia_atual)
	_sincronizar_totais_recurso()
	_atualizar_inventario()
	reward_toast.hide()

func _on_cafe_alterado(atual: int, maximo: int) -> void:
	coffee_bar.max_value = maximo
	coffee_bar.value = atual
	coffee_label.text = "Cafe: %d/%d" % [atual, maximo]

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
		partes.append("%s: %d" % [tipo.capitalize(), GameState.recursos[tipo]])
	inventory_label.text = " | ".join(partes)

func _sincronizar_totais_recurso() -> void:
	for tipo in GameState.recursos.keys():
		ultimos_totais_recurso[tipo] = GameState.recursos[tipo]

func _mostrar_toast_recompensa(tipo: String, ganho: int) -> void:
	reward_icon_label.text = RESOURCE_ICONS.get(tipo, "+")
	reward_text_label.text = "+%d %s" % [ganho, tipo]
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

func _on_encerrar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/EndScreen.tscn")
