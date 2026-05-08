extends Node2D

@export var mochila: Mochila

@onready var control: Control = $CanvasLayer/Control

const MADERA = preload("res://items/madera.tres")

func _ready() -> void:
	control.mochila = mochila
	control.agregar_item_a_mochila(MADERA)
	print(mochila.objetos)
