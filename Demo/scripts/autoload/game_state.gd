extends Node

signal cafe_alterado(atual: int, maximo: int)
signal recurso_alterado(tipo: String, quantidade_total: int)
signal dia_alterado(dia: int)

# --- Balanceamento centralizado (ajustar apos playtest) ---
const DIAS_DA_DEMO: int = 3
const CAFE_INICIAL: int = 5
const DESBLOQUEIO_CURRAL: Dictionary = {"milho": 10}
const DESBLOQUEIO_PAIOL: Dictionary = {"milho": 20, "leite": 5}
const SPAWN_AO_LADO_DA_CASA: Vector2 = Vector2(210, 140)

var cafe_atual: int = CAFE_INICIAL
var cafe_maximo: int = CAFE_INICIAL
var dia_atual: int = 1
var tutorial_visto: bool = false
var ponto_spawn: Vector2 = Vector2(-1, -1)  # -1,-1 = usar posicao padrao do Overworld
var recursos: Dictionary = {
	"milho": 0,
	"madeira": 0,
	"leite": 0,
	"ovos": 0,
}

func reset() -> void:
	cafe_atual = cafe_maximo
	dia_atual = 1
	tutorial_visto = false
	ponto_spawn = Vector2(-1, -1)
	recursos = {"milho": 0, "madeira": 0, "leite": 0, "ovos": 0}
	cafe_alterado.emit(cafe_atual, cafe_maximo)
	dia_alterado.emit(dia_atual)

func definir_spawn_casa() -> void:
	ponto_spawn = SPAWN_AO_LADO_DA_CASA

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

func avancar_dia() -> void:
	dia_atual += 1
	restaurar_cafe()
	dia_alterado.emit(dia_atual)

func demo_concluida() -> bool:
	return dia_atual > DIAS_DA_DEMO

func zona_desbloqueada(zona: String) -> bool:
	match zona:
		"Curral":
			return _checar_requisitos(DESBLOQUEIO_CURRAL)
		"Paiol":
			return _checar_requisitos(DESBLOQUEIO_PAIOL)
		_:
			return true

func texto_requisito(zona: String) -> String:
	var req: Dictionary = {}
	match zona:
		"Curral":
			req = DESBLOQUEIO_CURRAL
		"Paiol":
			req = DESBLOQUEIO_PAIOL
		_:
			return ""
	var partes: Array = []
	for tipo in req.keys():
		partes.append("%d %s" % [req[tipo], tipo])
	return "Bloqueado — precisa: " + ", ".join(partes)

func _checar_requisitos(req: Dictionary) -> bool:
	for tipo in req.keys():
		if recursos.get(tipo, 0) < req[tipo]:
			return false
	return true
