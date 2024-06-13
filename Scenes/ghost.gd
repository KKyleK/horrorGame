extends Sprite2D

var sum_time=0
@onready var animation = $AnimationPlayer
@onready var light = $light
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sum_time = sum_time+delta
	
	if(sum_time > 10):
		#animation.play("eyes_blink")
		sum_time=0
		
		
				
	#The eyes need to follow the light source. They should be rotated to always look in the middle.
	#var h_distance=light.texture.width
	#print (h_distance)
		
		
		
	pass
