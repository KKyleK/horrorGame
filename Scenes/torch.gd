extends PointLight2D

var base_dim = 600 #This is overall strength of the torch.
var new_dim : float #this is the changing strength of the torch.
var grow = true
signal light(light)
var torch_shrink_timer = 0
@export var shrink_timer = 10 #how often the light will shrink, and the ghost will move closer.

@onready var ghost = $ghost
@onready var eye_light = $ghost/eye_light

#Variables that control the ghost's movement.
var move_timer=0

var current_position
var move=false
var move_to=0
#The angle the ghost will move between in radiants.
var move_lower_bound=1
var move_upper_bound=2.5
var move_speed=0

var rng = RandomNumberGenerator.new()
var player_direction

@export var buffer_shrink_amount=50 #this is how much the ghost moves closer to the player when the light shrinks.
@export var buffer=150 #How far the ghost should appear away from the light
var new_buffer

var is_visable
signal ghost_visible
signal ghost_hide
var visable_timer=0
var number_pages=0
@export var make_visable_timer=0 #How many seconds until the ghost becomes visable.

var first_time = true #really big hack. Sorry!

# Called when the node enters the scene tree for the first time.
func _ready():
	
	is_visable=false
	ghost.modulate.a=0
	
	texture.width=base_dim
	texture.height=base_dim
	new_dim=base_dim

	current_position = 1.2
	new_buffer=buffer
	#There apppears to be a bug with how the eye light and the ghost's light are added to eachother when
	#blend mode is set to mix. TLDR when only the eye light is effecting the ghost, the eye light should be set to mix.
	#When the main light is also showing the ghost, the blend_mode should be set to add.
	eye_light.blend_mode = BLEND_MODE_MIX
	
	pass

func _process(delta):
	#Shrink the torch if the ghost is visable.
	if(is_visable):
		torch_shrink_timer	= delta + torch_shrink_timer
	#Make the torch slowly grow smaller.
	if(torch_shrink_timer > shrink_timer):
		base_dim = base_dim - 75
		torch_shrink_timer=0
		new_buffer=buffer-buffer_shrink_amount

	buffer=buffer+((new_buffer-buffer)/20) #adds a smoothing effect to the ghost moving closer to the player.
	if(buffer < 40):
		eye_light.blend_mode = BLEND_MODE_ADD
	else:
		eye_light.blend_mode= BLEND_MODE_MIX
#Grow and shrink the light.
	if (grow):
		new_dim = new_dim + (base_dim*0.0008)
	else:
		new_dim = new_dim - (base_dim*0.0008)
	texture.height=new_dim
	texture.width=new_dim
	light.emit(base_dim)
	if (new_dim > (base_dim*1.1)):
		grow=false
	if (new_dim < (base_dim*0.9)):
		grow=true

	#Move the ghost randomly, ensuring the ghost is always facing the player.
	ghost.look_at(to_global(Vector2(position.x,position.y)))
	move_timer = move_timer + delta
	if(move_timer > 3 && move==false): #move every 3 seconds.
		move=true
		move_to = current_position
		#A change of 0.15 here is about 8 degrees. (So when the ghost moves, it will move by at least 8 degrees).
		while(abs(move_to-current_position) < 0.15):
			move_to = rng.randf_range(move_lower_bound, move_upper_bound)
			if(player_direction=="right"):
				move_to=move_to*-1

	if (move):
		#The absolute value smooths out the animation.
		#Adding 0.001 is needed to ensure the ghost reaches its destination.
		move_speed = (abs(current_position-move_to))/20 + 0.001
		move_timer=0
		if(current_position < move_to):
			current_position = current_position+move_speed
			if(current_position > move_to):
				move=false
		else:
			current_position = current_position-move_speed
			if(current_position < move_to):
				move=false

	ghost.position=(Vector2(
		sin(current_position) * ((new_dim/3.2) + buffer),
		cos(current_position) * ((new_dim/3.2)+ buffer)
		))

	if(is_visable==true || first_time):
		
		first_time = false #This is a hack. Without it, the ghost can be unpredictable on instantiation.
		#Player is currently facing the ghost so it dissapears.
		if(get_parent().get_parent().get_parent()._animated_sprite.flip_h == true && player_direction!="left" || 
			get_parent().get_parent().get_parent()._animated_sprite.flip_h == false && player_direction!="right"):
			ghost.modulate.a=ghost.modulate.a-0.01

		#Player is not looking at the ghost. Resore it's opacity (1).
		else:
			if(ghost.modulate.a < 0.99):
				ghost.modulate.a=ghost.modulate.a+0.01
	
		#Ghost has been stared at and is now fully invisible. Flip it behind the player.
		if (ghost.modulate.a < 0):
			if (get_parent().get_parent().get_parent()._animated_sprite.flip_h == true && player_direction!="left"):
				player_direction="left"
				move=false
				current_position=current_position*-1
				ghost.flip_v=true
				move_timer=0
			else:
				player_direction="right"
				move=false
				current_position=current_position*-1
				ghost.flip_v=false
				move_timer=0
	else:
		visable_timer=visable_timer+delta
		if(ghost.modulate.a >0):
			ghost.modulate.a = ghost.modulate.a-0.01
	
	if(visable_timer >= make_visable_timer && !is_visable):
		is_visable=true
		ghost_visible.emit()
		ghost.modulate.a=0.01

	
	if(new_dim<=203):
		print("hello")
		ghost.animation="attack"
		get_parent().get_parent().get_parent()._animated_sprite.animation="Death"
		get_parent().get_parent().get_parent().paralize=true
	pass

#TODO: Make this not hardcoded.
func restore_torch():
	base_dim=600
	new_buffer=150
	is_visable=false
	ghost_hide.emit()
	number_pages=number_pages+1
	visable_timer=75+number_pages	#The player has one minute to find their first note. On each note pickup, ghost spawns in 5 seconds.
	eye_light.blend_mode = BLEND_MODE_MIX
	pass
