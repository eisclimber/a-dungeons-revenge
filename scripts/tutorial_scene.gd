class_name TutorialScene
extends Control

@onready var panel_1: Panel = %Panel1
@onready var panel_2: Panel = %Panel2


func _ready() -> void:
	panel_1.visible = true
	panel_2.visible = false


func _on_button_step_1_pressed() -> void:
	panel_1.visible = false
	panel_2.visible = true


func _on_button_step_2_pressed() -> void:
	get_tree().change_scene_to_file(Global.GAME_SCENE)
