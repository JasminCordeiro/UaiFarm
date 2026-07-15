extends Node

const BUS_NAME := "Music"

var _theme_stream: AudioStream = preload("res://assets/Audios/joy-ride.ogg")
var _player: AudioStreamPlayer

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.stream = _theme_stream
	_player.bus = BUS_NAME
	if _theme_stream is AudioStreamOggVorbis:
		_theme_stream.loop = true
	add_child(_player)
	_player.play()

func pause() -> void:
	_player.stream_paused = true

func resume() -> void:
	_player.stream_paused = false
