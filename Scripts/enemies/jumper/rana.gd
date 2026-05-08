extends "res://Scripts/enemies/jumper/jumper_enemy.gd"

@export var damage: int = 10
@export var extra_speed: float = 100
@export var extra_jump: float = -100
@export var extra_health: int = 50
@export var damage_interval := 1.0
@export var enemy_scale: float = 1.0

var player_ref: Node = null
var player_in_range := false

@onready var damage_area = $DamageArea
@onready var timer = $Timer_damage

# -----------------------
# READY
# -----------------------
func _ready():
	super._ready()
	
	scale = Vector2(enemy_scale, enemy_scale)
	speed += extra_speed
	jump_force += extra_jump
	
	max_health += extra_health
	health = max_health
	
	timer.wait_time = damage_interval

	# 🔥 conectar señales
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_area.body_exited.connect(_on_damage_area_body_exited)

# -----------------------
# DETECCIÓN
# -----------------------
func _on_damage_area_body_entered(body):

	# PLAYER
	if body.is_in_group("player"):
		player_ref = body
		player_in_range = true
		
		body.take_damage(damage)
		timer.start()

	# DEFENSAS
	elif body.is_in_group("defense"):
		body.take_damage(damage)


func _on_damage_area_body_exited(body):
	if body.is_in_group("player"):
		player_ref = null
		player_in_range = false
		timer.stop()

# -----------------------
# DAÑO CONTINUO
# -----------------------
func _on_timer_damage_timeout():

	# PLAYER
	if player_in_range and player_ref and is_instance_valid(player_ref):
		player_ref.take_damage(damage)

	# DEFENSAS
	for body in damage_area.get_overlapping_bodies():
		if body.is_in_group("defense"):
			body.take_damage(damage)
