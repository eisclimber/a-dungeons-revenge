class_name Card
extends Button

@onready var card_icon := %CardIcon
@onready var title_label := %TitleLabel
@onready var content_label := %ContentLabel

var drag_preview_packed = preload("res://scenes/card_drag_preview.tscn")

@export var data: CardData = null:
	set(value):
		data = value
		
		if value:
			disabled = false
			card_icon.texture = data.icon
			title_label.text = data.title_label
			content_label.text = data.description
		else:
			disabled = false
			card_icon.texture = null
			title_label.text = ""
			content_label.text = ""


func _get_drag_data(at_position: Vector2) -> Variant:
	var drag_preview = drag_preview_packed.instantiate()
	drag_preview.set_displayed_card(card_icon.texture)
	set_drag_preview(drag_preview)
	return { "card_data" : data }
