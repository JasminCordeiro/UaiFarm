extends Node

signal cafe_alterado(atual: int, maximo: int)
signal recurso_alterado(tipo: String, quantidade_total: int)

var cafe_atual: int = 5
var cafe_maximo: int = 5
var recursos: Dictionary = {
	"milho": 0,
	"madeira": 0,
	"leite": 0,
	"ovos": 0
}

func consumir_cafe() -> bool:
	if cafe_atual <= 0:
		return false
	cafe_atual -= 1
	cafe_alterado.emit(cafe_atual, cafe_maximo)
	return true

func restaurar_cafe() -> void:
	cafe_atual = cafe_maximo
	cafe_alterado.emit(cafe_atual, cafe_maximo)

func adicionar_recurso(tipo: String, quantidade: int) -> void:
	if recursos.has(tipo):
		recursos[tipo] += quantidade
		recurso_alterado.emit(tipo, recursos[tipo])
