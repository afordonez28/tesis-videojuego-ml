extends "res://Scripts/enemies/jumper/jumper_enemy.gd"

@export var damage: int = 10
@export var extra_speed: float = 100
@export var extra_jump: float = -100
@export var extra_health: int = 50
@export var damage_interval := 1.0


var current_target: Node = null
# ❌ ELIMINAR ESTA LÍNEA:
# var is_attacking := false

@onready var damage_area = $DamageArea
@onready var timer = $Timer_damage


func _ready():
	super._ready()
	
	speed += extra_speed
	jump_force += extra_jump
	
	max_health += extra_health
	health = max_health
	
	timer.wait_time = damage_interval

	damage_area.body_entered.connect(_on_body_entered)
	damage_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("defense"):
		current_target = body
		start_attack()


func _on_body_exited(body):
	if body == current_target:
		current_target = null
		stop_attack()


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

		print("daño")

		play_anim("hit")

		await sprite.animation_finished
		
		if current_target and is_instance_valid(current_target):
			if current_target.has_method("take_damage"):
				current_target.take_damage(damage)
		
		await timer.timeout
