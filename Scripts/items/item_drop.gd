extends CharacterBody2D

@export var item_type: String = "wood"

# física
@export var gravity: float = 600

# impulso inicial
@export var throw_force_x := 60
@export var throw_force_y := -250

# efecto imán
@export var magnet_range := 120
@export var magnet_speed := 300

var player = null
var speed: Vector2 = Vector2.ZERO

# 🔥 NUEVO
var landed := false

func _ready():
	randomize()
	
	# impulso inicial
	velocity.x = randf_range(-throw_force_x, throw_force_x)
	velocity.y = randf_range(throw_force_y, throw_force_y * 0.6)
	
	player = find_nearest_player()

func _physics_process(delta):

	# 🌍 primero aplicar física
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		
		# 🔥 marcar que ya cayó
		landed = true

	# 🧲 IMÁN SOLO DESPUÉS DE CAER
	if landed and player and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		
		if dist < magnet_range:
			var dir = (player.global_position - global_position).normalized()
			velocity = dir * magnet_speed

	move_and_slide()

# 🔍 buscar jugador
func find_nearest_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0]

# 🎒 recoger
func _on_body_entered(body):
	if body.is_in_group("player"):
		collect(body)

func collect(target_player):
	var inventory = target_player.get_node("Inventory")
	if inventory:
		inventory.add_item(item_type, 1)
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("player"):
		collect(body)
	# subir en la jerarquía hasta encontrar el player
	#while player:
		#if player.is_in_group("player"):d
		#	collect(player)
	#		return
	#	player = player.get_parent()
