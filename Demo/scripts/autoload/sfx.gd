extends Node

const BUS_NAME := "SFX"

var _win_stream: AudioStream = preload("res://assets/Audios/win-puzzle.wav")
var _lose_stream: AudioStream = preload("res://assets/Audios/fail-puzzle.wav")
var _match_stream: AudioStream = preload("res://assets/Audios/combinar-pares.wav")
var _move_stream: AudioStream = preload("res://assets/Audios/mover-peca-puzzle.wav")
var _reforma_stream: AudioStream = preload("res://assets/Audios/reforma-casa.ogg")
var _desbloqueio_stream: AudioStream = preload("res://assets/Audios/desbloquear-zona.wav")
var _descanso_stream: AudioStream = preload("res://assets/Audios/descansar-dia.wav")

func play_win() -> void:
	_play(_win_stream)

func play_lose() -> void:
	_play(_lose_stream)

func play_match() -> void:
	_play(_match_stream)

func play_move() -> void:
	_play(_move_stream)

func play_reforma_casa() -> void:
	_play(_reforma_stream)

func play_desbloqueio_zona() -> void:
	_play(_desbloqueio_stream)

func play_descanso() -> void:
	var player := _play(_descanso_stream)
	# A música do dia só volta depois que o galo (som de descanso) termina de tocar
	if player:
		player.finished.connect(Music.resume)

func _play(stream: AudioStream, pitch_variance: float = 0.0) -> AudioStreamPlayer:
	if stream == null:
		return null
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = BUS_NAME
	if pitch_variance > 0.0:
		player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	return player
