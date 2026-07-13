extends Node

const BUS_NAME := "SFX"

var _win_stream: AudioStream = preload("res://assets/Audios/win-puzzle.wav")
var _lose_stream: AudioStream = preload("res://assets/Audios/fail-puzzle.wav")

func play_win() -> void:
	_play(_win_stream)

func play_lose() -> void:
	_play(_lose_stream)

func _play(stream: AudioStream, pitch_variance: float = 0.0) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = BUS_NAME
	if pitch_variance > 0.0:
		player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
