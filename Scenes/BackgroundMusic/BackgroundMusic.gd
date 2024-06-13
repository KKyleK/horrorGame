extends Node

var haunt : float
var toggle = 0
var visible : bool
@onready var fade = $Fader
@onready var bgmusic = $Graveyard
@onready var ghostmusic = $Gruesome

func _ready():
	bgmusic.play()
	bgmusic.set_stream_paused(true)
	
	
func _light(dim):
	haunt = dim
	
func _on_ghost_visible():
	if !bgmusic.playing:
		bgmusic.set_stream_paused(false)
		fade.play("fadein")
		
func _on_ghost_hide():
	toggle = 0
	fade.play("fadeout")
	
func _process(delta):
	if haunt <= 300 and toggle == 0:
		_crossfade()
		toggle = 1
		
	if haunt >= 450 and toggle == 1:
		_crossfade()
		toggle = 0


func _crossfade():
	if bgmusic.playing and ghostmusic.playing:
		pass
		
	if ghostmusic.playing:
		bgmusic.set_stream_paused(false)
		fade.play("FadeToGrave")
	else:
		ghostmusic.play()
		fade.play("FadeToGruesome")
