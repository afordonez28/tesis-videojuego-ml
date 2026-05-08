extends Label

var is_crit := false

func _ready():
	
	# 🎯 posición ligera variación
	position += Vector2(randf_range(-6, 6), randf_range(-3, 3))
	
	# escala inicial
	scale = Vector2.ONE * (1.3 if is_crit else 1.0)
	
	var tween = create_tween()
	
	# 🔥 subir más lento
	tween.tween_property(self, "position:y", position.y - 30, 1.0)
	
	# pequeño rebote si es crítico
	if is_crit:
		tween.parallel().tween_property(self, "scale", Vector2.ONE * 1.6, 0.2)
	
	# 🔥 fade más lento
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	queue_free()
