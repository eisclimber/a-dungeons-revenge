class_name MainMenu
extends Control


@onready var ui_sound_player: AudioStreamPlayer = %UISoundPlayer


func _on_play_button_pressed() -> void:
	Sounds.play_released_sound(ui_sound_player)
	get_tree().change_scene_to_file(Global.TUTORIAL_SCENE)


func _on_exit_button_pressed() -> void:
	Sounds.play_released_sound(ui_sound_player)
	get_tree().quit()


func _on_button_button_down() -> void:
	Sounds.play_pressed_sound(ui_sound_player)
