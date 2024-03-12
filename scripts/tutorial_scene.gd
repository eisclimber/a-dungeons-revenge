class_name TutorialScene
extends Control

@onready var panel_1: Panel = %Panel1
@onready var panel_2: Panel = %Panel2
@onready var panel_3: Panel = %Panel3

@onready var ui_sound_player: AudioStreamPlayer = %UISoundPlayer

func _ready() -> void:
	panel_1.visible = true
	panel_2.visible = false
	panel_3.visible = false


func _on_button_step_1_pressed() -> void:
	Sounds.play_released_sound(ui_sound_player)
	panel_1.visible = false
	panel_2.visible = true
	panel_3.visible = false


func _on_button_step_2_pressed() -> void:
	Sounds.play_released_sound(ui_sound_player)
	panel_1.visible = false
	panel_2.visible = false
	panel_3.visible = true


func _on_button_step_3_pressed() -> void:
	Sounds.play_released_sound(ui_sound_player)
	get_tree().change_scene_to_file(Global.GAME_SCENE)


func _on_button_button_down() -> void:
	Sounds.play_pressed_sound(ui_sound_player)
