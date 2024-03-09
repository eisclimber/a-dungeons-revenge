class_name GameOverScreen
extends Control

@export var menu_scene: PackedScene
@export var game_scene: PackedScene

func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(menu_scene)
