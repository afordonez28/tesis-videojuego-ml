extends CanvasLayer

var inventory := {}

@onready var wood_label = $Panel/HBoxContainer/WoodSlot/Label
@onready var stone_label = $Panel/HBoxContainer/StoneSlot/Label

func add_item(item_type: String, amount: int = 1):
	
	if not inventory.has(item_type):
		inventory[item_type] = 0
	
	inventory[item_type] += amount
	
	update_ui()

func update_ui():
	wood_label.text = "x " + str(inventory.get("wood", 0))
	stone_label.text = "x " + str(inventory.get("stone", 0))

func _ready():
	add_to_group("inventory")
