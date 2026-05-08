extends CharacterBody2D

@export var speed: float = 50
@export var gravity: float = 500
@export var max_health: int = 100
@export var knockback_force := 150

var health: int
var is_knockback := false

@onready var player = null
@onready var sprite = $AnimatedSprite2D

# UI
@onready var bar_fill = $HealthBar/BarFill

# escena número daño
@export var damage_number_scene: PackedScene


func _ready():
	add_to_group("enemy")
	$Hurtbox.add_to_group("enemy_hurtbox")

	player = find_nearest_player()
	health = max_health
	
	update_health_bar()


# -----------------------
# GRAVEDAD
# -----------------------
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta


# -----------------------
# MIRAR AL JUGADOR
# -----------------------
func face_player():
	if player == null:
		return

	sprite.flip_h = player.global_position.x < global_position.x


# -----------------------
# BUSCAR JUGADOR
# -----------------------
func find_nearest_player():
	var players = get_tree().get_nodes_in_group("player")

	if players.is_empty():
		return null

	var nearest = players[0]
	var min_dist = global_position.distance_to(nearest.global_position)

	for p in players:
		var dist = global_position.distance_to(p.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = p

	return nearest


# -----------------------
# RECIBIR DAÑO
# -----------------------
func take_damage(damage):
	health -= damage
	
	# 📊 MÉTRICAS
	MetricsManager.register_combat_start()
	
	show_damage_number(damage)
	flash_hit()
	apply_knockback()
	update_health_bar()

	if health <= 0:
		die()


# -----------------------
# FLASH BLANCO
# -----------------------
func flash_hit():
	sprite.modulate = Color(2.0, 2.0, 2.0, 1.0) # blanco fuerte
	
	await get_tree().create_timer(0.1).timeout
	
	sprite.modulate = Color.WHITE


# -----------------------
# BARRA DE VIDA
# -----------------------
func update_health_bar():
	var ratio = float(health) / float(max_health)
	bar_fill.scale.x = ratio


# -----------------------
# KNOCKBACK
# -----------------------
func apply_knockback():
	if player == null:
		return
	
	is_knockback = true
	
	var dir = sign(global_position.x - player.global_position.x)
	
	velocity.x = dir * knockback_force
	velocity.y = -80
	
	await get_tree().create_timer(0.2).timeout
	
	is_knockback = false


# -----------------------
# NUMERO DE DAÑO
# -----------------------
func show_damage_number(damage):
	if damage_number_scene == null:
		return
	
	var number = damage_number_scene.instantiate()
	number.text = str(damage)
	number.global_position = global_position + Vector2(0, -40)
	
	get_parent().add_child(number)


# -----------------------
# MUERTE
# -----------------------
func die():
	# 📊 MÉTRICAS
	MetricsManager.enemies_killed += 1
	
	queue_free()


# -----------------------
# ANIMACIONES
# -----------------------
func play_anim(anim):
	if sprite.animation != anim:
		sprite.play(anim)
