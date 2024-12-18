extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop()


func _on_area_2d_body_entered(body: Node2D) -> void:
	# i strongly dislike this and hate this for many reasons
	$"../../Player".set_bashable(true)
	frame = 1
func _on_area_2d_body_exited(body: Node2D) -> void:
	$"../../Player".set_bashable(false)
	frame = 0
