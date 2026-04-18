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
	"temple": preload("res://assets/sound/music/temple.mp3"),
}

var sfx_library: Dictionary = {
	"barrier": preload("res://assets/sound/sfx/AOL_Barrier.wav"),
	"battle": preload("res://assets/sound/sfx/AOL_Battle.wav"),
	"boomerang": preload("res://assets/sound/sfx/AOL_Boomerang.wav"),
	"bridge": preload("res://assets/sound/sfx/AOL_Bridge.wav"),
	"deflect": preload("res://assets/sound/sfx/AOL_Deflect.wav"),
	"die": preload("res://assets/sound/sfx/AOL_Die.wav"),
	"door": preload("res://assets/sound/sfx/AOL_Door.wav"),
	"elevator": preload("res://assets/sound/sfx/AOL_Elevator.wav"),
	"fairy": preload("res://assets/sound/sfx/AOL_Fairy.wav"),
	"fall": preload("res://assets/sound/sfx/AOL_Fall.wav"),
	"fire": preload("res://assets/sound/sfx/AOL_Fire.wav"),
	"flute": preload("res://assets/sound/sfx/AOL_Flute.wav"),
	"ganon_laugh": preload("res://assets/sound/sfx/AOL_Ganon_Laugh.wav"),
	"hurt": preload("res://assets/sound/sfx/AOL_Hurt.wav"),
	"item_drop": preload("res://assets/sound/sfx/AOL_Item_Drop.wav"),
	"kill": preload("res://assets/sound/sfx/AOL_Kill.wav"),
	"kill_boss": preload("res://assets/sound/sfx/AOL_KillBoss.wav"),
	"learn_spell": preload("res://assets/sound/sfx/AOL_LearnSpell.wav"),
	"levelup_getitem": preload("res://assets/sound/sfx/AOL_LevelUp_GetItem.wav"),
	"low_health": preload("res://assets/sound/sfx/AOL_LowHealth.wav"),
	"map": preload("res://assets/sound/sfx/AOL_Map.wav"),
	"menu_alphabet": preload("res://assets/sound/sfx/AOL_Menu_Alphabet.wav"),
	"menu_erase": preload("res://assets/sound/sfx/AOL_Menu_Erase.wav"),
	"menu_letter": preload("res://assets/sound/sfx/AOL_Menu_Letter.wav"),
	"menu_select": preload("res://assets/sound/sfx/AOL_Menu_Select.wav"),
	"pause": preload("res://assets/sound/sfx/AOL_Pause.wav"),
	"pause_select": preload("res://assets/sound/sfx/AOL_Pause_Select.wav"),
	"shatter": preload("res://assets/sound/sfx/AOL_Shatter.wav"),
	"spell": preload("res://assets/sound/sfx/AOL_Spell.wav"),
	"stats": preload("res://assets/sound/sfx/AOL_Stats.wav"),
	"swamp": preload("res://assets/sound/sfx/AOL_Swamp.wav"),
	"sword": preload("res://assets/sound/sfx/AOL_Sword.wav"),
	"sword_clang": preload("res://assets/sound/sfx/AOL_Sword_Clang.wav"),
	"sword_hit": preload("res://assets/sound/sfx/AOL_Sword_Hit.wav"),
	"sword_shoot": preload("res://assets/sound/sfx/AOL_Sword_Shoot.wav"),
	"text": preload("res://assets/sound/sfx/AOL_Text.wav"),
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
