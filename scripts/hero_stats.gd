class_name HeroStats
extends Node

signal player_dead(_num_effects: int)
signal player_stats_changed(_effect: String, _health: int, _max_health: int, _attack: int, _defense: int, _num_effects: int)


var health := 10
var max_health := 10
var attack := 2
var defense := 1

var num_effects := 0


func _ready() -> void:
	player_stats_changed.emit("none", health, max_health, attack, defense, num_effects)


# Returns if the hero survived
func apply_card_data(_card_data: CardData) -> void:
	if !_card_data:
		return
	
	var value1 = _card_data.value1
	var value2 = _card_data.value2
	var value3 = _card_data.value3
	
	match _card_data.effect:
		"damage":
			health -= value1
			num_effects += 1
		"heal":
			health = min(health + value1, max_health)
			num_effects += 1
		"max_health":
			max_health *= (100.0 + value1) / 100.0
			num_effects += 1
		"attack":
			attack += value1
			num_effects += 1
		"defense":
			defense += value1
			num_effects += 1
		"fight": # value1: monster attack; value2: monster defense; value3: monster health
			var in_damge = max(value1 - defense, 0.0)
			var out_damage = max(attack - value3, 0.0)
			var num_rounds = ceil(value3 / out_damage)
			health -= num_rounds * in_damge
			num_effects += 1
	
	player_stats_changed.emit(_card_data.effect, health, max_health, attack, defense, num_effects)
	
	if health <= 0:
		player_dead.emit(num_effects)


func _on_hero_movement_room_effect_triggered(_room_id: int, _card_data: CardData) -> void:
	apply_card_data(_card_data)
