extends CharacterBody2D

@export var speed: float = 1  # Velocidad de avance en X
@export var gravity: float = 500.0  # Fuerza de gravedad
@export var health: int = 1  # Vida

#busca jugador
@onready var player = null  # Inicializa la variable en nulo


func _ready():
	player = find_nearest_player()

func _physics_process(delta: float) -> void:
	# Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity.y += gravity * delta

	# Si el jugador existe y es válido, buscar dirección
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		
		# Ajustar dirección del sprite
		if direction < 0:
			$AnimatedSprite2D.position.x=-3
			$AnimatedSprite2D.scale.x=-1
		elif direction >0:
			$AnimatedSprite2D.position.x=1
			$AnimatedSprite2D.scale.x=1
			
		if direction:
			velocity.x = direction * speed
			if is_on_floor():
				$AnimatedSprite2D.play("run")
		else:
			velocity.x = direction * speed
			if is_on_floor():
				$AnimatedSprite2D.play("static")
		move_and_slide() #Aplica movimiento y coliciones

func find_nearest_player():
	var players = get_tree().get_nodes_in_group("player")  # Obtiene todos los jugadores en el grupo
	if players.is_empty():
		return null  # Retorna null si no hay jugadores

	var nearest_player = players[0]
	var min_distance = global_position.distance_to(nearest_player.global_position)

	for p in players:
		var distance = global_position.distance_to(p.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_player = p

	return nearest_player
