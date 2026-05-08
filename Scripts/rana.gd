extends "res://Scripts/jumper_enemy.gd"

#values
@export var damage: int = 10
@export var extra_speed: float = 100.0
@export var extra_jump: float = -100.0  # Fuerza de salto
@export var extra_health: int = 50  # Vida de la rana
@export var damage_interval = 1.0 #Repetitive damage
#variables
@export var can_take_damage = true #tiempo de daño
var enemy_in_contact = false #contact with player

var player_ref: Player = null


#aplicate modifiers
var modifiers: bool = false 

#funcion parametros personaje
func _ready():
	super._ready()
	#body.take_damage(damage) #daño
	speed += extra_speed #velocidad
	health += extra_health #vida
	jump_force += extra_jump #salto
	modifiers= true
	

#damage al entrar	
func _on_damage_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		enemy_in_contact = true
		player_ref = body
		player_ref.take_damage(damage)
		$Timer_damage.start()

func _on_damage_body_exited(body: Node2D) -> void:
	if body is Player:
		enemy_in_contact = false
		player_ref=null
		$Timer_damage.stop()

func _on_timer_damage_timeout() -> void:
	if enemy_in_contact and player_ref:
		player_ref.take_damage(damage)
