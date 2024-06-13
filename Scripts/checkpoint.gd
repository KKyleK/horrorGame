extends Node2D
#class_name checkpoint

@export var spawnpoint = false

var activated = false

#when checkpoint entered/activated this tells the game manager the new checkpoint  
func activate():
	GameManager.current_checkpoint = self
	activated = true
	$AnimatedSprite2D.play("moving")
	

#func _on_area_2d_area_entered(area):
#	if area.get_parent() is player && !activated:
#		activate()
