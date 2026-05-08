extends Node

# 📊 MÉTRICAS
var survival_time: float = 0.0
var enemies_killed: int = 0
var damage_taken: int = 0
var resources_collected: int = 0
var level_reached: int = 1

var last_combat_time: float = 0.0
var combat_intervals: Array = []
var in_combat: bool = false


# 🔢 contador de archivos
var file_index: int = 1


func _ready():
	# 🔥 Mostrar ruta real al iniciar el juego
	print("📁 Ruta real de guardado:")
	print(OS.get_user_data_dir())
	
	# 🔍 Buscar el siguiente número disponible
	file_index = get_next_file_index()


func _process(delta):
	survival_time += delta


# 🔍 BUSCAR SIGUIENTE NÚMERO DISPONIBLE
func get_next_file_index():
	var dir = DirAccess.open("user://")
	if dir == null:
		return 1
	
	var index = 1
	
	while true:
		var file_name = "metrics" + str(index) + ".json"
		
		if not dir.file_exists(file_name):
			return index
		
		index += 1


# 💾 GUARDAR MÉTRICAS
func save_metrics():
	var file_name = "metrics" + str(file_index) + ".json"
	var path = "user://" + file_name
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(get_metrics(), "\t"))
		file.close()
		
		print("✅ Guardado:", file_name)
		
		file_index += 1  # preparar el siguiente


# ⚔️ COMBATE
func register_combat_start():
	if not in_combat:
		var current_time = survival_time
		if last_combat_time > 0:
			var interval = current_time - last_combat_time
			combat_intervals.append(interval)
		
		in_combat = true


func register_combat_end():
	last_combat_time = survival_time
	in_combat = false


# 📊 OBTENER DATOS
func get_metrics():
	return {
		"survival_time": survival_time,
		"enemies_killed": enemies_killed,
		"damage_taken": damage_taken,
		"resources_collected": resources_collected,
		"level_reached": level_reached,
		"combat_intervals": combat_intervals
	}
