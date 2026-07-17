extends Node

signal cafe_alterado(atual: int, maximo: int)
signal recurso_alterado(tipo: String, quantidade_total: int)
signal dia_alterado(dia: int)
signal casa_melhorada(nivel: int)
signal cercado_melhorado()
signal zona_desbloqueada_manualmente(zona: String)

# --- Balanceamento centralizado (ajustar após playtest) ---
const DIAS_DA_DEMO: int = 3
const CAFE_INICIAL: int = 5
const DESBLOQUEIO_CELEIRO: Dictionary = {"milho": 10}
const DESBLOQUEIO_CURRAL: Dictionary = {"milho": 20, "graos": 5}
const SPAWN_AO_LADO_DA_CASA: Vector2 = Vector2(1010, 332)
const NIVEL_CASA_MAXIMO: int = 3
const CUSTO_UPGRADE_CASA: Dictionary = {
	2: {"milho": 15},
	3: {"milho": 25, "leite": 10, "graos": 8},
}
const CAFE_UPGRADE_CASA: int = 1
# Só pode ser reformado depois que a casa chega no NIVEL_CASA_REFORMA_CERCADO
const NIVEL_CASA_REFORMA_CERCADO: int = 2
const CUSTO_REFORMA_CERCADO: Dictionary = {"milho": 8, "leite": 8}
const CAFE_REFORMA_CERCADO: int = 1

var cafe_atual: int = CAFE_INICIAL
var cafe_maximo: int = CAFE_INICIAL
var dia_atual: int = 1
var nivel_casa: int = 1
var cercado_reformado: bool = false
# Milho plantado no Roçado: a cena é recriada ao descansar, então o plantio
# fica guardado aqui e é replantado (já maduro) no dia seguinte.
# Cada item: {"indice": posição na fileira, "qtd": milhos da planta}
var plantio_pendente: Array = []
var zonas_ja_desbloqueadas: Dictionary = {}
var tutorial_visto: bool = false
var dialogo_dia_mostrado: Dictionary = {}
var ponto_spawn: Vector2 = Vector2(-1, -1)  # -1,-1 = usar posição padrão do Overworld
var cena_destino: String = ""  # cena que a LoadingScreen deve abrir em seguida
var recursos: Dictionary = {
	"milho": 0,
	"graos": 0,
	"leite": 0,
	"ovos": 0,
}

# Nome acentuado pra exibição em UI — as chaves em "recursos" ficam sem acento
# de propósito (são identificadores usados em comparações e save/load)
const NOMES_RECURSOS: Dictionary = {
	"milho": "Milho",
	"graos": "Grãos",
	"leite": "Leite",
	"ovos": "Ovos",
}

func nome_recurso(tipo: String) -> String:
	return NOMES_RECURSOS.get(tipo, tipo.capitalize())

func reset() -> void:
	cafe_atual = cafe_maximo
	dia_atual = 1
	nivel_casa = 1
	cercado_reformado = false
	plantio_pendente = []
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
		partes.append("%d %s" % [custo[tipo], nome_recurso(tipo).to_lower()])
	partes.append("%d café" % CAFE_UPGRADE_CASA)
	return ", ".join(partes)

# --- Reforma do cercado (Curral) ---
# Libera a partir da casa nível 2; usa recursos do próprio Curral (leite)

func pode_reformar_cercado() -> bool:
	if cercado_reformado:
		return false
	if nivel_casa < NIVEL_CASA_REFORMA_CERCADO:
		return false
	if cafe_atual < CAFE_REFORMA_CERCADO:
		return false
	return _checar_requisitos(CUSTO_REFORMA_CERCADO)

func reformar_cercado() -> bool:
	if not pode_reformar_cercado():
		return false
	for tipo in CUSTO_REFORMA_CERCADO.keys():
		recursos[tipo] -= CUSTO_REFORMA_CERCADO[tipo]
		recurso_alterado.emit(tipo, recursos[tipo])
	cafe_atual -= CAFE_REFORMA_CERCADO
	cafe_alterado.emit(cafe_atual, cafe_maximo)
	cercado_reformado = true
	cercado_melhorado.emit()
	Sfx.play_reforma_casa()
	return true

func texto_custo_cercado() -> String:
	var partes: Array = []
	for tipo in CUSTO_REFORMA_CERCADO.keys():
		partes.append("%d %s" % [CUSTO_REFORMA_CERCADO[tipo], nome_recurso(tipo).to_lower()])
	partes.append("%d café" % CAFE_REFORMA_CERCADO)
	return ", ".join(partes)

func texto_bloqueio_cercado() -> String:
	if nivel_casa < NIVEL_CASA_REFORMA_CERCADO:
		return "Uai, primeiro melhora a casa (nível %d) pra depois cuidar do cercado!" % NIVEL_CASA_REFORMA_CERCADO
	return "Pra reformar o cercado precisa de: %s. Ainda falta coisa, uai!" % texto_custo_cercado()

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
		partes.append("%d %s" % [req[tipo], nome_recurso(tipo).to_lower()])
	return "Bloqueado - precisa: " + ", ".join(partes)

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
		partes.append("%s: %d/%d" % [nome_recurso(tipo), recursos.get(tipo, 0), req[tipo]])
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
