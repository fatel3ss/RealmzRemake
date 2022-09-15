extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var pickedparty : Array = []

onready var charPickRect = $CharPickRect
onready var okButton : Button = $OKButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_viewport_size_changed(screensize) :
	set_size(screensize)

func show() :
	pickedparty = GameGlobal.player_characters
	charPickRect.fill()
	.show()

func fill() -> void :
	charPickRect.fill()


func set_ready(rdy : bool, party : Array) :
	okButton.disabled = not rdy
	if rdy :
		pickedparty = party#GameGlobal.player_characters = party
	else :
		pickedparty.clear()


func _on_CancelButton_pressed():
	hide()




func _on_OKButton_pressed():
	GameState.set_paused(false)
	GameGlobal.player_characters = pickedparty
	get_parent().fillCharactersRect() # ask OWHUDNode2D
	GameGlobal.refresh_OW_HUD()
	hide()
	MusicStreamPlayer.play_music_map()
	var map = NodeAccess.__Map()
	map.set_ow_character_icon(GameGlobal.player_characters[0].icon)
