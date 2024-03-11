extends Node

const MAIN_MENU_SCENE = "res://scenes/main_menu.tscn"
const TUTORIAL_SCENE = "res://scenes/tutorial_scene.tscn"
const GAME_SCENE = "res://scenes/game.tscn"
const GAME_OVER_SCENE = "res://scenes/game_over_screen.tscn"

enum GAME_OVER_STATES { DEATH, UNSTOPPABLE }

func change_to_game_over_scene(_type: int, _wait: float, _num_steps: float) -> void:
	if _wait:
		await get_tree().create_timer(_wait).timeout
	get_tree().change_scene_to_file(GAME_OVER_SCENE)
	get_tree().paused = false
	# Need to wait two frames till the scene is switched
	await get_tree().process_frame
	await get_tree().process_frame
	
	var game_over = get_tree().current_scene
	game_over.display_stats(_type, _num_steps)
