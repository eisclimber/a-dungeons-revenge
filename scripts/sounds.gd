extends Node


const BUTTON_UP: AudioStream = preload("res://sounds/ButtonPressed.wav")
const BUTTON_DOWN: AudioStream = preload("res://sounds/ButtonReleased.wav")

const SPIKES: AudioStream = preload("res://sounds/Slash.wav")
const GHOST: AudioStream = preload("res://sounds/GhostSigh.wav")
const SLIME: AudioStream = preload("res://sounds/SlimeJump.wav")
const SWORD: AudioStream = preload("res://sounds/SwordUnsheath.wav")
const SHIELD: AudioStream = preload("res://sounds/HeavyWoodHitSingle.wav")
const BANDAID: AudioStream = preload("res://sounds/BandaidHealing.wav")
const VITAMINS: AudioStream = preload("res://sounds/Pills.wav")

const HERO_HURT: AudioStream = preload("res://sounds/HeroHurt.wav")
const HERO_WALK: AudioStream = preload("res://sounds/Steps.wav")

const BOSS_DYING: AudioStream = preload("res://sounds/HeroDying.wav")
const FANFARE: AudioStream = preload("res://sounds/Fanfares.wav")

const CARD_DRAW: AudioStream = preload("res://sounds/CardDraw.wav")
const CARD_PLACE: AudioStream = preload("res://sounds/CardPlace.wav")

const MUSIC_TRACK: AudioStream = preload("res://sounds/Alexandr Zhelanov - Caves of Sorrow.ogg")

var music_player: AudioStreamPlayer 

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	play_sound(music_player, MUSIC_TRACK)


func play_pressed_sound(_player: AudioStreamPlayer) -> void:
	play_sound(_player, Sounds.BUTTON_DOWN)


func play_released_sound(_player: AudioStreamPlayer) -> void:
	pass
	#if _player.playing:
		#await _player.finished
	#if _player:
		#play_sound(_player, Sounds.BUTTON_UP)


func play_sound(_player: AudioStreamPlayer, _sound: AudioStream) -> void:
	_player.stream = _sound
	_player.play()
