class_name CardArea
extends Control

const ENABLED_LABEL_COLOR = Color.WHITE
const DISABLED_LABEL_COLOR = Color.WEB_GRAY

signal cards_drawn()
signal all_cards_placed()
signal cards_placement_confirmed()

@export var cards: Array[CardData]
@export var max_cards := 8
@export var draw_duration := 0.1
@export var inter_draw_duration := 0.3

@onready var cards_anchor: HBoxContainer = %CardsAnchor
@onready var deck_anchor: TextureButton = %StartButton

@onready var ui_sound_player: AudioStreamPlayer = %UISoundPlayer

var card_packed = preload("res://scenes/card.tscn")

func _ready() -> void:
	clear_cards()


#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		#draw_card()


func draw_cards(_num: int) -> void:
	for i in range(_num):
		draw_card()
		await get_tree().create_timer(inter_draw_duration).timeout
	cards_drawn.emit()


func draw_card() -> void:
	var card = card_packed.instantiate() as Card
	card.data = cards.pick_random()
	card.disabled = true
	deck_anchor.add_child(card)
	var deck_pos = deck_anchor.get_rect().get_center()
	var target_pos = cards_anchor.get_rect().position - deck_pos + (cards_anchor.get_child_count() + 2) * Vector2(120, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position:x", target_pos.x, draw_duration)
	tween.tween_callback(reparent_drawn_card_to_hand)


func reparent_drawn_card_to_hand() -> void:
	# Child 0 is Label!!!
	if deck_anchor.get_child_count() > 1:
		var card = deck_anchor.get_child(1) as Card
		deck_anchor.remove_child(card)
		cards_anchor.add_child(card)
		card.tree_exited.connect(_on_card_placed)
		card.disabled = false


func clear_cards() -> void:
	for child in cards_anchor.get_children():
		child.queue_free()
	
	for child in deck_anchor.get_children():
		if child is Card:
			child.queue_free()


func _on_card_placed() -> void:
	if cards_anchor.get_child_count() <= 0:
		all_cards_placed.emit()


func _on_all_cards_placed() -> void:
	$StartButton.disabled = false
	$StartButton/Label.add_theme_color_override("font_color", ENABLED_LABEL_COLOR)


func _on_dungeon_generator_dungeon_created(_astar: AStar2D, _start_pos: Vector2i, _boss_pos: Vector2i, _num_rooms: int) -> void:
	$StartButton.disabled = true
	$StartButton/Label.add_theme_color_override("font_color", DISABLED_LABEL_COLOR)
	var num_cards = clampi(_num_rooms - 2, 0, max_cards) # -2 for the start and boss room
	draw_cards(num_cards)


func _on_start_button_pressed() -> void:
	cards_placement_confirmed.emit()
	$StartButton.disabled = true


func _on_start_button_button_down() -> void:
	Sounds.play_pressed_sound(ui_sound_player)


func _on_start_button_button_up() -> void:
	Sounds.play_released_sound(ui_sound_player)
