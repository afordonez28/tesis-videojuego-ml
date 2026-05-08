extends "res://Scripts/enemies/floor/floor_enemy.gd"

@export var damage: int = 15
@export var damage_interval: float = 1.0
@export var enemy_scale: float = 1.0
var enemy_in_contact = false

var player_ref: Node = null
var player_in_range: bool = false


# -----------------------
# READY
# -----------------------
func _ready():
	super._ready()
	scale = Vector2(enemy_scale, enemy_scale)
	
	# Configurar timer automáticamente
	$Timer_damage.wait_time = damage_interval


# -----------------------
# DETECCIÓN DE JUGADOR
# -----------------------
func _on_damage_area_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body
		player_in_range = true
		
		# Daño inmediato
		player_ref.take_damage(damage)
		
		# Iniciar daño continuo
		$Timer_damage.start()


func _on_damage_area_body_exited(body):
	if body.is_in_group("player"):
		player_ref = null
		player_in_range = false
		
		$Timer_damage.stop()


# -----------------------
# DAÑO CONTINUO
# -----------------------
func _on_timer_damage_timeout():
	if player_in_range and player_ref:
		if is_instance_valid(player_ref):
			player_ref.take_damage(damage)


# -----------------------
# MUERTE
# -----------------------
func die():
	# 📊 MÉTRICAS
	MetricsManager.enemies_killed += 1
	
	queue_free()


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
