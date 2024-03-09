class_name HeroMovement
extends Node

const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

const NO_ROOM := -1
const UNDISCOVERED := 0
const DISCOVERED := 1
const VISITED := 2

signal room_entering(_room_id: int)
signal room_effect_triggered(_room_id: int, _card_data: CardData)
signal room_exiting(_room_id: int)
signal boss_reached()

@export var dungeon_map: TileMap
@export var hero: HeroPawn
@export var dungeon_area: DungeonArea
@export var move_duration := 1.0 # Seconds per room moved
@export var visit_duration := 2.0 # Seconds per room visited

var dungeon_size : Vector2i
var num_rooms : int
var max_num_rooms : int
var astar: AStar2D
var start_pos: Vector2i
var boss_pos: Vector2i
var current_room_id: int
var current_path: Array
var room_knowledge: Array[int]

var tween: Tween
var move := false

func _on_dungeon_generator_dungeon_created(_astar: AStar2D, _start_pos: Vector2i, \
		_boss_pos: Vector2i, _num_rooms: int) -> void:
	
	dungeon_size = dungeon_map.get_used_rect().size
	max_num_rooms = dungeon_size.x * dungeon_size.y
	astar = _astar
	start_pos = _start_pos
	boss_pos = _boss_pos
	hero.position = dungeon_map.map_to_local(_start_pos)
	room_knowledge = []
	room_knowledge.resize(max_num_rooms)
	_visit_room(_start_pos, true)


func _visit_room(_room_pos: Vector2i, _initial: bool = false) -> void:
	var room_id = id(_room_pos)
	current_room_id = room_id
	room_knowledge[room_id] = VISITED
	for dir in DIRECTIONS:
		var neighbor = _room_pos + dir
		var neighbor_id = id(neighbor)
		if neighbor.x < 0 or neighbor.x >= dungeon_size.x \
				and neighbor.y < 0 or neighbor.y >= dungeon_size.y:
			
			continue
		elif !astar.has_point(neighbor_id):
			room_knowledge[neighbor_id] = NO_ROOM
		elif astar.are_points_connected(room_id, neighbor_id) \
				and room_knowledge[neighbor_id] == UNDISCOVERED:
			
			room_knowledge[neighbor_id] = DISCOVERED
	
	if !_initial:
		room_entering.emit(room_id)
	if !_initial:
		_apply_room_effect(room_id)
	#get_tree().paused = true
	await get_tree().create_timer(visit_duration).timeout
	if !_initial:
		room_exiting.emit(room_id)


func _apply_room_effect(_room_id: int) -> void:
	var card_data = dungeon_area.hazards[_room_id]
	room_effect_triggered.emit(_room_id, card_data)


func target_next_room() -> void:
	var possible_rooms = []
	for i in range(max_num_rooms):
		if room_knowledge[i] == DISCOVERED:
			possible_rooms.append(i)
	
	if possible_rooms.size() <= 0:
		printerr("No rooms left, this should not happen!!!")
		return
	
	var next_id = possible_rooms.pick_random()
	var next_room = unid(next_id)
	current_path = astar.get_point_path(current_room_id, next_id)
	
	_continue_on_path(false)


func _continue_on_path(_visit_next: bool = true) -> void:
	# Dirty hack for stoping move
	if !move:
		return
	
	if current_path.size() <= 0:
		printerr("Path only had one element. This should not happen")
		return
	
	# Visit current room
	var next_room = current_path.pop_front()
	if _visit_next:
		await _visit_room(next_room)
	
	# Bos reached
	if current_room_id == id(boss_pos):
		print("Boss")
		return
	
	# Nothing to do if not
	if current_path.size() <= 0:
		target_next_room()
		return
	
	var target_pos = dungeon_map.map_to_local(current_path[0])
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).tween_property(hero, "position", target_pos, move_duration)
	tween.tween_callback(_continue_on_path)


func print_knowledge() -> void:
	var res := ""
	for y in dungeon_size.y:
		for x in dungeon_size.x:
			res += str(room_knowledge[y * dungeon_size.x + x]) + " "
		res += "\n"
	print(res)


func id(_point: Vector2i) -> int:
	return _point.y * dungeon_size.x + _point.x


func unid(_id: int) -> Vector2i:
	return Vector2i(_id % dungeon_size.x, _id / dungeon_size.x)


func _on_hero_stats_player_dead(_num_effects: int) -> void:
	# Dirty hack for canceling moving
	move = false
	tween.stop()


func _on_dungeon_generator_dungeon_completed(_astar: AStar2D, _start_pos: Vector2i, \
		_boss_pos: Vector2i, _num_rooms: int, _hazards: Array[int]) -> void:
	
	move = true 
	target_next_room()
