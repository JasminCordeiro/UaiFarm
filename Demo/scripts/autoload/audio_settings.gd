extends Node

signal music_muted_changed(muted: bool)
signal sfx_muted_changed(muted: bool)

const CONFIG_PATH := "user://audio_settings.cfg"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

var music_muted: bool = false
var sfx_muted: bool = false

func _ready() -> void:
	_load()
	_apply()

func toggle_music() -> void:
	set_music_muted(not music_muted)

func toggle_sfx() -> void:
	set_sfx_muted(not sfx_muted)

func set_music_muted(muted: bool) -> void:
	music_muted = muted
	_apply()
	_save()
	music_muted_changed.emit(music_muted)

func set_sfx_muted(muted: bool) -> void:
	sfx_muted = muted
	_apply()
	_save()
	sfx_muted_changed.emit(sfx_muted)

func _apply() -> void:
	_set_bus_mute(BUS_MUSIC, music_muted)
	_set_bus_mute(BUS_SFX, sfx_muted)

func _set_bus_mute(bus_name: String, muted: bool) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_mute(idx, muted)

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music_muted", music_muted)
	cfg.set_value("audio", "sfx_muted", sfx_muted)
	cfg.save(CONFIG_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) == OK:
		music_muted = cfg.get_value("audio", "music_muted", false)
		sfx_muted = cfg.get_value("audio", "sfx_muted", false)
