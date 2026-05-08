extends "res://Scripts/enemies/enemy_base.gd"

@export var jump_force = -250
@export var jump_interval = 0.8

var jump_timer = 0.0


func _physics_process(delta):

	apply_gravity(delta)

	if player and is_instance_valid(player):

		face_player()

		var direction = player.global_position - global_position

		if not is_on_floor():
			velocity.x = sign(direction.x) * speed

			if velocity.y < 0:
				play_anim("jump")
			else:
				play_anim("fall")

		else:
			velocity.x = 0
			play_anim("static")

		jump_timer -= delta

		if is_on_floor() and jump_timer <= 0:

			velocity.y = jump_force
			jump_timer = jump_interval

	move_and_slide()
