class_name Card
extends TextureButton

@onready var card_icon := %CardIcon
@onready var title_label := %TitleLabel
@onready var content_label := %ContentLabel

@onready var stats: HBoxContainer = %Stats

@onready var defense_label: Label = %DefenseLabel
@onready var health_label: Label = %HealthLabel
@onready var attack_label: Label = %AttackLabel

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

var drag_preview_packed = preload("res://scenes/card_drag_preview.tscn")

@export var data: CardData = null:
	set(value):
		data = value
		
		if is_inside_tree():
			_update_card_data(data)


func _ready() -> void:
	_update_card_data(data)


func _update_card_data(_data: CardData) -> void:
	if _data:
		#disabled = false
		%CardIcon.texture = data.icon
		%TitleLabel.text = data.title
		%ContentLabel.text = data.description
		
		if data.effect == CardData.EFFECTS.FIGHT:
			stats.visible = true
			# value1: monster attack; value2: monster defense; value3: monster health
			defense_label.text = str(data.value2)
			health_label.text = str(data.value3)
			attack_label.text = str(data.value1)
		else:
			stats.visible = false
	else:
		#disabled = true
		%CardIcon.texture = null
		%TitleLabel.text = ""
		%ContentLabel.text = ""
		%FightLabel.visible = false
		stats.visible = false


func _get_drag_data(_at_position: Vector2) -> Variant:
	var drag_preview = drag_preview_packed.instantiate()
	drag_preview.set_displayed_card(card_icon.texture)
	set_drag_preview(drag_preview)
	Sounds.play_sound(audio_stream_player, Sounds.CARD_PLACE)
	return { "card_data" : data, "drag_preview": drag_preview, "card_node": self }
