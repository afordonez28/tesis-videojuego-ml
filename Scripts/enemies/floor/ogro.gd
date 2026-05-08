extends "res://Scripts/enemies/floor/floor_enemy.gd"

@export var damage: int = 20
@export var damage_interval: float = 1.2

var current_target: Node = null
var is_attacking := false

@onready var damage_area = $DamageArea
@onready var timer = $Timer_damage


func _ready():
	super._ready()
	scale = Vector2(enemy_scale, enemy_scale)
	damage_area.body_entered.connect(_on_body_entered)
	damage_area.body_exited.connect(_on_body_exited)
	# ❗ IMPORTANTE: NO usamos el timeout aquí


func _physics_process(delta):
	
	# PRIORIDAD: Knockback
	if is_knockback:
		apply_gravity(delta)
		move_and_slide()
		return

	apply_gravity(delta)

	# SI ESTÁ ATACANDO → no se mueve
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	# PERSEGUIR JUGADOR
	if player and is_instance_valid(player):
		var direction = player.global_position - global_position
		var dir = sign(direction.x)
		
		velocity.x = dir * speed
		face_player()
		
		if is_on_floor():
			play_anim("run")

	move_and_slide()


# -----------------------
# DETECTAR JUGADOR
# -----------------------
func _on_body_entered(body):
	if body.is_in_group("player"):
		current_target = body
		start_attack()


func _on_body_exited(_body):
	if not damage_area.has_overlapping_bodies():
		current_target = null
		stop_attack()


# -----------------------
# ATAQUE (IGUAL QUE SKELETON)
# -----------------------
func start_attack():
	if is_attacking:
		return
	
	is_attacking = true
	timer.start(damage_interval)
	attack_loop()


func stop_attack():
	is_attacking = false
	timer.stop()


func attack_loop():
	while is_attacking:
		
		play_anim("hit")
		await sprite.animation_finished
		
		# 💥 daño solo si sigue tocando
		if current_target and is_instance_valid(current_target):
			if current_target.has_method("take_damage"):
				current_target.take_damage(damage)
		
		await timer.timeout
