extends Node

signal cafe_alterado(atual: int, maximo: int)
signal recurso_alterado(tipo: String, quantidade_total: int)
signal dia_alterado(dia: int)
signal casa_melhorada(nivel: int)
signal zona_desbloqueada_manualmente(zona: String)

# --- Balanceamento centralizado (ajustar apos playtest) ---
const DIAS_DA_DEMO: int = 3
const CAFE_INICIAL: int = 5
const DESBLOQUEIO_CELEIRO: Dictionary = {"milho": 10}
const DESBLOQUEIO_CURRAL: Dictionary = {"milho": 20, "graos": 5}
const SPAWN_AO_LADO_DA_CASA: Vector2 = Vector2(1010, 332)
const NIVEL_CASA_MAXIMO: int = 2
const CUSTO_UPGRADE_CASA: Dictionary = {
	2: {"milho": 15},
}
const CAFE_UPGRADE_CASA: int = 1

var cafe_atual: int = CAFE_INICIAL
var cafe_maximo: int = CAFE_INICIAL
var dia_atual: int = 1
var nivel_casa: int = 1
var zonas_ja_desbloqueadas: Dictionary = {}
var tutorial_visto: bool = false
var dialogo_dia_mostrado: Dictionary = {}
var ponto_spawn: Vector2 = Vector2(-1, -1)  # -1,-1 = usar posicao padrao do Overworld
var cena_destino: String = ""  # cena que a LoadingScreen deve abrir em seguida
var recursos: Dictionary = {
	"milho": 0,
	"graos": 0,
	"leite": 0,
	"ovos": 0,
}

func reset() -> void:
	cafe_atual = cafe_maximo
	dia_atual = 1
	nivel_casa = 1
	zonas_ja_desbloqueadas = {}
	tutorial_visto = false
	dialogo_dia_mostrado = {}
	ponto_spawn = Vector2(-1, -1)
	recursos = {"milho": 0, "graos": 0, "leite": 0, "ovos": 0}
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
	return zonas_ja_desbloqueadas.get(zona, false)

func requisitos_zona_atendidos(zona: String) -> bool:
	match zona:
		"Curral":
			return _checar_requisitos(DESBLOQUEIO_CURRAL)
		"Celeiro":
			return _checar_requisitos(DESBLOQUEIO_CELEIRO)
		_:
			return true

func desbloquear_zona(zona: String) -> void:
	if zonas_ja_desbloqueadas.get(zona, false):
		return
	zonas_ja_desbloqueadas[zona] = true
	zona_desbloqueada_manualmente.emit(zona)
	Sfx.play_desbloqueio_zona()

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
	Sfx.play_reforma_casa()
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
		"Celeiro":
			req = DESBLOQUEIO_CELEIRO
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
		"Celeiro":
			req = DESBLOQUEIO_CELEIRO
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
