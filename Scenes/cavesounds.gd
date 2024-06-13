extends AudioStreamPlayer2D

var screenSize = DisplayServer.screen_get_size()
var rng = RandomNumberGenerator.new()
var timer = Timer.new()

func _ready():
	rng.randomize()
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.set_wait_time(rng.randf_range(5 , 15))
	timer.start()
func _on_timer_timeout():
		rng.randomize()
		var rndX = rng.randi_range(-screenSize.x / 2 , screenSize.x / 2)
		position.x = rndX
		play()
		timer.set_wait_time(rng.randf_range(5 , 15))
func _process(_delta):
	pass
