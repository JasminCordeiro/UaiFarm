extends CanvasLayer

@onready var coffee_bar: ProgressBar = $TopBar/CoffeeBar
@onready var coffee_label: Label = $TopBar/CoffeeLabel
@onready var day_label: Label = $TopBar/DayLabel
@onready var inventory_label: Label = $TopBar/InventoryLabel
@onready var encerrar_button: Button = $TopBar/EncerrarButton

func _ready() -> void:
	GameState.cafe_alterado.connect(_on_cafe_alterado)
	GameState.recurso_alterado.connect(_on_recurso_alterado)
	GameState.dia_alterado.connect(_on_dia_alterado)
	encerrar_button.pressed.connect(_on_encerrar_pressed)
	_on_cafe_alterado(GameState.cafe_atual, GameState.cafe_maximo)
	_on_dia_alterado(GameState.dia_atual)
	_atualizar_inventario()

func _on_cafe_alterado(atual: int, maximo: int) -> void:
	coffee_bar.max_value = maximo
	coffee_bar.value = atual
	coffee_label.text = "Cafe: %d/%d" % [atual, maximo]

func _on_dia_alterado(dia: int) -> void:
	day_label.text = "Dia %d" % dia

func _on_recurso_alterado(_tipo: String, _quantidade_total: int) -> void:
	_atualizar_inventario()

func _atualizar_inventario() -> void:
	var partes: Array = []
	for tipo in GameState.recursos.keys():
		partes.append("%s: %d" % [tipo.capitalize(), GameState.recursos[tipo]])
	inventory_label.text = " | ".join(partes)

func _on_encerrar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/EndScreen.tscn")
