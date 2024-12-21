extends Node2D

@export var refills = 1
var used = false

func _ready() -> void:
	$AnimatedSprite2D.frame = refills - 1


func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not used:
		body.leaps += refills
		used = true
