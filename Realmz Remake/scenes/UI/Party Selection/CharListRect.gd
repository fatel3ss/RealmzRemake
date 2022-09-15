extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func can_drop_data(_pos, data):
	# does the character come from this ?
	# [character, button ]
	var buttonsList = data[1].get_parent().get_parent().get_parent()
	if name == "TeamListRect" :
		if GameGlobal.get_currentcampaign_max_party_size() <= $"TeamScrollContainer/TeamVBoxContainer".get_child_count() :
			return false
	return buttonsList.name != name

func drop_data(_pos, data):
	var buttonsList = data[1].get_parent().get_parent().get_parent()
	get_parent()._on_char_button_pressed(data[1])
	if buttonsList.name == "EligibleListRect" :
		get_parent()._on_AddButton_pressed()
	if buttonsList.name == "TeamListRect" :
		get_parent()._on_DropButton_pressed()
	
	
