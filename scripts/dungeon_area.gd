class_name DungeonArea
extends Control

const NO_TILE_ID := -1
const GRID_TILE_ID := 0
const ROOM_TILE_ID := 1
const HASARD_TILE_ID := 3

const GRID_LAYER := 0
const ROOM_LAYER := 1
const HASARD_LAYER := 2
const PREVIEW_LAYER := 3

const NO_PREVIEW_TILE_POS = Vector2i(-1, -1)

const ROOM_TERRAIN := 0
const ROOM_TERRAIN_SET := 0

@onready var dungeon_space : Control = %DungeonSpace
@onready var dungeon_map : TileMap = %DungeonMap

var prev_preview_tile = NO_PREVIEW_TILE_POS
var initial_pos

func _ready() -> void:
	await get_tree().process_frame
	center_dungeon_map()


func center_dungeon_map() -> void:
	var available_rect = dungeon_space.get_rect()
	var dungeon_size = Vector2(dungeon_map.get_used_rect().size * dungeon_map.tile_set.tile_size)
	var possible_scales = available_rect.size / dungeon_size
	var dungeon_target_scale = Vector2.ONE * min(possible_scales.x, possible_scales.y)
	var remaining_space = available_rect.size - dungeon_size * dungeon_target_scale
	
	# Add padding and undo the shift of the parents container margin
	dungeon_map.position = available_rect.position + remaining_space / 2 - Vector2(dungeon_space.position)
	dungeon_map.scale = dungeon_target_scale

func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	# prev_preview_title must already be valid as it was generated during _can_drop_data
	var atlas_tile_pos = _data["card_data"].atlas_tile_pos
	dungeon_map.set_cell(HASARD_LAYER, prev_preview_tile, HASARD_TILE_ID, atlas_tile_pos)
	# Remove preview and reset prev_preview_tile
	dungeon_map.erase_cell(PREVIEW_LAYER, prev_preview_tile)
	prev_preview_tile = NO_PREVIEW_TILE_POS


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	var tile_pos = get_dungeon_tile_pos(_at_position)
	var is_special_tile = is_special_tile(tile_pos)
	var can_drop = !is_special_tile and _data and _data is Dictionary and \
					_data.has_all([ "card_data", "drag_preview" ]) and is_tile_valid(tile_pos)
	
	if can_drop:
		show_room_preview(tile_pos)
	else:
		show_room_preview(NO_PREVIEW_TILE_POS)
	_data["drag_preview"].visible = !can_drop
	
	return can_drop


func get_dungeon_tile_pos(_at: Vector2) -> Vector2i:
	var scaled_pos = (_at - dungeon_map.position) / dungeon_map.scale
	return dungeon_map.local_to_map(scaled_pos)


func is_special_tile(_tile_pos : Vector2i, _layer: int = ROOM_LAYER) -> bool:
	return %DungeonMap.get_cell_atlas_coords(_layer, _tile_pos).y >= 2


func is_tile_valid(_tile_pos : Vector2i) -> bool:
	return dungeon_map.get_cell_source_id(GRID_LAYER, _tile_pos) == GRID_TILE_ID \
		and dungeon_map.get_cell_source_id(ROOM_LAYER, _tile_pos) != NO_TILE_ID


func show_room_preview(_tile_pos : Vector2i) -> void:
	if prev_preview_tile != NO_PREVIEW_TILE_POS:
		dungeon_map.erase_cell(PREVIEW_LAYER, prev_preview_tile)
	
	if _tile_pos != NO_PREVIEW_TILE_POS:
		dungeon_map.set_cell(PREVIEW_LAYER, _tile_pos, HASARD_TILE_ID, Vector2i.ZERO, 0)
	
	prev_preview_tile = _tile_pos