extends Node2D
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
var paperCorrdinates =[
	Vector2(4634,43), #good
	Vector2(7394,-1037), #good
	Vector2(8865,-925), #good
	Vector2(10138,-956), #good
	Vector2(11778,-405), #good
	Vector2(10634,545), #good
	Vector2(5330,907), #good
	Vector2(8234,1435), #good
	Vector2(7098,2387), #good
	Vector2(3210,2685), #good
	Vector2(8162,-1797), #good
	Vector2(3866,795), #good
	Vector2(2266,1203), #good
	Vector2(8074,-2549) #good
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var j : int = 0
	randomize()
	paperCorrdinates.shuffle()
	for i in papers:
		i.position.x = paperCorrdinates[j].x
		i.position.y = paperCorrdinates[j].y
		j += 1



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
