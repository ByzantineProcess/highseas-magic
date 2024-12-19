extends AnimationPlayer

var playedBash = false

func _ready() -> void:
	stop()

func _on_bash_spell_seq_trigger_body_entered(body: Node2D) -> void:
	active = true
	if body.name == "Player" and not playedBash:
		play("BashSpellGrant")
	playedBash = true
	pass
