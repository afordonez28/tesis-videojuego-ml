extends Node2D

@export var resources : Array[PackedScene]

@export var spawn_area_size := Vector2(1000, 500)
@export var max_resources := 30
@export var spawn_interval := 2.0

@export var initial_spawn_radius := 200
@export var initial_amount_each := 5

# 🔥 NUEVO
@export var min_distance_between := 50
@export var min_distance_to_player := 80

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
	spawn_initial_resources()
	start_spawning()

# 🌱 SPAWN INICIAL
func spawn_initial_resources():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	if resources.size() < 2:
		return
	
	var tree_scene = resources[0]
	var rock_scene = resources[1]
	
	for i in range(initial_amount_each):
		spawn_near_player(tree_scene, player)
	
	for i in range(initial_amount_each):
		spawn_near_player(rock_scene, player)

# 📍 SPAWN CERCA DEL PLAYER (CON VALIDACIÓN)
func spawn_near_player(scene: PackedScene, player):
	var tries = 10
	
	while tries > 0:
		
		var offset = Vector2(
			rng.randf_range(-initial_spawn_radius, initial_spawn_radius),
			0
		)
		
		var x = player.global_position.x + offset.x
		var pos = get_ground_position(x, player.global_position.y)
		
		if pos != null and is_position_valid(pos, player):
			var resource = scene.instantiate()
			resource.position = pos + Vector2(0, resource.spawn_offset_y)
			add_child(resource)
			return
		
		tries -= 1

# 🌍 SPAWN NORMAL
func start_spawning():
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		
		if get_child_count() < max_resources:
			spawn_one()

func spawn_one():
	var tries = 10
	
	while tries > 0:
		
		var scene = resources[rng.randi_range(0, resources.size() - 1)]
		
		var x = global_position.x + rng.randf_range(-spawn_area_size.x, spawn_area_size.x)
		var pos = get_ground_position(x, global_position.y)
		
		var player = get_tree().get_first_node_in_group("player")
		
		if pos != null and is_position_valid(pos, player):
			var resource = scene.instantiate()
			resource.position = pos + Vector2(0, resource.spawn_offset_y)
			add_child(resource)
			return
		
		tries -= 1

# 🔽 RAYCAST AL SUELO (REUTILIZABLE)
func get_ground_position(x, y_origin):
	var space_state = get_world_2d().direct_space_state
	
	var from = Vector2(x, y_origin - 200)
	var to = Vector2(x, y_origin + spawn_area_size.y)

	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)

	if result:
		return result.position
	
	return null

# 🚫 VALIDAR POSICIÓN
func is_position_valid(pos: Vector2, player) -> bool:
	
	# ❌ muy cerca del jugador
	if player and pos.distance_to(player.global_position) < min_distance_to_player:
		return false
	
	# ❌ muy cerca de otros recursos
	for r in get_tree().get_nodes_in_group("resource"):
		if pos.distance_to(r.global_position) < min_distance_between:
			return false
	
	return true
