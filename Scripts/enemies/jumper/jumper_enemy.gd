extends "res://Scripts/enemies/enemy_base.gd"

@export var jump_force = -250
@export var jump_interval: float = 0.8

var jump_timer: float = 0.0

# 🔥 AÑADIR ESTO AQUÍ (CLAVE)
var is_attacking: bool = false


func _physics_process(delta):

	if is_knockback:
		apply_gravity(delta)
		move_and_slide()
		return

	apply_gravity(delta)

	jump_timer -= delta

	if player and is_instance_valid(player):

		face_player()

		var direction = player.global_position - global_position

		# 🚫 BLOQUEAR MOVIMIENTO SI ATACA
		if is_attacking:
			velocity.x = 0
		else:
			if not is_on_floor():
				velocity.x = sign(direction.x) * speed
			else:
				velocity.x = 0

		# 🚫 BLOQUEAR ANIMACIONES SI ATACA
		if not is_attacking:
			if not is_on_floor():
				if velocity.y < 0:
					play_anim("jump")
				else:
					play_anim("fall")
			else:
				play_anim("static")

		# SALTO
		if is_on_floor() and jump_timer <= 0 and not is_attacking:
			velocity.y = jump_force
			jump_timer = jump_interval

	move_and_slide()
