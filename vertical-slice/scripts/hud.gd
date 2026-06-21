extends CanvasLayer

@onready var coffee_bar: ProgressBar = $TopBar/CoffeeBar
@onready var coffee_label: Label = $TopBar/CoffeeLabel
@onready var inventory_label: Label = $TopBar/InventoryLabel
@onready var debug_rest_button: Button = $TopBar/DebugRestButton

func _ready() -> void:
	GameState.cafe_alterado.connect(_on_cafe_alterado)
	GameState.recurso_alterado.connect(_on_recurso_alterado)
	debug_rest_button.pressed.connect(_on_debug_rest_button_pressed)
	_on_cafe_alterado(GameState.cafe_atual, GameState.cafe_maximo)
	_atualizar_inventario()

func _on_cafe_alterado(atual: int, maximo: int) -> void:
	coffee_bar.max_value = maximo
	coffee_bar.value = atual
	coffee_label.text = "Cafe: %d/%d" % [atual, maximo]

func _on_recurso_alterado(_tipo: String, _quantidade_total: int) -> void:
	_atualizar_inventario()

func _atualizar_inventario() -> void:
	var partes: Array = []
	for tipo in GameState.recursos.keys():
		partes.append("%s: %d" % [tipo.capitalize(), GameState.recursos[tipo]])
	inventory_label.text = " | ".join(partes)

func _on_debug_rest_button_pressed() -> void:
	GameState.restaurar_cafe()
