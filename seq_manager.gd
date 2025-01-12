extends AnimationPlayer

var playedBash = false
var playedLeap = false

func _ready() -> void:
	stop()

func _on_bash_spell_seq_trigger_body_entered(body: Node2D) -> void:
	active = true
	if body.name == "Player" and not playedBash:
		play("BashSpellGrant")
	playedBash = true
	pass


func _on_leap_spell_seq_trigger_body_entered(body: Node2D) -> void:
	active = true
	if body.name == "Player" and not playedLeap:
		play("LeapSpellGrant")
	playedLeap = true
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().change_scene_to_file("res://end.tscn")
