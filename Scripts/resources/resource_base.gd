extends StaticBody2D

@export var max_health: int = 5
@export var required_tool: String = "none" # "axe", "pickaxe"

var health: int

func _ready():
	health = max_health

func take_damage(amount: int, tool: String):
	if tool != required_tool:
		return # herramienta incorrecta
	
	health -= amount
	
	if health <= 0:
		destroy()

func destroy():
	queue_free()
