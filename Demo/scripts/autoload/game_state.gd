extends Node

signal cafe_alterado(atual: int, maximo: int)
signal recurso_alterado(tipo: String, quantidade_total: int)
signal dia_alterado(dia: int)
signal casa_melhorada(nivel: int)

# --- Balanceamento centralizado (ajustar apos playtest) ---
const DIAS_DA_DEMO: int = 3
const CAFE_INICIAL: int = 5
const DESBLOQUEIO_CURRAL: Dictionary = {"milho": 10}
const DESBLOQUEIO_PAIOL: Dictionary = {"milho": 20, "leite": 5}
const SPAWN_AO_LADO_DA_CASA: Vector2 = Vector2(1010, 332)
const NIVEL_CASA_MAXIMO: int = 3
const CUSTO_UPGRADE_CASA: Dictionary = {
	2: {"milho": 15},
	3: {"madeira": 12, "leite": 10},
}
const CAFE_UPGRADE_CASA: int = 1

var cafe_atual: int = CAFE_INICIAL
var cafe_maximo: int = CAFE_INICIAL
var dia_atual: int = 1
var nivel_casa: int = 1
var zonas_ja_desbloqueadas: Dictionary = {}
var tutorial_visto: bool = false
var ponto_spawn: Vector2 = Vector2(-1, -1)  # -1,-1 = usar posicao padrao do Overworld
var cena_destino: String = ""  # cena que a LoadingScreen deve abrir em seguida
var recursos: Dictionary = {
	"milho": 0,
	"madeira": 0,
	"leite": 0,
	"ovos": 0,
}

func reset() -> void:
	cafe_atual = cafe_maximo
	dia_atual = 1
	nivel_casa = 1
	zonas_ja_desbloqueadas = {}
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
	if zonas_ja_desbloqueadas.get(zona, false):
		return true
	var atende: bool
	match zona:
		"Curral":
			atende = _checar_requisitos(DESBLOQUEIO_CURRAL)
		"Paiol":
			atende = _checar_requisitos(DESBLOQUEIO_PAIOL)
		_:
			atende = true
	if atende:
		zonas_ja_desbloqueadas[zona] = true
	return atende

# --- Upgrade da casa ---

func custo_proximo_nivel_casa() -> Dictionary:
	return CUSTO_UPGRADE_CASA.get(nivel_casa + 1, {})

func pode_melhorar_casa() -> bool:
	if nivel_casa >= NIVEL_CASA_MAXIMO:
		return false
	if cafe_atual < CAFE_UPGRADE_CASA:
		return false
	return _checar_requisitos(custo_proximo_nivel_casa())

func melhorar_casa() -> bool:
	if not pode_melhorar_casa():
		return false
	var custo: Dictionary = custo_proximo_nivel_casa()
	for tipo in custo.keys():
		recursos[tipo] -= custo[tipo]
		recurso_alterado.emit(tipo, recursos[tipo])
	cafe_atual -= CAFE_UPGRADE_CASA
	cafe_alterado.emit(cafe_atual, cafe_maximo)
	nivel_casa += 1
	casa_melhorada.emit(nivel_casa)
	return true

func texto_custo_casa() -> String:
	var custo: Dictionary = custo_proximo_nivel_casa()
	if custo.is_empty():
		return ""
	var partes: Array = []
	for tipo in custo.keys():
		partes.append("%d %s" % [custo[tipo], tipo])
	partes.append("%d cafe" % CAFE_UPGRADE_CASA)
	return ", ".join(partes)

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

func texto_progresso(zona: String) -> String:
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
		partes.append("%s: %d/%d" % [tipo.capitalize(), recursos.get(tipo, 0), req[tipo]])
	return "\n".join(partes)

func dificuldade_puzzle() -> Dictionary:
	match dia_atual:
		1:
			return {"move_delta": 0, "score_delta": 0}
		2:
			return {"move_delta": -2, "score_delta": 50}
		_:
			return {"move_delta": -4, "score_delta": 100}

func _checar_requisitos(req: Dictionary) -> bool:
	for tipo in req.keys():
		if recursos.get(tipo, 0) < req[tipo]:
			return false
	return true
