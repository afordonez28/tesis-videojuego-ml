extends CharacterBody2D

@export var speed: float = 50
@export var gravity: float = 500
@export var health: int = 1


@onready var player = null
@onready var sprite = $AnimatedSprite2D


func _ready():

	player = find_nearest_player()


func apply_gravity(delta):

	if not is_on_floor():
		velocity.y += gravity * delta


func face_player():

	if player == null:
		return

	if player.global_position.x < global_position.x:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1


func find_nearest_player():

	var players = get_tree().get_nodes_in_group("player")

	if players.is_empty():
		return null

	var nearest = players[0]
	var min_dist = global_position.distance_to(nearest.global_position)

	for p in players:

		var dist = global_position.distance_to(p.global_position)

		if dist < min_dist:
			min_dist = dist
			nearest = p

	return nearest


func take_damage(damage):

	health -= damage

	if health <= 0:
		queue_free()


func play_anim(anim):

	if sprite.animation != anim:
		sprite.play(anim)
