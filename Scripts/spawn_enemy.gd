extends Area2D

#Variable para la instancia del enemigo
@onready var Enemy_Rana = load("res://scenes/rana.tscn")

#variables
var bool_spawn =true
var random = RandomNumberGenerator.new() #Generar posicion
var i:int =0 #derecha o izquierda
var x:int =0 #generar o no generar

func _ready() -> void:
	random.randomize()

func _process(_delta: float) -> void: #Guion bajo porque delta no se usa
	spawn()

func spawn():
	if bool_spawn:
		x= random.randi_range(0,100)
		i= random.randi_range(0,4)
		$respawn_rana.start()
		bool_spawn=false
		
		#crear enemigo
		var enemy_instance = Enemy_Rana.instantiate()
		enemy_instance.scale = Vector2(0.5, 0.5)

		if i<=2:
			enemy_instance.position = Vector2(-1080,13) 
		else:
			enemy_instance.position = Vector2(1350,13)
		if x==3:
			add_child(enemy_instance)

func _on_respawn_rana_timeout() -> void:
	bool_spawn = true
