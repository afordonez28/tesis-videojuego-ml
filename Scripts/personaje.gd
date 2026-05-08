class_name Player
extends CharacterBody2D

#Constants
const SPEED = 120.0
const JUMP_VELOCITY = -250.0

# booleans
var is_dead = false

#var life
@onready var health_bar = $TextureProgressBar  
@export var max_health: int = 100
@export var health_regen: int = 2
@export var health= 100



func _physics_process(delta: float) -> void:
	
	health_bar.value = health
	
	if is_dead:
		if Input.is_action_just_pressed("ai_reset"):  
			reset()	
	if is_dead == false:	
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
			$AnimatedSprite2D.play("jump")

		# If the Character is in the floor "jump".
		if Input.is_action_just_pressed("ia_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	
	
		# Get the input direction and handle the movement/deceleration.
		# Direction 1 0 -1
		var direction := Input.get_axis("ia_left", "ia_right")
		if direction < 0:
			$AnimatedSprite2D.position.x=-3
			$AnimatedSprite2D.scale.x=-1
		elif direction >0:
			$AnimatedSprite2D.position.x=1
			$AnimatedSprite2D.scale.x=1
	
	
		if direction:
			velocity.x = direction * SPEED
			if is_on_floor():
				$AnimatedSprite2D.play("run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor():
				$AnimatedSprite2D.play("static")
		move_and_slide()

		#dead
		if Input.is_action_just_pressed("ai_die"):
			dead()
	
func _process(delta):
	# Regeneración de vida
	if is_dead==false:
		if health < max_health:
			health += health_regen * delta
			health = min(health, max_health)  # No superar el máximo de vida
			health_bar.value = health  # Actualiza la barra de vida

func take_damage(damage: int):

	health -= damage
	health = max(health, 0)  # No permitir quead la vida sea menor a 0
	health_bar.value = health
	if health <= 0:
		dead()
				
func dead():
	if is_dead==false:
		$AnimatedSprite2D.play("die")
	is_dead=true

func reset():
	$AnimatedSprite2D.position.y=-18
	$AnimatedSprite2D.play("reset")
	await $AnimatedSprite2D.animation_finished
	is_dead = false
	$AnimatedSprite2D.position.y=0
	health=100
