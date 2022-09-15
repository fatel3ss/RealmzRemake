extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#onready var yesButton = $"ChoicesYesNoBox/YesButton"
#onready var noButton = $"ChoicesYesNoBox/NoButton"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_YesButton_pressed():
	emit_signal("pressed")


func _on_NoButton_pressed():
	emit_signal("pressed")

func connectbuttonstome(obj : Object) :
	var yesButton = $"ChoicesYesNoBox/YesButton"
	var noButton = $"ChoicesYesNoBox/NoButton"
	yesButton.connect("pressed", obj,"_on_choice_button_pressed", ["YES"])
	noButton.connect("pressed", obj,"_on_choice_button_pressed", ["NO"])
#	newButton.connect("pressed", self, "_on_choice_button_pressed", [scripts[i]])
