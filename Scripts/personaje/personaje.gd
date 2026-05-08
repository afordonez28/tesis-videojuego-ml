class_name Player
extends CharacterBody2D

# -----------------------
# ATAQUE
# -----------------------
var can_attack := true
var is_attacking := false

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
var base_scale := 0.5

# -----------------------
# STATE
# -----------------------
var is_dead = false
var level_timer := 0.0

# -----------------------
# HEALTH
# -----------------------
@export var max_health: int = 100
var health: float = 100

# -----------------------
# BUILD SYSTEM
# -----------------------
@export var defense_scene: PackedScene

# -----------------------
# NODES
# -----------------------
@onready var health_bar = $UI2/TextureProgressBar
@onready var damage_label = $UI/VBoxContainer/DamageRow/DamageLabel
@onready var speed_label = $UI/VBoxContainer/SpeedRow/SpeedLabel

@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $hitbox

# -----------------------
# READY
# -----------------------
func _ready():
	add_to_group("player")
	update_health_bar()
	update_stats_ui()



func _process(delta):
	level_timer += delta
	
	if level_timer >= 60: # cada 60 segundos
		level_timer = 0
		MetricsManager.level_reached += 1

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
	handle_build()
	
	apply_gravity(delta)
	handle_jump()
	handle_movement()
	move_and_slide()

# -----------------------
# TOOL SWITCH
# -----------------------
func handle_tool_switch():
	var changed = false
	
	if Input.is_action_just_pressed("tool_1"):
		current_tool = Tool.SWORD
		changed = true
	elif Input.is_action_just_pressed("tool_2"):
		current_tool = Tool.PICKAXE
		changed = true
	elif Input.is_action_just_pressed("tool_3"):
		current_tool = Tool.AXE
		changed = true
	
	if changed:
		update_stats_ui()

# -----------------------
# ATAQUE
# -----------------------
func handle_attack():
	if Input.is_action_just_pressed("ia_attack") and can_attack and not is_attacking:
		can_attack = false
		is_attacking = true
		
		play_attack_animation()
		await sprite.animation_finished
		
		perform_attack()
		
		is_attacking = false
		can_attack = true

func perform_attack():
	var tool_name = get_tool_name()
	var damage_amount = get_damage()
	
	for body in hitbox.get_overlapping_bodies():
		
		if body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(damage_amount)
		
		elif body.is_in_group("resource"):
			if body.has_method("take_damage_tool"):
				body.take_damage_tool(damage_amount, tool_name)

# -----------------------
# CONSTRUCCIÓN 🔥 (USANDO INVENTORY)
# -----------------------
func handle_build():
	if not Input.is_action_just_pressed("build"):
		return
	
	var inventory = get_tree().get_first_node_in_group("inventory")
	
	if inventory == null:
		print("❌ No hay inventory en la escena")
		return
	
	print("Madera:", inventory.inventory.get("wood", 0),
		  " Piedra:", inventory.inventory.get("stone", 0))
	
	if is_attacking:
		print("❌ Está atacando")
		return
	
	if inventory.inventory.get("wood", 0) < 5:
		print("❌ Falta madera")
		return
	
	if inventory.inventory.get("stone", 0) < 3:
		print("❌ Falta piedra")
		return
	
	# 🔥 RESTAR RECURSOS
	inventory.inventory["wood"] -= 5
	inventory.inventory["stone"] -= 3
	inventory.update_ui()
	
	build_structure()

func build_structure():
	is_attacking = true
	
	play_anim("hammer")
	await sprite.animation_finished
	
	if defense_scene == null:
		print("⚠️ No asignaste defense_scene")
		is_attacking = false
		return
	
	var defense = defense_scene.instantiate()
	
	var dir = 1 if sprite.scale.x > 0 else -1
	defense.global_position = global_position + Vector2(32 * dir, -8)
	
	get_parent().add_child(defense)
	
	# aparición progresiva
	defense.scale = Vector2(0, 0)
	var tween = create_tween()
	tween.tween_property(defense, "scale", Vector2(1,1), 0.5)
	
	is_attacking = false

# -----------------------
# HELPERS
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
# ANIMACIÓN
# -----------------------
func play_attack_animation():
	match current_tool:
		Tool.SWORD:
			play_anim("attack_sword")

		Tool.PICKAXE:
			play_anim("attack_pickaxe")

		Tool.AXE:
			play_anim("attack_axe")
			
			sprite.position.y = -13
			await sprite.animation_finished
			sprite.position.y = -7

func play_anim(anim):
	if sprite.animation != anim:
		sprite.play(anim)

# -----------------------
# MOVIMIENTO
# -----------------------
func handle_movement():
	if is_attacking:
		return
	
	var direction = Input.get_axis("ia_left", "ia_right")
	
	if direction < 0:
		sprite.scale.x = -base_scale
		hitbox.scale.x = -1
	elif direction > 0:
		sprite.scale.x = base_scale
		hitbox.scale.x = 1
	
	if direction != 0:
		velocity.x = direction * SPEED
		if is_on_floor():
			play_anim("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			play_anim("static")

# -----------------------
# GRAVEDAD / SALTO
# -----------------------
func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if sprite.animation != "jump":
			play_anim("jump")

func handle_jump():
	if Input.is_action_just_pressed("ia_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

# -----------------------
# VIDA
# -----------------------
func take_damage(damage: int):
	if is_dead:
		return
	
	# 🔥 MÉTRICA
	MetricsManager.damage_taken += damage
	
	health -= damage
	health = max(health, 0)
	update_health_bar()
	
	if health <= 0:
		dead()

func update_health_bar():
	health_bar.value = health

# -----------------------
# MUERTE
# -----------------------
func dead():
	if not is_dead:
		play_anim("die")
		sprite.position.y = -10
	is_dead = true
	
	MetricsManager.save_metrics()
	print("guardando metricas")

func reset():
	sprite.position.y = -18
	play_anim("reset")
	await sprite.animation_finished
	
	is_dead = false
	sprite.position.y = 0
	health = max_health
	
	update_health_bar()
	update_stats_ui()

# -----------------------
# UI
# -----------------------
func update_stats_ui():
	damage_label.text = "Daño: " + str(get_damage())
	speed_label.text = "Velocidad: " + str(SPEED)
