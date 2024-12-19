extends Node2D

@export var ZOOM_IN_NOT_OUT = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if ZOOM_IN_NOT_OUT:
			$"../../Player/Camera2D".zoom.x = lerp($"../../Player/Camera2D".zoom.x, 1.5, 0.2)
		else:
			$"../../Player/Camera2D".zoom.x = lerp($"../../Player/Camera2D".zoom.x, 1.0, 0.2)
