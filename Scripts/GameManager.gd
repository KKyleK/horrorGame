#extends Node

#var current_checkpoint : checkpoint

#var player : player

#func respawn_player():
	#if current_checkpoint != null:
		#player.position = current_checkpoint.global_position

#tells the player which activated checkpoint to respawn at
#automatically overrides the last checkpoint once new one is crossed

