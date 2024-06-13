extends CharacterBody2D



@export var SPEED : int
@export var ACCEL : int
@export var FRICTION : float
@export var jumpForce : int
@export var MAXGRAVITY : float
@export var sprintSpeed : float
@export var stamina : float
@export var slowDown : float
@export var gravity = 60
@export var jumpBuffer = 0.3
@export var sprintDelay : int
@onready var papers = [
	$Paper0,
	$Paper1,
	$Paper2,
	$Paper3,
	$Paper4,
	$Paper5,
	$Paper6,
	$Paper7,
	$Paper8,
	$Paper9
]
@onready var Step = $step
@onready var death = $Death
@onready var win = $Win
@onready var voice = $voice
@onready var paperSFX = $paperSFX
@onready var climbSFX = $climb
@onready var ghost = $torch/torch/light
@onready var _animated_sprite = $AnimatedSprite2D
@onready var paperFull = $PaperFull
@onready var paperStop = SPEED
var sprintTime : float = 0.00
var temp : float
var time : float = 0.00
var isExhausted : bool = false
const MAX_TIME = 0.60
var rope : bool = false
var paper : bool = false
var dead : bool = false
var grabbed : int = 0
var paralize = false

#func _ready():a
	#GameManager.player = self

func _ready():
	death.visible = false
	death.modulate.a = 0
	win.visible = false
	win.modulate.a = 0

func getHorizontalDirection() -> float:
	return Input.get_axis("moveLeft", "moveRight");

func _physics_process(delta):
	
	if grabbed == 10:
		Step.stop()
		paperFull.visible = false
		win.visible = true
		win.modulate.a = win.modulate.a + 0.005
		ghost.base_dim = 500
		return
	
	if(paralize):
		Step.stop()
		death.visible = true
		death.modulate.a = death.modulate.a + 0.005
		ghost.base_dim = 500
		return
	move_and_slide()
	#delta is time per frame so this keeps a rolling count of time per frame and can be used to do things per frame.
	time += delta
	if(velocity.y>5000):
		position.x=555
		position.y=635
	if !is_on_floor():
		velocity.y += gravity
		jumpBuffer -= delta
		if velocity.y > MAXGRAVITY:
			velocity.y = MAXGRAVITY
	if is_on_floor():
		jumpBuffer = 0.25
	
	if is_on_floor() or (jumpBuffer > 0 && velocity.y>0):
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jumpForce
			voice.stream = load("res://Scenes/SFX/jump/jump.tres")
			if !voice.playing:
				voice.volume_db = -5
				voice.play()
		
	var hDirection = getHorizontalDirection();
	
	if hDirection != 0:
		velocity.x = move_toward(velocity.x, hDirection * SPEED, ACCEL);
		if !Step.playing and is_on_floor() == true:
			Step.play()
		elif is_on_floor() == false:
			Step.stop()
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION);
		Step.stop()
	
	if Input.is_action_pressed("sprint") and (Input.is_action_pressed("moveRight") or Input.is_action_pressed("moveLeft")) and !isExhausted:
		_animated_sprite.speed_scale = 1.60
		sprintTime += delta
		#print(sprintTime)
		Step.pitch_scale = 1.4
		if sprintTime > 5:
			sprintTime = sprintDelay #sprint delay detaches the stamina so we can change how long the character is slowed down after sprinting without changing the amount of sprint available
			isExhausted = true
		if Input.is_action_pressed("moveRight"):
			velocity.x = velocity.x + sprintSpeed
		else:
			velocity.x = velocity.x - sprintSpeed
	else:
		_animated_sprite.speed_scale = 1
		Step.pitch_scale = 1
	if !Input.is_action_pressed("sprint"):
		if !isExhausted and sprintTime >= 0.01666666666667:
			sprintTime -= delta

	if isExhausted:
		_animated_sprite.speed_scale = 0.5
		Step.pitch_scale = 0.6
		if !voice.playing:
			voice.volume_db = 0
			voice.stream = load("res://Scenes/SFX/breath.wav")
			voice.play()
		if SPEED != slowDown:
			temp = SPEED
		SPEED = slowDown
		sprintTime -= delta
		
	if sprintTime < 0.0000000000:
		SPEED = temp
		isExhausted = false
		sprintTime = 0
		voice.stream = load("res://Scenes/SFX/deep-breath.wav")
		voice.volume_db = -20
		voice.play(7.76)
	
	if Input.is_action_pressed("moveRight"):
		_animated_sprite.flip_h = false
		
	#will flip the animation when moving left
	if Input.is_action_pressed("moveLeft"):
		_animated_sprite.flip_h = true
		
	#This will play the animation when the character is moving 
	if velocity.x > 0 or velocity.x < 0:
		_animated_sprite.play("Run")
	else:
		_animated_sprite.play("Idle")
	
	if rope == true:
		if Input.is_action_pressed("moveUp"):
			velocity.y = -150
			if time > MAX_TIME: 
				rope = false
		elif Input.is_action_pressed("moveDown"):
			velocity.y = 150
			if time > MAX_TIME: 
				rope = false
		elif Input.is_action_pressed("moveRight"):
			velocity.x = 100
			velocity.y = 0
			if time > 0.2: 
				rope = false
		elif Input.is_action_pressed("moveLeft"):
			velocity.x = -100
			velocity.y = 0
			if time > 0.2: 
				rope = false
		else:
			velocity.y = 0
			velocity.x = 0
		if !climbSFX.playing and !velocity.y == 0:
			climbSFX.play(1)
	if rope == false:
		climbSFX.stop()
		
	
	if paper and Input.is_action_just_pressed("interact"):
		if paperFull.visible == false and grabbed < 10:
			ghost.restore_torch()
			paperFull.get_child(grabbed).visible = true #makes the first paper visible.
			paperFull.visible = true
			SPEED = 0
			for node in get_tree().get_nodes_in_group("papers"):
				if position.distance_to(node.position) < 100:
					node.queue_free()
			if !paperSFX.playing:
					paperSFX.play(2.14)
		else:
			paperFull.visible = false
	elif !paper and Input.is_action_just_pressed("interact"):
		SPEED = paperStop
		grabbed += 1
		paperFull.visible = false

	#gives the player death boundaries
	#if position.y >= 3000:
		#die()

func _on_rope_body_entered(body):
	time = 0
	rope = true


func _on_rope_body_exited(body):
	# This prevents the character from sliping off the rope due to it exiting a rope at the same time it enter one 
	if time > 0.2:
		rope = false


func _on_paper_body_entered(body):
	paper = true


func _on_paper_body_exited(body):
	paper = false


func _on_rope_2_body_entered(body):
	time = 0
	rope = true



func _on_rope_2_body_exited(body):
	if time > 0.2:
		rope = false


func _on_torch_body_entered(body):
	if time > 1:
		dead = true

#func die():
	#GameManager.respawn_player()
