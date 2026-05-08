extends Node

# =========================
# CONSTANTES DE TIEMPO
# =========================
const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

# =========================
# SEÑALES
# =========================
signal time_tick(day:int, hour:int, minute:int)

# =========================
# CONFIGURACIÓN
# =========================
@export var INGAME_SPEED = 20.0   # 5 lento | 20 normal | 50 rápido
@export var INITIAL_HOUR = 12

# =========================
# VARIABLES INTERNAS
# =========================
var time: float = 0.0
var past_minute: int = -1

# 🔥 VARIABLES GLOBALES DE TIEMPO
var current_day: int = 0
var current_hour: int = 0
var current_minute: int = 0


# =========================
# INICIO
# =========================
func _ready():
	time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR


# =========================
# ACTUALIZACIÓN
# =========================
func _process(delta):
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
	_recalculate_time()


# =========================
# CICLO DÍA/NOCHE (0 a 1)
# =========================
func get_day_value():
	return (sin(time - PI / 2.0) + 1.0) / 2.0


# =========================
# RECALCULAR TIEMPO
# =========================
func _recalculate_time():

	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)

	# 🔥 DÍA
	current_day = int(total_minutes / MINUTES_PER_DAY)

	# 🔥 MINUTOS DEL DÍA ACTUAL
	var current_day_minutes = total_minutes % MINUTES_PER_DAY

	# 🔥 HORA Y MINUTO
	current_hour = int(current_day_minutes / MINUTES_PER_HOUR)
	current_minute = int(current_day_minutes % MINUTES_PER_HOUR)

	# 🔔 SEÑAL (solo cuando cambia el minuto)
	if past_minute != current_minute:
		past_minute = current_minute
		time_tick.emit(current_day, current_hour, current_minute)


# =========================
# FUNCIONES DE ACCESO
# =========================
func get_day():
	return current_day + 1   # 👈 empieza en día 1

func get_hour():
	return current_hour

func get_minute():
	return current_minute
