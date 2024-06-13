extends PointLight2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#blend_mode=Light2D.BLEND_MODE_MIX
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(get_parent().get_parent().new_dim) Fix the lighting bug that occurs when the ghost gets too close
	#by setting the eye_light to "add".
	#if(blend_mode==Light2D.BLEND_MODE_MIX && get_parent().):
	
	
	pass
