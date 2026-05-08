extends Node2D

@export var enemies : Array[PackedScene]
@export var probabilities : Array[float]
@export var growth : Array[float] 

@onready var respawn_timer = $RespawnTimer

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()


func _process(delta):

	# 🔥 Cambiar probabilidades con el tiempo
	for i in range(probabilities.size()):

		if i < growth.size():
			probabilities[i] += growth[i] * delta

		# evitar negativos o cero
		probabilities[i] = max(probabilities[i], 1)


func _on_respawn_timer_timeout():

	# 🌓 SOLO DE NOCHE
	var hour = TimeManager.get_hour()

	if hour >= 18 or hour < 6:
		spawn_enemy()
	else:
		print("Es de día, no spawnea")


func spawn_enemy():

	if enemies.size() == 0:
		print("No hay enemigos configurados")
		return

	var total_weight = 0
	for p in probabilities:
		total_weight += p

	var r = rng.randi_range(1, int(total_weight))

	var cumulative = 0
	var selected_enemy : PackedScene = null

	for i in range(enemies.size()):
		cumulative += probabilities[i]

		if r <= cumulative:
			selected_enemy = enemies[i]
			break

	if selected_enemy == null:
		return

	var enemy_instance = selected_enemy.instantiate()

	if rng.randi_range(0,1) == 0:
		enemy_instance.position = Vector2(-1080, 13)
	else:
		enemy_instance.position = Vector2(1350, 13)

	add_child(enemy_instance)
