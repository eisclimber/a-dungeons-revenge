class_name Game
extends Control

const MAX_ATTACK := 8
const MAX_DEFENSE := 8

const DEATH_WAIT := 1.0
const UNSTOPPABLE_WAIT := 1.0

@onready var boss_reached_popup: Control = %BossReachedPopup
@onready var dungeon_generator: Node = %DungeonGenerator
@onready var dungeon_area: DungeonArea = %DungeonArea

func _ready() -> void:
	boss_reached_popup.visible = false


func _on_hero_stats_player_dead(_num_effects: int) -> void:
	get_tree().paused = true
	Global.change_to_game_over_scene(Global.GAME_OVER_STATES.DEATH, _num_effects, DEATH_WAIT)


func _on_hero_movement_boss_reached() -> void:
	boss_reached_popup.visible = true


func _on_boss_reached_popup_continue_dungeon() -> void:
	boss_reached_popup.visible = false
	dungeon_area.clear_hazards()
	dungeon_generator.generate_dungeon()


func _on_hero_stats_player_stats_changed(_effect: int, _health: int, _max_health: int, \
		_attack: int, _defense: int, _num_effects: int) -> void:
	
	if _attack >= MAX_ATTACK or _defense >= MAX_DEFENSE:
		Global.change_to_game_over_scene(Global.GAME_OVER_STATES.UNSTOPPABLE, _num_effects, UNSTOPPABLE_WAIT)
