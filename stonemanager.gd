extends Node2D

var stones
var stone_index = -1 # next one to drop
var dropping_stone = false

func _ready() -> void:
	# get all stones/children
	stones = get_children()

# Called when the node enters the scene tree for the first time.
func drop(body: Node2D) -> void:
	if body.name == "Player":
		stone_index += 1
		dropping_stone = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dropping_stone:
		stones[stone_index].position.y = lerp(stones[stone_index].position.y, -2767.0, 0.2)
