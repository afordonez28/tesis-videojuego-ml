class_name Player
extends CharacterBody2D

# -----------------------
# BUG FIX / CONTROL ATAQUE
# -----------------------
var attack_cooldown := 0.3
var can_attack := true

# -----------------------
# CONSTANTS
# -----------------------
const SPEED = 120.0
const JUMP_VELOCITY = -250.0

# -----------------------
# TOOLS
# -----------------------
enum Tool { SWORD, PICKAXE, AXE }
var current_tool = Tool.SWORD
var facing_direction := 1  # 1 = derecha, -1 = izquierda

# -----------------------
# PLAYER STATE
# -----------------------
var is_dead = false
var is_attacking = false

# -----------------------
# HEALTH
# -----------------------
@export var max_health: int = 100
@export var health_regen: float = 2.0
var health: float = 100

# -----------------------
# NODES
# -----------------------
@onready var health_bar = $TextureProgressBar
@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $hitbox
@onready var tool_sprite = $ToolSprite

# -----------------------
# READY
# -----------------------
func _ready():
	add_to_group("player")
	update_health_bar()
	update_tool_sprite()

# -----------------------
# PHYSICS
# -----------------------
func _physics_process(delta):
	
	if is_dead:
		if Input.is_action_just_pressed("ai_reset"):
			reset()
		return
	
	handle_tool_switch()
	handle_attack()
	
	apply_gravity(delta)
	handle_jump()
	handle_movement()
	move_and_slide()

# -----------------------
# TOOL SWITCH
# -----------------------
func handle_tool_switch():
	if Input.is_action_just_pressed("tool_1"):
		current_tool = Tool.SWORD
		update_tool_sprite()
	elif Input.is_action_just_pressed("tool_2"):
		current_tool = Tool.PICKAXE
		update_tool_sprite()
	elif Input.is_action_just_pressed("tool_3"):
		current_tool = Tool.AXE
		update_tool_sprite()

# -----------------------
# ATTACK
# -----------------------
func handle_attack():
	if Input.is_action_just_pressed("ia_attack") and can_attack:
		can_attack = false
		is_attacking = true
		
		play_attack_animation()
		perform_attack()
		
		await get_tree().create_timer(0.3).timeout
		
		is_attacking = false
		can_attack = true

func perform_attack():
	print("Intentando atacar...")
	var tool_name = get_tool_name()
	var damage_amount = get_damage()
	
	for area in hitbox.get_overlapping_areas():
		
		if area.is_in_group("enemy_hurtbox"):
			var enemy = area.get_parent()
			
			if enemy.has_method("take_damage"):
				enemy.take_damage(get_damage())
	
	for body in hitbox.get_overlapping_areas():
		
		if body.is_in_group("enemy"):
			print("Golpeando enemigo:", body.name)
			if body.has_method("take_damage"):
				body.take_damage(damage_amount)
		
		elif body.is_in_group("resource"):
			if body.has_method("take_damage_tool"):
				body.take_damage_tool(damage_amount, tool_name)
				

# -----------------------
# TOOL HELPERS
# -----------------------
func get_tool_name():
	match current_tool:
		Tool.SWORD: return "sword"
		Tool.PICKAXE: return "pickaxe"
		Tool.AXE: return "axe"

func get_damage():
	match current_tool:
		Tool.SWORD: return 100
		Tool.PICKAXE: return 1
		Tool.AXE: return 1

# -----------------------
# TOOL SPRITE
# -----------------------
func update_tool_sprite():
	match current_tool:
		Tool.SWORD:
			tool_sprite.texture = load("res://Assets/herramientas/espada.png")
		Tool.PICKAXE:
			tool_sprite.texture = load("res://Assets/herramientas/pico.png")
		Tool.AXE:
			tool_sprite.texture = load("res://Assets/herramientas/hacha.png")

# -----------------------
# ATTACK ANIMATION
# -----------------------
func play_attack_animation():
	match current_tool:
		Tool.SWORD:
			play_anim("attack_sword")
		Tool.PICKAXE:
			play_anim("attack_pickaxe")
		Tool.AXE:
			play_anim("attack_axe")

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
	if is_attacking:
		return
	
	var direction = Input.get_axis("ia_left", "ia_right")
	
	if direction < 0:
		sprite.scale.x = -1
		facing_direction = -1
		$hitbox.scale.x = -1
	elif direction > 0:
		sprite.scale.x = 1
		facing_direction = 1
	
	if direction != 0:
		velocity.x = direction * SPEED
		if is_on_floor():
			play_anim("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			play_anim("static")

# -----------------------
# ANIMATION
# -----------------------
func play_anim(anim):
	if sprite.animation != anim:
		sprite.play(anim)

# 🔥 ESTA FUNCIÓN ARREGLA EL FREEZE
func _on_AnimatedSprite2D_animation_finished():
	print("Animación terminó")  # 👈 DEBUG
	
	if is_attacking:
		is_attacking = false

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
# UI
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


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
