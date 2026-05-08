extends HBoxContainer

@export var slot_scene: PackedScene

func _ready():
	for i in range(10):
		var slot = slot_scene.instantiate()
		add_child(slot)
