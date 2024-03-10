class_name HeroArea
extends Control

const HEALTH_FORMAT := "Health\n%s/%s"
const DEFENSE_FORMAT := "Defense\n%s"
const ATTACK_FORMAT := "Attack\n%s"

@onready var health_label: Label = %HealthLabel
@onready var defense_label: Label = %DefenseLabel
@onready var attack_label: Label = %AttackLabel


func _on_hero_stats_player_stats_changed(_effect: int, _health: int, _max_health: int, \
		_attack: int, _defense: int, _num_effects: int) -> void:
	
	health_label.text = HEALTH_FORMAT % [_health, _max_health]
	defense_label.text = DEFENSE_FORMAT % _defense
	attack_label.text = ATTACK_FORMAT % _attack
	
	# TODO Play Animation & Sound



func _on_hero_stats_player_dead(_num_effects: int) -> void:
	print("player ded Hero Area") # TODO Play Animation & Sound
