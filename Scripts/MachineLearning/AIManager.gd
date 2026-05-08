extends Node

# -----------------------
# RESULTADOS IA
# -----------------------
var difficulty: float = 1.0
var tree_type: String = "unknown"
var cluster_type: String = "unknown"

# -----------------------
# VERSION
# -----------------------
var game_version: String = "v3_adaptive_ai"

# -----------------------
# CONFIG
# -----------------------
var update_interval := 5.0
var timer := 0.0

# -----------------------
# ARCHIVOS
# -----------------------
var file_index := 1


func _ready():
	file_index = get_next_file_index()


func _process(delta):
	timer += delta
	
	if timer >= update_interval:
		timer = 0
		run_ai()


# -----------------------
# IA
# -----------------------
func run_ai():
	var start_time = Time.get_ticks_msec()
	
	calculate_difficulty()
	classify_player_tree()
	cluster_player()
	adapt_enemies()
	
	var end_time = Time.get_ticks_msec()
	var response_time = (end_time - start_time) / 1000.0
	
	print("🎯 Dificultad:", difficulty)
	print("🌳 Árbol:", tree_type)
	print("🧩 Cluster:", cluster_type)
	print("⚠️ Error rate:", MetricsManager.get_error_rate())
	print("⏱ Tiempo:", response_time)
	
	save_ai_data(response_time)


# -----------------------
# REGRESIÓN
# -----------------------
func calculate_difficulty():
	var survival = max(MetricsManager.survival_time, 1)
	var kills = MetricsManager.enemies_killed
	var damage = MetricsManager.damage_taken
	
	var performance = (kills * 2.0) - (damage * 0.5)
	performance /= survival
	
	difficulty = clamp(performance, 0.5, 5.0)


# -----------------------
# ÁRBOL
# -----------------------
func classify_player_tree():
	var damage = MetricsManager.damage_taken
	var kills = MetricsManager.enemies_killed
	var resources = MetricsManager.resources_collected
	
	if damage > 200:
		tree_type = "defensivo"
	elif kills > 30 and damage < 100:
		tree_type = "agresivo"
	elif resources > kills:
		tree_type = "recolector"
	else:
		tree_type = "balanceado"


# -----------------------
# CLUSTERING
# -----------------------
func cluster_player():
	var survival = max(MetricsManager.survival_time, 1)
	
	var kills = MetricsManager.enemies_killed / survival
	var damage = MetricsManager.damage_taken / survival
	var resources = MetricsManager.resources_collected / survival
	
	var player_vector = Vector3(kills, damage, resources)
	
	var aggressive = Vector3(0.5, 0.2, 0.1)
	var defensive = Vector3(0.2, 1.0, 0.1)
	var collector = Vector3(0.1, 0.3, 0.8)
	
	var d1 = player_vector.distance_to(aggressive)
	var d2 = player_vector.distance_to(defensive)
	var d3 = player_vector.distance_to(collector)
	
	if d1 < d2 and d1 < d3:
		cluster_type = "agresivo"
	elif d2 < d1 and d2 < d3:
		cluster_type = "defensivo"
	else:
		cluster_type = "recolector"


# -----------------------
# ADAPTACIÓN
# -----------------------
func adapt_enemies():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		
		if not enemy is CharacterBody2D:
			continue
		
		if "speed" in enemy:
			if not enemy.has_meta("base_speed"):
				enemy.set_meta("base_speed", enemy.speed)
			
			enemy.speed = enemy.get_meta("base_speed") * (1 + difficulty * 0.2)
		
		if "damage" in enemy:
			if not enemy.has_meta("base_damage"):
				enemy.set_meta("base_damage", enemy.damage)
			
			var bonus = 1.0
			
			if cluster_type == "agresivo":
				bonus = 1.2
			elif cluster_type == "defensivo":
				bonus = 1.3
			
			enemy.damage = enemy.get_meta("base_damage") * (1 + difficulty * 0.2) * bonus
		
		if "damage_interval" in enemy:
			if not enemy.has_meta("base_interval"):
				enemy.set_meta("base_interval", enemy.damage_interval)
			
			enemy.damage_interval = enemy.get_meta("base_interval") * (1 - difficulty * 0.1)


# -----------------------
# GUARDAR IA
# -----------------------
func save_ai_data(response_time):
	var file_name = "ai_data" + str(file_index) + ".json"
	var path = "user://" + file_name
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file:
		var data = {
			"version": game_version,
			"difficulty": difficulty,
			"decision_tree": tree_type,
			"clustering": cluster_type,
			"response_time": response_time,
			"metrics": MetricsManager.get_metrics()
		}
		
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		
		print("💾 IA guardada:", file_name)
		file_index += 1


func get_next_file_index():
	var dir = DirAccess.open("user://")
	if dir == null:
		return 1
	
	var index = 1
	
	while true:
		var file_name = "ai_data" + str(index) + ".json"
		
		if not dir.file_exists(file_name):
			return index
		
		index += 1
