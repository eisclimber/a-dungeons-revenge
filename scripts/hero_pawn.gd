class_name HeroPawn
extends Node


func _on_hero_stats_player_stats_changed(_effect: int, _health: int, _max_health: int, \
		_attack: int, _defense: int, _num_effects: int) -> void:
	
	pass # TODO Play Animation & Sound


func _on_hero_stats_player_dead(_num_effects: int) -> void:
	pass #print("player ded Hero Pawn") # TODO play Animation & Sound
