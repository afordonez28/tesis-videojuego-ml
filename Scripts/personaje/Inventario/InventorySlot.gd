extends Control

@onready var icon = $TextureRect
@onready var label = $Label

var item = null

func set_item(new_item):
	item = new_item
	
	if item:
		icon.texture = item.icon
		label.text = str(item.amount)
	else:
		icon.texture = null
		label.text = ""
