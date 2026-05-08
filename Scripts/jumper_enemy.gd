extends CharacterBody2D

@export var speed: float = 1  # Velocidad de avance en X
@export var jump_force: float = -1  # Fuerza de salto
@export var gravity: float = 500.0  # Fuerza de gravedad
@export var jump_interval: float = 0.8  # Tiempo entre saltos
@export var health: int = 1  # Vida

#busca jugador
@onready var player = null  # Inicializa la variable en nulo
var jump_timer: float = 0.0  # Temporizador para los saltos

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
		if direction.x < 0:
			$AnimatedSprite2D.scale.x = -1  # Mirar a la izquierda
		elif direction.x > 0:
			$AnimatedSprite2D.scale.x = 1   # Mirar a la derecha	
		if not is_on_floor():
			velocity.x = direction.x * speed  # Moverse horizontalmente hacia el jugador
			# Reproducir animación de salto
			if velocity.y<0:
				$AnimatedSprite2D.play("jump")
			else:
				$AnimatedSprite2D.play("fall")
			
		elif is_on_floor():
			velocity.x = 0	
			$AnimatedSprite2D.play("static")
			
		# Saltar solo cuando está en el suelo y el temporizador lo permite
		jump_timer -= delta
		if is_on_floor() and jump_timer <= 0:
			velocity.y = jump_force  # Aplicar salto
			jump_timer = jump_interval  # Reiniciar temporizador
	
			

	move_and_slide()  # Aplica movimiento con colisiones

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
	


	
