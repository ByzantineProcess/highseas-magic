extends CharacterBody2D


const SPEED = 10.0
const JUMP_VELOCITY = -350.0

@export var lock = false
var should_walk = true
var bash_mode = false
var bashable = false
var jumping_rn = false
var bash_timer = 0.0
var should_bash_anyway = false
var cant_bash_for = 0.0

func set_bashable(yesno: bool):
	bashable = yesno
	

func _bash():
	# exiting bash mode, do the bash.
	var distance_vector = global_position - $Camera2D.get_global_mouse_position()
	velocity = Vector2()
	velocity += distance_vector.normalized() * -1 * SPEED * 50
	bash_timer = 0.0
	should_bash_anyway = false
	cant_bash_for = 0.3
	#print(distance_vector.normalized() * SPEED)

func _ready() -> void:
	lock = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		should_walk = false
		jumping_rn = true
	if is_on_floor() and not Input.is_action_pressed("jump"):
		should_walk = true
		jumping_rn = false
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x += direction * SPEED
	elif is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, 0.17)
	if velocity.x < 0.01 and velocity.x > -0.01 and should_walk == true:
		$AniSprite.play("walk")
	if should_walk == false and not is_on_floor() and not $RayCast2D.is_colliding():
		$AniSprite.play("jump")
	if $RayCast2D.is_colliding() and should_walk:
		$AniSprite.play("walk")
	
	if bash_mode:
		bash_timer += delta
		$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 1.3, 0.2)
		$Camera2D.zoom.y = lerp($Camera2D.zoom.y, 1.3, 0.2)
		$Arrow.look_at($Camera2D.get_global_mouse_position())
	else:
		$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 1.0, 0.2)
		$Camera2D.zoom.y = lerp($Camera2D.zoom.y, 1.0, 0.2)
	
	if Input.is_action_pressed("bash") and not is_on_floor() and bashable and cant_bash_for < 0:
		#print("making bashmode true")
		bash_mode = true
		$Arrow.visible = true
		Engine.time_scale = lerp(Engine.time_scale, 0.005, 0.18)
		$ReboundParticles.emitting = true
		bash_timer += delta
		if bash_timer > 0.18:
			bash_timer = 0.0
			bash_mode = false
			should_bash_anyway = true
			cant_bash_for = 0.5
	if not Input.is_action_pressed("bash") or not bashable or should_bash_anyway:
		if should_bash_anyway:
			print(bash_mode)
		if bash_mode or should_bash_anyway:
			bash_mode = false
			_bash()
		bash_mode = false
		$Arrow.visible = false
		Engine.time_scale = 1.0
	cant_bash_for -= delta
	if velocity.x > 300:
		velocity.x = 300
	if velocity.x < -300:
		velocity.x = -300
	if lock:
		velocity = Vector2()
	
	move_and_slide()
