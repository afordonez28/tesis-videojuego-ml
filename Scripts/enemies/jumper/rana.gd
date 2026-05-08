extends "res://Scripts/enemies/jumper/jumper_enemy.gd"

@export var damage: int = 10
@export var extra_speed: float = 100
@export var extra_jump: float = -100
@export var extra_health: int = 50
@export var damage_interval = 1.0
@export var enemy_scale: float = 1.0

var enemy_in_contact = false
var player_ref: Player = null

func _ready():
	super._ready()
	
	scale = Vector2(enemy_scale, enemy_scale)
	speed += extra_speed
	jump_force += extra_jump
	
	max_health += extra_health
	health = max_health

func _on_damage_body_entered(body):
	if body is Player:
		player_ref = body
		enemy_in_contact = true
		
		player_ref.take_damage(damage)
		$Timer_damage.start()

func _on_damage_body_exited(body):
	if body is Player:
		player_ref = null
		enemy_in_contact = false
		$Timer_damage.stop()

func _on_timer_damage_timeout():
	if enemy_in_contact and player_ref:
		player_ref.take_damage(damage)


func _on_hurtbox_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.


func _on_hurtbox_body_exited(_body: Node2D) -> void:
	pass # Replace with function body.
