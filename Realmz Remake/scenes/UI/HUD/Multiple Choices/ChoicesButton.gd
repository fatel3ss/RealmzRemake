extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#onready var label = $"Label"

signal pressed
#onready var button = $ChoicesButton

func set_text(text : String) :
#	var text2 = "I’ve had the same problem with labels’ rect size not working as one would expect. What you can do, at least until someone with more knowledge can shed more light in this, is get the font you are using (if you use the theme’s default font, you can easily just get the default font without much fuzz) and use its GetStringSize() method."
	.set_text(text)
#	var sz = $"Label".get_combined_minimum_size()
#	_set_size(Vector2(320,sz.y+10))

func set_just_text() :
	# remove the "on click"  stuff
#	$ChoicesButton.set_flat(true)
	$ChoicesButton.set_disabled(true)
#	var font = DynamicFont.new()
#	font.font_data = load(" res://Fonts/theldrowremake.ttf ")
#	set("custom_fonts/font", font)
	set("custom_fonts/font", load("res://Fonts/theldrowremake.tres"))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ChoicesButton_pressed():
	emit_signal("pressed")
