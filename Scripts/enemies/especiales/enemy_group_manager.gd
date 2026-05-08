extends Node2D

@export var max_group_size := 4
@export var simultaneous_attackers := 2
@export var attack_cooldown := 1.5

var enemies: Array = []
var attackers: Array = []
var can_attack := true


func _ready():
	add_to_group("enemy_manager")


func register_enemy(enemy):
	if enemies.size() < max_group_size:
		enemies.append(enemy)
		enemy.group_manager = self


func unregister_enemy(enemy):
	enemies.erase(enemy)
	attackers.erase(enemy)


func request_attack(enemy):

	if not can_attack:
		return false

	if attackers.size() < simultaneous_attackers:
		attackers.append(enemy)
		return true

	return false


func notify_attack_finished(enemy):
	attackers.erase(enemy)

	if attackers.is_empty():
		reset_cycle()


func reset_cycle():
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
