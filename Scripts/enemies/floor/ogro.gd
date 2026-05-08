extends "res://Scripts/enemies/floor/floor_enemy.gd"

@export var damage: int = 20
@export var damage_interval: float = 1.2
@export var enemy_scale: float = 1.2
@export var attack_range: float = 60.0

# 🔥 comportamiento ogro (más pesado)
@export var approach_speed_multiplier := 0.8

var current_target: Node = null

var is_attacking := false
var is_chasing := true

# 🔥 grupo
var group_manager = null
var group_index := 0
var group_size := 1
var random_offset := 0.0

@onready var damage_area = $DamageArea
@onready var timer = $Timer_damage
@onready var collision = $CollisionShape2D


# -----------------------
# READY
# -----------------------
func _ready():
	super._ready()

	group_manager = get_parent()

	# 🔥 info del grupo
	if group_manager:
		group_index = get_index()
		group_size = group_manager.get_child_count()

	random_offset = randf_range(-20, 20)

	# 🔥 SCALE (como skeleton)
	sprite.scale = Vector2(enemy_scale, enemy_scale)
	damage_area.scale = Vector2(enemy_scale, enemy_scale)

	# ❗ NO escalar collision (rompe físicas)

	sprite.position.y = -13
		

	timer.wait_time = damage_interval

	damage_area.body_entered.connect(_on_body_entered)
	damage_area.body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)


# -----------------------
# PHYSICS
# -----------------------
func _physics_process(delta):
	super._physics_process(delta)
	
	if current_target == null:
		current_target = player
		
	if is_attacking:
		velocity.x = 0
		return

	if current_target == null:
		return

	var dist = global_position.distance_to(current_target.global_position)

	if dist <= attack_range:
		start_attack()
	else:
		chase_target()


# -----------------------
# PERSEGUIR (GRUPO)
# -----------------------
func chase_target():

	is_chasing = true

	var spacing = 70

	# 🔥 distribución en grupo
	var offset = ((group_index - group_size / 2.0) * spacing) + random_offset

	var target_x = current_target.global_position.x + offset
	var dir = sign(target_x - global_position.x)

	var final_speed = speed * approach_speed_multiplier

	velocity.x = dir * final_speed

	play_anim("run")


# -----------------------
# ATAQUE (COORDINADO)
# -----------------------
func start_attack():

	if is_attacking:
		velocity.x = 0
		play_anim("hit")
		return

	is_attacking = true
	is_chasing = false

	velocity.x = 0

	# 🔥 delay por posición en grupo (se siente coordinado)
	await get_tree().create_timer(group_index * 0.15).timeout

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


# -----------------------
# DAÑO
# -----------------------
func _on_timer_timeout():

	if not is_attacking:
		return

	if current_target and current_target.has_method("take_damage"):
		current_target.take_damage(damage)

	stop_attack()


# -----------------------
# ANIMACIONES
# -----------------------
func play_anim(anim_name: String):
	if sprite.animation != anim_name:
		sprite.play(anim_name)


func _on_damage_area_body_entered(body: Node2D) -> void:
	print("Detectó:", body)
