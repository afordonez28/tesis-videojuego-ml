extends "res://Scripts/enemies/enemy_base.gd"

func _physics_process(delta):
	# Knockback tiene prioridad
	if is_knockback:
		apply_gravity(delta)
		move_and_slide()
		return

	apply_gravity(delta)

	if player and is_instance_valid(player):
		var direction = player.global_position - global_position
		var dir = sign(direction.x)
		velocity.x = dir * speed
		face_player()
		if is_on_floor():
			play_anim("run")

	move_and_slide()
