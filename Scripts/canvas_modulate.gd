extends CanvasModulate

@export var gradient_texture: GradientTexture1D

func _process(delta):
	var value = TimeManager.get_day_value()
	self.color = gradient_texture.gradient.sample(value)
