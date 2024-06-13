extends CharacterBody2D

var SPEED = 200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng = RandomNumberGenerator.new()
var timer = Timer.new()
@onready var movesfx = $ghostmove
@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
var facing_right = true

func _ready():
	$AnimationPlayer.play("run")
	rng.randomize()
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.set_wait_time(rng.randf_range(30 , 60))
	timer.start()
	
func _on_timer_timeout():
	rng.randomize()
	movesfx.pitch_scale = randf_range(0.5 , 2)
	movesfx.play()
	timer.set_wait_time(rng.randf_range(60 , 120))
	
func _physics_process(delta):
	velocity.y += gravity * delta
	if velocity.y > 1000:
		velocity.y = 1000
		
	if !$RayCast2D.is_colliding() && is_on_floor():
		flip()
	
	velocity.x = SPEED
	move_and_slide()

#flips ghost when it gets to the edge
func flip():
	facing_right = !facing_right
	
	scale.x = abs(scale.x) * -1
	if facing_right:
		SPEED = abs(SPEED)
	else:
		SPEED = abs(SPEED) * -1
	
	# Handle Jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY
	

	# Get the input direction and handle the movement/deceleration.
	
	#moves the ghost according to player but we scrapped this
	#var direction = Input.get_axis("moveLeft", "moveRight")
	#if direction:
	#	velocity.x = direction * SPEED
	#else:
	#	velocity.x = move_toward(velocity.x, 0, SPEED)
		

	#if direction != 0:
	#	sprite.flip_h = (direction == -1)

	#move_and_slide()
	
	#update_animations(direction)
	
#func update_animations(direction):
#	if is_on_floor():
#		if direction == 0:
#			ap.play("idle")
#		else:
##			ap.play("run")
	#else:
	#	if velocity.y < 0: 
	#		ap.play("fall")
	#		
