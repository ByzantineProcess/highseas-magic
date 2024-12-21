extends CharacterBody2D


const SPEED = 10.0
const JUMP_VELOCITY = -350.0

@export var lock = false
@export var unlocked_bash = false
@export var unlocked_leap = false
@export var spam_leap_protection = false
@export var leaps = 0
var should_walk = true
var bash_mode = false
var bashable = false
var jumping_rn = false
var bash_timer = 0.0
var should_bash_anyway = false
var cant_bash_for = 0.0
var leap_mode = false
var leap_scale = 0.0
var leap_chain = 0
var should_reset_leapchain = false
var just_finished_leap = false
var zoomout = false

func set_bashable(yesno: bool):
	if unlocked_bash:
		bashable = yesno

func start_leap():
	if unlocked_leap and leaps > 0:
		#print("not resetting leapchain anymore! starting a new leap")
		should_reset_leapchain = false
		lock = true
		leap_mode = true
		$LeapOverlay.visible = true
		leap_scale = 1
		leap_chain += 1
		leaps -= 1

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
	if is_on_floor() and should_reset_leapchain and leap_chain > 0:
		#print("alright, leapchain reset!")
		leap_chain = 0
		should_reset_leapchain = false
	
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
	
	if not $RayCast2D.is_colliding() and just_finished_leap and not should_reset_leapchain:
		should_reset_leapchain = true
		just_finished_leap = false
		#print("hey! i'll reset your leapchain as soon as you land.")
	
	# meteor leap code here, wow ig i like nesting?
	if Input.is_action_just_pressed("leap") and not $RayCast2D.is_colliding() and not is_on_floor():
		if $LeapCast.is_colliding():
			if $LeapCast.get_collider().name == "LeapTiles":
				start_leap()
	if Input.is_action_pressed("leap") and $RayCast2D.is_colliding() and not should_reset_leapchain:
		zoomout = true
		$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 0.6, 0.2)
		$Camera2D.zoom.y = lerp($Camera2D.zoom.y, 0.6, 0.2)
		$Camera2D.offset.y = lerp($Camera2D.offset.y, 100.0, 0.2)
	else:
		zoomout = false
	
	if leap_mode:
		$LeapOverlay.play("default")
		leap_scale += delta
		if is_on_floor() or $RayCast2D.is_colliding():
			just_finished_leap = true
			leap_mode = false
			lock = false
			const leap_mult = 2.25
			if spam_leap_protection:
				velocity.y = -300 * leap_scale * leap_mult / leap_chain
			else:
				velocity.y = -300 * leap_scale * leap_mult
			$LeapOverlay.visible = false
			print("finished a leap!")
			print("your leap's velocity was:")
			print(velocity.y)
			print("values were:")
			print(leap_chain)
	
	# hud code
	if unlocked_bash:
		$Camera2D/Hud/LearntSpells/Reboundicon.visible = true
	
	
	if bash_mode:
		bash_timer += delta
		$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 1.2, 0.2)
		$Camera2D.zoom.y = lerp($Camera2D.zoom.y, 1.2, 0.2)
		$Arrow.look_at($Camera2D.get_global_mouse_position())
	elif leap_mode or should_reset_leapchain and not is_on_floor():
		$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 0.8, 0.2)
		$Camera2D.zoom.y = lerp($Camera2D.zoom.y, 0.8, 0.2)
		if leap_mode:
			$PointLight2D.scale.x = lerp($PointLight2D.scale.x, leap_scale / 5, 0.2)
			$PointLight2D.scale.y = lerp($PointLight2D.scale.y, leap_scale / 5, 0.2)
			$PointLight2D.energy = leap_scale
		else:
			$PointLight2D.scale.x = lerp($PointLight2D.scale.x, 0.0, 0.2)
			$PointLight2D.scale.y = lerp($PointLight2D.scale.y, 0.0, 0.2)
	else:
		if not zoomout:
			$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 1.0, 0.2)
			$Camera2D.zoom.y = lerp($Camera2D.zoom.y, 1.0, 0.2)
			$Camera2D.offset.y = lerp($Camera2D.offset.y, 0.0, 0.2)
		$PointLight2D.scale.x = lerp($PointLight2D.scale.x, 0.0, 0.2)
		$PointLight2D.scale.y = lerp($PointLight2D.scale.y, 0.0, 0.2)
	
	
	
	if Input.is_action_pressed("bash") and not is_on_floor() and bashable and cant_bash_for < 0:
		#print("making bashmode true")
		bash_mode = true
		$Arrow.visible = true
		Engine.time_scale = lerp(Engine.time_scale, 0.005, 0.4)
		$ReboundParticles.emitting = true
		bash_timer += delta
		#print(bash_timer)
		if bash_timer > 0.078:
			bash_timer = 0.0
			bash_mode = false
			should_bash_anyway = true
			cant_bash_for = 0.5
	if not Input.is_action_pressed("bash") or not bashable or should_bash_anyway:
		#if should_bash_anyway:
			#print(bash_mode)
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
		if leap_mode:
			velocity = Vector2(0.0, 800.0)
	
	move_and_slide()
