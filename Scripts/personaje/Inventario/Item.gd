class_name Item
extends Area2D

@export var item_data: ItemData
@export var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	if item_data:
		sprite.texture = item_data.icon
	# Conectar la señal aquí directamente
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if InventoryManager.add_item(item_data, amount):
			queue_free()
