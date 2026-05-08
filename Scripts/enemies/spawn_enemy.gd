extends Node2D

@export var enemies : Array[PackedScene]
@export var probabilities : Array[float]
@export var growth : Array[float] 

@export var min_group_size := 3
@export var max_group_size := 5

@onready var respawn_timer = $RespawnTimer
@onready var group_manager = $EnemyGroupManager

var rng = RandomNumberGenerator.new()


# -----------------------
# READY
# -----------------------
func _ready():
	rng.randomize()


# -----------------------
# ACTUALIZAR PROBABILIDADES
# -----------------------
func _process(delta):

	for i in range(probabilities.size()):

		if i < growth.size():
			probabilities[i] += growth[i] * delta

		probabilities[i] = max(probabilities[i], 1)


# -----------------------
# TIMER
# -----------------------
func _on_respawn_timer_timeout():

	var hour = TimeManager.get_hour()

	if hour >= 18 or hour < 6:
		spawn_enemy()
	else:
		print("Es de día, no spawnea")


# -----------------------
# SPAWN ENEMY
# -----------------------
func spawn_enemy():

	if enemies.is_empty():
		print("No hay enemigos configurados")
		return

	# 🔢 Selección por probabilidad
	var total_weight := 0.0
	for p in probabilities:
		total_weight += p

	var r := rng.randf_range(0.0, total_weight)

	var cumulative := 0.0
	var selected_enemy : PackedScene = null

	for i in range(enemies.size()):
		cumulative += probabilities[i]

		if r <= cumulative:
			selected_enemy = enemies[i]
			break

	if selected_enemy == null:
		print("Error seleccionando enemigo")
		return

	print("Spawn:", selected_enemy.resource_path)

	# 🔍 Obtener player
	var player = get_tree().get_first_node_in_group("player")

	if not player:
		print("No se encontró el player")
		return

	# 📍 Posición base cerca del jugador
	var offset_x = rng.randi_range(300, 500)
	var side = rng.randi_range(0, 1)

	var base_x = player.global_position.x + (-offset_x if side == 0 else offset_x)
	var ground_y = player.global_position.y

	var base_position = Vector2(base_x, ground_y)

	# 🔥 Detectar si es ogro
	var is_ogre = selected_enemy.resource_path.find("ogro") != -1


	# =========================
	# 🐗 OGROS → GRUPO
	# =========================
	if is_ogre:

		var group_size = rng.randi_range(min_group_size, max_group_size)

		for i in range(group_size):

			var enemy_instance = selected_enemy.instantiate()

			var offset = Vector2(
				rng.randi_range(-40, 40),
				rng.randi_range(-10, 10)
			)

			enemy_instance.global_position = base_position + offset

			if group_manager:
				group_manager.add_child(enemy_instance)
			else:
				print("ERROR: No se encontró EnemyGroupManager")


	# =========================
	# 🐸 OTROS → NORMAL
	# =========================
	else:

		var enemy_instance = selected_enemy.instantiate()

		enemy_instance.global_position = base_position

		if group_manager:
			group_manager.add_child(enemy_instance)
		else:
			print("ERROR: No se encontró EnemyGroupManager")
