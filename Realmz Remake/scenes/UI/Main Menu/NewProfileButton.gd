extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var lineEdit : LineEdit = $LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err_connecttoself = connect("pressed", self, "_on_Button_pressed")

func _on_Button_pressed()  -> void :
	var new_text = lineEdit.text
	if new_text == '' or new_text=="Profile Created !" :
		return
	var success = GameGlobal.create_new_profile(new_text)
	if success :
		GameGlobal.set_current_profile(new_text)
		lineEdit.text = "Profile Created !"
		self.get_parent().build_profiles_list()
		self.get_parent().set_text(new_text)
	else :
		print("This directory already exists !")
		lineEdit.text = "Profile already exists !"

#	fill()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
