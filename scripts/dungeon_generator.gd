extends Node

const GRID_LAYER := 0
const ROOM_LAYER := 1
const HAZARD_LAYER := 2
const PREVIEW_LAYER := 3
const FOW_LAYER := 4

const NO_TILE_ID := -1
const DUNGEON_TILES_ID := 1

const HAZARDS_TILE_OFFSET := 4

const TILES_PER_ROW := 8
const START_IDX_OFFSET := 16
const END_IDX_OFFSET := 32

const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
# pos  for connections up, down, left, rigth. Prefix "s" if special.
const ASTAR_CHARS: Array[String] = [ 
	"☐", "╞", "╡", "═", "╥", "╔", "╗", "╦", 
	"╨", "╚", "╝", "╩", "║", "╠", "╣", "╬", 
	"■", "╺", "╸", "━", "╻", "┏", "┓", "┳", 
	"╹", "┗", "┛", "┻", "│", "┣", "┫", "╋"
]

signal dungeon_created(_astar: AStar2D, _start_pos: Vector2i, _boss_pos: Vector2i, _num_rooms: int)
signal dungeon_completed(_astar: AStar2D, _start_pos: Vector2i, _boss_pos: Vector2i, _num_rooms: int, _hazards: Array[int])

@export var dungeon_map: TileMap
@export var min_boss_dist := 2
@export var min_recursion_depth := 1
@export var max_recursion_depth := 10
@export var recursion_connectivity := 0.4

var start_pos: Vector2i
var boss_pos: Vector2i
var dungeon_size: Vector2i
var dungeon_astar: AStar2D
var num_rooms: int
var hazards: Array[int]


func _ready() -> void:
	dungeon_size = dungeon_map.get_used_rect().size
	seed(0)
	#randomize()
	generate_dungeon()


func generate_dungeon() -> void:
	start_pos = dungeon_map.get_used_rect().get_center()
	boss_pos = _calculate_boss_pos()
	var path = _generate_hot_path(start_pos, boss_pos)
	dungeon_astar = _generate_rooms_along_path(path)
	update_dungeon_tiles(dungeon_astar, start_pos, boss_pos)
	num_rooms = dungeon_map.get_used_cells(ROOM_LAYER).size()
	dungeon_created.emit(dungeon_astar, start_pos, boss_pos, num_rooms)


func update_dungeon_tiles(_astar: AStar2D, _start_pos: Vector2i, _end_pos: Vector2i) -> void:
	for y in range(dungeon_map.get_used_rect().size.y):
		for x in range(dungeon_map.get_used_rect().size.x):
			var point = dungeon_map.get_used_rect().position + Vector2i(x, y)
			var point_id = id(point)
			
			if !_astar.has_point(point_id):
				dungeon_map.set_cell(ROOM_LAYER, point, -1) # No Room -> Clear Tile
				continue
			
			var neighbors = DIRECTIONS.map(func(dir): return point + dir)
			var neighbor_ids = neighbors.map(id)
			var has_neighbors = neighbor_ids.map(func(id): return _astar.are_points_connected(id, point_id, true))
			var tile_idx = dungeon_atlas_idx_from_connections(has_neighbors)
			
			if point == _start_pos:
				tile_idx += START_IDX_OFFSET
			elif point == _end_pos:
				tile_idx += END_IDX_OFFSET
			
			@warning_ignore("integer_division")
			var atlas_pos = Vector2i(tile_idx % TILES_PER_ROW, tile_idx / TILES_PER_ROW)
		
			dungeon_map.set_cell(ROOM_LAYER, point, DUNGEON_TILES_ID, atlas_pos)


func _generate_hot_path(_start_pos: Vector2i, _end_pos: Vector2i) -> Array[Vector2i]:
	var max_steps = (_end_pos - _start_pos).length()
	var curr_pos = _start_pos
	var path: Array[Vector2i] = [_start_pos]
	
	for i in max_steps:
		var diff = _end_pos - curr_pos
		# If x or y should be interpolated
		var proceed_x = bool(randi() % 2)
		
		if proceed_x and diff.x != 0 or diff.y == 0:
			curr_pos += Vector2i(-1 ** int(diff.x < 0), 0)
		else:
			curr_pos += Vector2i(0, -1 ** int(diff.y < 0))
		path.append(curr_pos)
	return path


func _generate_rooms_along_path(_hot_path: Array[Vector2i]) -> AStar2D:
	var astar = AStar2D.new()
	# Add hot path points
	for i in _hot_path.size():
		var point = _hot_path[i]
		var point_id = id(point)
		astar.add_point(point_id, point)
		if i > 0:
			astar.connect_points(point_id, id(_hot_path[i - 1]), true)
	
	for point in _hot_path:
		var recursion_depth = randi_range(min_recursion_depth, max_recursion_depth)
		recursive_add_room(astar, point, recursion_connectivity, recursion_depth)
	
	#_visualize_astar_grid(astar, _hot_path[0], _hot_path[-1], dungeon_map.get_used_rect())
	return astar


func recursive_add_room(_astar: AStar2D, _point: Vector2i, _connectivity: float, _depth: int) -> void:
	if _depth <= 0:
		return
	
	var point_id = id(_point)
	
	for dir in DIRECTIONS:
		var do_branch = randf() <= _connectivity
		var neighbor_point = _point + dir
		var neighbor_id = id(neighbor_point)
		
		if !do_branch or !is_in_bounds(neighbor_point):
			continue
		
		# Dont continue recursion if the point was already added, just connect them
		var continue_recursion = _astar.has_point(neighbor_id)
		_astar.add_point(neighbor_id, neighbor_point)
		_astar.connect_points(point_id, neighbor_id, true)
		
		if continue_recursion:
			recursive_add_room(_astar, neighbor_point, _connectivity, _depth - 1)


func _calculate_boss_pos() -> Vector2i:
	var dungeon_pos = dungeon_map.get_used_rect().position
	var dungeon_size = dungeon_map.get_used_rect().size
	var dungeon_end = dungeon_map.get_used_rect().end
	var dungeon_center = dungeon_map.get_used_rect().get_center()
	var boss_max_dist = max(dungeon_size.x / 2, dungeon_size.y / 2)
	# Offset should be at least min_boss_dist
	var boss_distance = Vector2.ONE * randi_range(min_boss_dist, boss_max_dist)
	# Use Vector2 to rotate offset randomly as the function does not exist for Vector2i
	var boss_offset = Vector2i(boss_distance.rotated(randf_range(0, 2 * PI)))
	var boss_pos_unclamped = dungeon_center + boss_offset
	
	return boss_pos_unclamped.clamp(dungeon_pos, dungeon_end - Vector2i.ONE)


func _visualize_astar_grid(_astar: AStar2D, _start_pos: Vector2i, _target_pos: Vector2i, _region: Rect2i) -> void:
	var size = _region.size
	var res = "┌" + "─".repeat(size.x) + "┐\n"
	
	for y in range(size.y):
		res += "│"
		for x in range(size.x):
			var point = _region.position + Vector2i(x, y)
			var point_id = id(point)
			var is_special = point == _start_pos or point == _target_pos
			res += _get_astar_char(_astar, point, point_id, is_special)
		res += "│\n"
	
	res += "└" + "─".repeat(size.x) + "┘"
	print(res)


func _get_astar_char(_astar: AStar2D, _point: Vector2i, _point_id: int, _special: bool) -> String:
	if !_astar.has_point(_point_id):
		return " "
	
	var neighbors: Array = DIRECTIONS.map(func(dir): return _point + dir)
	var neighbor_ids: Array = neighbors.map(id)
	var has_neighbors: Array = neighbor_ids.map(func(id): return _astar.are_points_connected(id, _point_id, true))
	var char_idx = 16 * int(_special) + dungeon_atlas_idx_from_connections(has_neighbors)
	
	return ASTAR_CHARS[char_idx]

func dungeon_atlas_idx_from_connections(_connetions: Array) -> int:
	var atlas_idx = 0
	for i in range(_connetions.size()):
		atlas_idx += 2 ** (_connetions.size() - i - 1) * int(_connetions[i])
	return atlas_idx


func is_in_bounds(_point: Vector2i) -> bool:
	return dungeon_map.get_used_rect().has_point(_point)


func id(_point: Vector2i) -> int:
	return _point.y * dungeon_size.x + _point.x

func unid(_id: int) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(_id % dungeon_size.x, _id / dungeon_size.x)


func _place_fow() -> void:
	pass # TODO Gather Roomswa


func _gather_hazards() -> void:
	hazards = []
	for y in range(dungeon_size.y):
		for x in range(dungeon_size.x):
			var hazard = dungeon_map.get_cell_source_id(HAZARD_LAYER, Vector2i(x, y)) - HAZARDS_TILE_OFFSET
			hazards.append(max(hazard, NO_TILE_ID))


func _on_card_area_cards_placement_confirmed() -> void:
	_place_fow()
	_gather_hazards()
	dungeon_completed.emit(dungeon_astar, start_pos, boss_pos, num_rooms, hazards)
