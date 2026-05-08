extends GridContainer

@export var slot_scene: PackedScene

func _ready():
	columns = 5  # 5 x 6 = 30 slots
	
	for i in range(30):
		var slot = slot_scene.instantiate()
		add_child(slot)
