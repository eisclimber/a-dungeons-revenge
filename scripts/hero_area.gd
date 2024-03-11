class_name HeroArea
extends Control

const HEALTH_FORMAT := "Health\n%s/%s"
const DEFENSE_FORMAT := "Defense\n%s"
const ATTACK_FORMAT := "Attack\n%s"

@export var idle_animation : AnimatedTexture
@export var hurt_animation : AnimatedTexture
@export var death_animation : AnimatedTexture

@onready var health_label: Label = %HealthLabel
@onready var defense_label: Label = %DefenseLabel
@onready var attack_label: Label = %AttackLabel
@onready var player_sprite: TextureRect = %PlayerSprite


func _on_hero_stats_player_stats_changed(_effect: int, _health: int, _max_health: int, \
		_attack: int, _defense: int, _num_effects: int) -> void:
	
	health_label.text = HEALTH_FORMAT % [_health, _max_health]
	defense_label.text = DEFENSE_FORMAT % _defense
	attack_label.text = ATTACK_FORMAT % _attack
	
	var below_half_health = _health <= _max_health / 2
	
	if below_half_health and player_sprite.texture == idle_animation:
		player_sprite.texture = hurt_animation
	elif !below_half_health and player_sprite.texture == hurt_animation:
		player_sprite.texture = idle_animation


func _on_hero_stats_player_dead(_num_effects: int) -> void:
	death_animation.set_current_frame(0) # Reset the animation
	player_sprite.texture = death_animation
