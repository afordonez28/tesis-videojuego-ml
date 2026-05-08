extends "res://Scripts/enemies/floor/floor_enemy.gd"

@export var damage: int = 15
@export var damage_interval: float = 1.0
@export var enemy_scale: float = 1.0
@export var attack_range: float = 40.0

var current_target: Node = null

var is_attacking := false
var is_chasing := true

@onready var damage_area = $DamageArea
@onready var timer = $Timer_damage
@onready var collision = $CollisionShape2D


# -----------------------
# READY
# -----------------------
func _ready():
	super._ready()

	sprite.scale = Vector2(enemy_scale, enemy_scale)
	damage_area.scale = Vector2(enemy_scale, enemy_scale)
	collision.scale = Vector2(enemy_scale, enemy_scale)
	
	sprite.position.y = -22	
	
	timer.wait_time = damage_interval

	damage_area.body_entered.connect(_on_body_entered)
	damage_area.body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)


# -----------------------
# PHYSICS PROCESS
# -----------------------
func _physics_process(delta):
	super._physics_process(delta)

	if current_target == null:
		return

	var dist = global_position.distance_to(current_target.global_position)

	# 🔥 SI ESTÁ ATACANDO → NO SE MUEVE NI CAMBIA ANIMACIÓN
	if is_attacking:
		velocity.x = 0
		return

	# 🔥 SI ESTÁ EN RANGO → ATACAR
	if dist <= attack_range:
		start_attack()
		return

	# 🔥 SI NO → PERSEGUIR
	chase_target()


# -----------------------
# PERSEGUIR
# -----------------------
func chase_target():

	is_chasing = true

	var dir = sign(current_target.global_position.x - global_position.x)
	velocity.x = dir * speed

	play_anim("run")


# -----------------------
# ATAQUE
# -----------------------
func start_attack():

	# Evita reiniciar ataque si ya está atacando
	if is_attacking:
		return

	is_attacking = true
	is_chasing = false

	velocity.x = 0

	play_anim("hit")
	timer.start()


# -----------------------
# TERMINAR ATAQUE
# -----------------------
func stop_attack():

	is_attacking = false
	timer.stop()


# -----------------------
# DETECCIÓN
# -----------------------
func _on_body_entered(body):

	if body.is_in_group("player") or body.has_method("take_damage"):
		current_target = body


func _on_body_exited(body):

	if body == current_target:
		current_target = null
		stop_attack()


# -----------------------
# DAÑO
# -----------------------
func _on_timer_timeout():

	if not is_attacking:
		return

	if current_target and current_target.has_method("take_damage"):
		current_target.take_damage(damage)


# -----------------------
# CONTROL DE ANIMACIONES (IMPORTANTE)
# -----------------------
func play_anim(name: String):
	if sprite.animation != name:
		sprite.play(name)
