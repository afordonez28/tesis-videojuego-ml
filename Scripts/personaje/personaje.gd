class_name Player
extends CharacterBody2D

# -----------------------
# CONSTANTS
# -----------------------
const SPEED = 120.0
const JUMP_VELOCITY = -250.0

# -----------------------
# PLAYER STATE
# -----------------------
var is_dead = false

# -----------------------
# HEALTH
# -----------------------
@export var max_health: int = 100
@export var health_regen: float = 2.0
var health: float = 100

@onready var health_bar = $TextureProgressBar
@onready var sprite = $AnimatedSprite2D
@onready var inventory_ui = get_node("/root/mundo/UI/InventoryUI")

@export var inventory_panel: Control

# -----------------------
# READY
# -----------------------
func _ready():
	add_to_group("player")
	update_health_bar()


# -----------------------
# PHYSICS
# -----------------------
func _physics_process(delta):


	
		
	if is_dead:
		if Input.is_action_just_pressed("ai_reset"):
			reset()
		return

	apply_gravity(delta)
	handle_jump()
	handle_movement()

	move_and_slide()


# -----------------------
# GRAVITY
# -----------------------
func apply_gravity(delta):

	if not is_on_floor():
		velocity += get_gravity() * delta
		play_anim("jump")


# -----------------------
# JUMP
# -----------------------
func handle_jump():

	if Input.is_action_just_pressed("ia_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


# -----------------------
# MOVEMENT
# -----------------------
func handle_movement():

	var direction = Input.get_axis("ia_left", "ia_right")

	if direction < 0:
		sprite.scale.x = -1
	elif direction > 0:
		sprite.scale.x = 1

	if direction != 0:
		velocity.x = direction * SPEED

		if is_on_floor():
			play_anim("run")

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		if is_on_floor():
			play_anim("static")


# -----------------------
# ANIMATION SAFE PLAY
# -----------------------
func play_anim(anim):

	if sprite.animation != anim:
		sprite.play(anim)


# -----------------------
# PROCESS
# -----------------------
func _process(delta):

#------------------------
# INVENTARY
#-----------------------

	if Input.is_action_just_pressed("inventory"):
		inventory_panel.visible = !inventory_panel.visible

#--------------------------------------

	if is_dead:
		return

	if health < max_health:
		health += health_regen * delta
		health = min(health, max_health)
		update_health_bar()


# -----------------------
# DAMAGE
# -----------------------
func take_damage(damage: int):

	if is_dead:
		return

	health -= damage
	health = max(health, 0)

	update_health_bar()

	if health <= 0:
		dead()


# -----------------------
# UPDATE UI
# -----------------------
func update_health_bar():

	health_bar.value = health


# -----------------------
# DEAD
# -----------------------
func dead():

	if not is_dead:
		play_anim("die")

	is_dead = true


# -----------------------
# RESET
# -----------------------
func reset():

	sprite.position.y = -18
	play_anim("reset")

	await sprite.animation_finished

	is_dead = false
	sprite.position.y = 0
	health = max_health

	update_health_bar()
	
