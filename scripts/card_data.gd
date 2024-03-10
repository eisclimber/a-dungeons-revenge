class_name CardData
extends Resource

enum EFFECTS { NONE, DAMAGE, HEAL, MAX_HEALTH, ATTACK, DEFENSE, FIGHT }

@export var icon : Texture = null
@export var title := ""
@export_multiline var description := ""
@export var effect := EFFECTS.NONE
@export var value1 := 0
@export var value2 := 0
@export var value3 := 0
@export var atlas_tile_pos := Vector2i()
