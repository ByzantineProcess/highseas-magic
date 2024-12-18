extends Node2D

const FLICKER_INTERVAL = 0.1

var dt_total = 0.0

func _process(delta: float) -> void:
	dt_total += delta
	if dt_total > FLICKER_INTERVAL:
		dt_total = 0.0
		for i in get_children():
			i.scale *= randf_range(0.98, 1.02)
			if i.scale.x > 0.3:
				i.scale *= randf_range(0.97, 1.00)
			if i.scale.x < 0.15:
				i.scale *= randf_range(1, 1.03)
