extends Node2D

@export var refills = 1
@export var always_multi_use = true
var used = false

func _ready() -> void:
	$AnimatedSprite2D.frame = refills - 1


func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not used:
		body.leaps = refills
		body.fire_bash_particles()
		if not always_multi_use:
			used = true
