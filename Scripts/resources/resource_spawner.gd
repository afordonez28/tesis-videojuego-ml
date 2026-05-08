extends Node2D

@export var resources: Array[PackedScene]
@export var probabilities: Array[float]
@export var spawn_area: Rect2
@export var max_resources: int = 20

var rng = RandomNumberGenerator.new()

func _ready():
	spawn_resources()

func spawn_resources():
	for i in range(max_resources):
		var res = pick_resource()
		var instance = res.instantiate()
		
		instance.global_position = get_random_position()
		add_child(instance)

func pick_resource():
	var total = 0.0
	for p in probabilities:
		total += p
	
	var r = rng.randf() * total
	
	var acc = 0.0
	for i in range(resources.size()):
		acc += probabilities[i]
		if r <= acc:
			return resources[i]
	
	return resources[0]

func get_random_position():
	var x = rng.randf_range(spawn_area.position.x, spawn_area.end.x)
	var y = spawn_area.end.y # suelo
	return Vector2(x, y)
