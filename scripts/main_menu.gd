class_name MainMenu
extends Control


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.TUTORIAL_SCENE)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
