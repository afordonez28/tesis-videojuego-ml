extends "res://Scripts/enemies/floor/floor_enemy.gd"

@export var damage: int = 20
@export var damage_interval: float = 1.2
@export var enemy_scale: float = 1.2
@export var attack_range: float = 80.0
@export var approach_speed_multiplier := 0.8

var current_target: Node = null
var is_attacking := false

# Grupo
var group_manager = null
var group_index := 0
var group_size := 1
var random_offset := 0.0

@onready var damage_area = $DamageArea
@onready var collision = $CollisionShape2D

# -----------------------
# READY
# -----------------------
func _ready():
	
	
	super._ready()
	group_manager = get_parent()
	if group_manager:
		group_index = get_index()
		group_size = group_manager.get_child_count()
	random_offset = randf_range(-20, 20)

	sprite.scale = Vector2(enemy_scale, enemy_scale)
	damage_area.scale = Vector2(enemy_scale, enemy_scale)
	sprite.position.y = -13

	damage_area.monitoring = false
	damage_area.body_entered.connect(_on_damage_area_hit)
	sprite.animation_finished.connect(_on_animation_finished)

# -----------------------
# PHYSICS — sin super para evitar que el padre pise animaciones
# -----------------------
func _physics_process(delta):
	# Knockback heredado de enemy_base
	if is_knockback:
		apply_gravity(delta)
		move_and_slide()
		return

	apply_gravity(delta)

	if current_target == null:
		current_target = player

	if is_attacking:
		velocity.x = 0
		face_player()
		move_and_slide()
		return

	if current_target == null or not is_instance_valid(current_target):
		play_anim("run")
		move_and_slide()
		return

	var dist = global_position.distance_to(current_target.global_position)

	if dist <= attack_range:
		start_attack()
	else:
		chase_target()

	face_player()
	move_and_slide()

# -----------------------
# PERSEGUIR
# -----------------------
func chase_target():
	# Sin offset cuando hay un solo enemigo, offset reducido en grupo
	var offset := 0.0
	if group_size > 1:
		var spacing = 40  # reducido de 70 a 40
		offset = ((group_index - group_size / 2.0) * spacing) + random_offset

	var target_x = current_target.global_position.x + offset
	var dir = sign(target_x - global_position.x)

	# Si ya está muy cerca del target_x, no frenarlo
	var dist_to_target_x = abs(target_x - global_position.x)
	if dist_to_target_x < attack_range:
		start_attack()
		return

	velocity.x = dir * (speed * approach_speed_multiplier)
	play_anim("run")

# -----------------------
# ATAQUE
# -----------------------
func start_attack():
	if is_attacking:
		return
	is_attacking = true
	velocity.x = 0
	play_anim("hit")

# -----------------------
# ANIMACIÓN TERMINÓ
# -----------------------
func _on_animation_finished():
	if sprite.animation == "hit":
		apply_hit_damage()
		is_attacking = false

# -----------------------
# APLICAR DAÑO
# -----------------------
func apply_hit_damage():
	if current_target and is_instance_valid(current_target):
		var dist = global_position.distance_to(current_target.global_position)
		if dist <= attack_range * 1.2:
			if current_target.has_method("take_damage"):
				current_target.take_damage(damage)

# -----------------------
# DETECCIÓN POR HITBOX (opcional, como respaldo)
# -----------------------
func _on_damage_area_hit(body: Node):
	if body.is_in_group("player") or body.has_method("take_damage"):
		current_target = body

# -----------------------
# ANIMACIÓN
# -----------------------
func play_anim(anim_name: String):
	if sprite.animation != anim_name:
		sprite.play(anim_name)
