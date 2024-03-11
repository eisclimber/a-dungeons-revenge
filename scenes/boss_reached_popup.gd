extends Control

signal continue_dungeon()

func _on_continue_button_pressed() -> void:
	continue_dungeon.emit()
