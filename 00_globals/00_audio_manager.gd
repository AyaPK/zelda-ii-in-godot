extends Node

@export var master_bus_name: String = "Master"
@export var music_bus_name: String = "Music"
@export var sfx_bus_name: String = "SFX"

var master_bus_idx: int:
	get: return AudioServer.get_bus_index(master_bus_name)

var music_bus_idx: int:
	get: return AudioServer.get_bus_index(music_bus_name)

var sfx_bus_idx: int:
	get: return AudioServer.get_bus_index(sfx_bus_name)

var music_library: Dictionary = {
	"title": preload("res://assets/sound/music/title.mp3"),
	"overworld": preload("res://assets/sound/music/overworld.mp3"),
	"village": preload("res://assets/sound/music/village.mp3"),
	"battle": preload("res://assets/sound/music/battle.mp3"),
}

var sfx_library: Dictionary = {

}

var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = music_bus_name
	add_child(_music_player)

func play_music(music: String) -> void:
	var stream: AudioStream = music_library.get(music)
	if stream == null:
		push_warning("AudioManager: music '" + music + "' not found in music_library")
		return
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stop()
	_music_player.stream = stream
	_music_player.play()

func stop_music() -> void:
	if _music_player and _music_player.playing:
		_music_player.stop()

func play_sfx(sfx: String) -> void:
	var stream: AudioStream = sfx_library.get(sfx)
	if stream == null:
		push_warning("AudioManager: sfx '" + sfx + "' not found in sfx_library")
		return
	var player := get_sfx_player(stream)
	add_child(player)
	player.finished.connect(func() -> void:
		player.queue_free()
	)
	player.play()

func get_sfx_player(stream: AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = sfx_bus_name
	player.stream = stream
	return player
