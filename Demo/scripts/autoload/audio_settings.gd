extends Node

signal music_muted_changed(muted: bool)
signal sfx_muted_changed(muted: bool)
signal music_volume_changed(volume: float)
signal sfx_volume_changed(volume: float)

const CONFIG_PATH := "user://audio_settings.cfg"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"
const VOLUME_MINIMA_DB := -40.0

var music_muted: bool = false
var sfx_muted: bool = false
var music_volume: float = 1.0  # 0.0 (silêncio) a 1.0 (volume total)
var sfx_volume: float = 1.0  # 0.0 (silêncio) a 1.0 (volume total)

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

func set_music_volume(volume: float) -> void:
	music_volume = clampf(volume, 0.0, 1.0)
	_apply()
	_save()
	music_volume_changed.emit(music_volume)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	_apply()
	_save()
	sfx_volume_changed.emit(sfx_volume)

func _apply() -> void:
	_set_bus_mute(BUS_MUSIC, music_muted)
	_set_bus_mute(BUS_SFX, sfx_muted)
	_set_bus_volume(BUS_MUSIC, music_volume)
	_set_bus_volume(BUS_SFX, sfx_volume)

func _set_bus_mute(bus_name: String, muted: bool) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_mute(idx, muted)

func _set_bus_volume(bus_name: String, volume_linear: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, lerpf(VOLUME_MINIMA_DB, 0.0, volume_linear))

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music_muted", music_muted)
	cfg.set_value("audio", "sfx_muted", sfx_muted)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "sfx_volume", sfx_volume)
	cfg.save(CONFIG_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) == OK:
		music_muted = cfg.get_value("audio", "music_muted", false)
		sfx_muted = cfg.get_value("audio", "sfx_muted", false)
		music_volume = cfg.get_value("audio", "music_volume", 1.0)
		sfx_volume = cfg.get_value("audio", "sfx_volume", 1.0)
