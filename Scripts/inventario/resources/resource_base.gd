extends Node2D

@export var max_health := 5
@export var resource_type := "wood"
@export var required_tool := "axe"
@export var drop_scene : PackedScene
@export var spawn_offset_y: float = -20

var health := 5

@onready var sprite = $Sprite2D

func _ready():
	health = max_health
	add_to_group("resource")

func take_damage_tool(damage, tool_name):
	
	# ❌ herramienta incorrecta
	if tool_name != required_tool:
		flash_wrong_tool()
		return
	
	# ✅ aplicar daño
	health -= damage
	
	# 🔴 efecto visual
	flash_hit()
	
	# 🔥 soltar 1 item por golpe
	drop_one()
	
	# 💀 morir si se queda sin vida
	if health <= 0:
		queue_free()

# 1 drop por golpe
func drop_one():
	if drop_scene == null:
		return
	
	var drop = drop_scene.instantiate()
	
	drop.global_position = global_position + Vector2(
		randf_range(-10, 10),
		-10
	)
	
	get_parent().add_child(drop)

# 🔴 golpe correcto
func flash_hit():
	sprite.modulate = Color(1,1,1,0.6)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

# 🔴 herramienta incorrecta
func flash_wrong_tool():
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
