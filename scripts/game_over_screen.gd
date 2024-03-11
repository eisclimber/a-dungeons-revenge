class_name GameOverScreen
extends Control

const DEAD_TITLE := "Good job! He's dead, Jim."
const DEAD_SCORE_FORMAT := "You let him suffer through %d Rooms."

const UNSTOPPABLE_TITLE := "Oh no! They became too strong!"
const UNSTOPPABLE_SCORE_FORMAT := "You did not manage to kill them after %d rooms.\nGotta run!"

@onready var title_label: Label = %TitleLabel
@onready var score_label: Label = %ScoreLabel
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton


func display_stats(_type: int, _num_rooms: int) -> void:
	if _type == Global.GAME_OVER_STATES.DEATH:
		title_label.text = DEAD_TITLE
		score_label.text = DEAD_SCORE_FORMAT % _num_rooms
	else:
		title_label.text = UNSTOPPABLE_TITLE
		score_label.text = UNSTOPPABLE_SCORE_FORMAT % _num_rooms


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.GAME_SCENE)


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.MAIN_MENU_SCENE)
