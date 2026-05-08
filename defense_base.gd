extends Node2D

@export var max_health := 50
@export var damage := 10
@export var attack_interval := 1.0

var health := 50
var enemies_in_range: Array = []

@onready var damage_area = $DamageArea
@onready var hurtbox = $Hurtbox
@onready var bar_fill = $HealthBar/BarFill
@onready var timer = $Timer

func _ready():
	health = max_health
	
	# 🔥 DETECCIÓN PARA ATACAR
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_area.body_exited.connect(_on_damage_area_body_exited)
	
	# 🔥 DETECCIÓN PARA RECIBIR DAÑO
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	
	# 🔥 TIMER ATAQUE
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = attack_interval
	timer.start()
	
	update_health_bar()

# -----------------------
# DETECTAR ENEMIGOS (ATACAR)
# -----------------------
func _on_damage_area_body_entered(body):
	if body.is_in_group("enemy"):
		if not enemies_in_range.has(body):
			enemies_in_range.append(body)

func _on_damage_area_body_exited(body):
	if body.is_in_group("enemy"):
		enemies_in_range.erase(body)

# -----------------------
# ATAQUE AUTOMÁTICO
# -----------------------
func _on_timer_timeout():
	for enemy in enemies_in_range:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			enemy.take_damage(damage)

# -----------------------
# RECIBIR DAÑO (🔥 CLAVE)
# -----------------------
func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("damage"):
			take_damage(body.damage)
		else:
			# fallback por si no tiene variable damage
			take_damage(10)

# -----------------------
# FUNCIÓN DE DAÑO
# -----------------------
func take_damage(amount):
	health -= amount
	update_health_bar()
	
	if health <= 0:
		queue_free()

# -----------------------
# BARRA DE VIDA
# -----------------------
func update_health_bar():
	var ratio = float(health) / float(max_health)
	bar_fill.scale.x = ratio
