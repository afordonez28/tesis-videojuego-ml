extends CharacterBody2D

@export var speed: float = 50
@export var gravity: float = 500
@export var max_health: int = 100

var health: int

@onready var player = null
@onready var sprite = $AnimatedSprite2D

# UI
@onready var bar_fill = $HealthBar/BarFill
@onready var damage_spawner = $DamageNumberSpawner

@export var damage_number_scene: PackedScene


func _ready():
	add_to_group("enemy")
	$Hurtbox.add_to_group("enemy_hurtbox")

	player = find_nearest_player()
	health = max_health
	
	update_health_bar()


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta


func face_player():
	if player == null:
		return

	sprite.flip_h = player.global_position.x < global_position.x


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


# 🔥 RECIBIR DAÑO
func take_damage(damage):
	health -= damage
	
	# 📊 MÉTRICAS → empieza combate
	MetricsManager.register_combat_start()
	
	show_damage_number(damage)
	flash_hit()
	update_health_bar()

	if health <= 0:
		die()


# ❤️ BARRA DE VIDA
func update_health_bar():
	var ratio = float(health) / float(max_health)
	bar_fill.scale.x = ratio


# 🔴 EFECTO GOLPE
func flash_hit():
	sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE


# 🔢 NUMERO DE DAÑO
func show_damage_number(damage):
	if damage_number_scene == null:
		return
	
	var number = damage_number_scene.instantiate()
	number.text = str(damage)
	number.global_position = global_position + Vector2(0, -40)
	
	get_parent().add_child(number)


# 💀 MUERTE
func die():
	# 📊 MÉTRICAS
	MetricsManager.enemies_killed += 1
	MetricsManager.register_combat_end()
	
	queue_free()
	
	


func play_anim(anim):
	if sprite.animation != anim:
		sprite.play(anim)
