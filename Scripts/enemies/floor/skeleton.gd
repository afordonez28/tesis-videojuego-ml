extends "res://Scripts/enemies/floor/floor_enemy.gd"

@export var damage: int = 15
@export var damage_interval := 1.0
@export var enemy_scale: float = 1.0

var player_ref: Player = null
var player_in_range := false


func _ready():
	super._ready()
	scale = Vector2(enemy_scale, enemy_scale)


# -----------------------
# DAÑO AL JUGADOR
# -----------------------
func _on_damage_area_body_entered(body):
	if body is Player:
		player_ref = body
		player_in_range = true
		
		player_ref.take_damage(damage)
		$Timer_damage.start()


func _on_damage_area_body_exited(body):
	if body is Player:
		player_ref = null
		player_in_range = false
		$Timer_damage.stop()


func _on_timer_damage_timeout():
	if player_in_range and player_ref:
		player_ref.take_damage(damage)


# -----------------------
# MUERTE
# -----------------------
func die():
	
	# 🔥 SUMAR KILL A MÉTRICAS
	MetricsManager.enemies_killed += 1
	
	queue_free()

func _on_damage_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_damage_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _on_hurtbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_hurtbox_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
