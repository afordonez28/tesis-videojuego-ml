extends Label

var velocity := Vector2(0, -50)

func _ready():
	scale = Vector2(0.7, 0.7)
	modulate = Color.RED

	# Desaparece después de un tiempo
	await get_tree().create_timer(0.6).timeout
	queue_free()

func _process(delta):
	position += velocity * delta
	modulate.a -= delta * 2
