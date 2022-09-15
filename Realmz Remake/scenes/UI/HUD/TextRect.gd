extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var textLabel : RichTextLabel = $RichTextLabel
onready var hud : Control = $".."
onready var disablerButton = $DisablerButton #cover whole screen with mouse filter STOP to disable UI
onready var choicesContainer = $ChoicesVBoxContainer


signal interruption_over
signal choice_pressed

#var picked_choice_script = null

#var pause : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var screensize : Vector2 = OS.get_window_size()
	disablerButton._set_size(screensize)
	disablerButton._set_position(Vector2(0,-screensize.y+200))
	choicesContainer.add_constant_override ("separation",0)
#	choicesContainer.connect("choice_pressed", self, "_on_ChoicesVBoxContainer_choice_pressed", [scripts[i]])
	choicesContainer._set_global_position(Vector2((screensize.x-320-380)/2,5))
	choicesContainer._set_size(Vector2(380,screensize.y-210))
	


func on_viewport_size_changed(screensize:Vector2) :
	_set_size(Vector2(screensize.x-320, 200))
	_set_position(Vector2(0, screensize.y-200))
	textLabel._set_size(Vector2(screensize.x-320-15, 170))
	disablerButton._set_position(Vector2(0,-screensize.y+200))
	disablerButton._set_size(screensize)
	
	choicesContainer.on_viewport_size_changed(screensize)


func set_text(text : String, _interrupt : bool = true, _sound : String = "") :
#	textLabel.clear()
	if _sound != "" :
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book[_sound]
		SfxPlayer.play()
	
	var err = textLabel.parse_bbcode(text)
	if err != 0 :
		print("Error displaying BBCode in TextRect : ", err)
	else :
		print("textLabel.parse_bbcode : ", text)
	if _interrupt :
#		hud.set_mouse_filter(MOUSE_FILTER_IGNORE)
		disablerButton.show()
		GameState.set_paused(true)
		Input.set_custom_mouse_cursor(GameState.cursor_click)
#		pause = true
#		while(pause) :
#			pass

		#GDScriptFunctionState yield(object: Object = null, signal: String = "")
		yield(disablerButton, "pressed")
		print('""disablerButton, "pressed"', text)

		GameState.set_paused(false)
		Input.set_custom_mouse_cursor(GameState.cursor_sword)
		disablerButton.hide()
		textLabel.clear()

		emit_signal("interruption_over")




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



#func _on_DisablerButton_pressed():

#	pause = false

func display_multiple_choices(choices : Array, scripts : Array) :
	GameState.set_paused(true)
	Input.set_custom_mouse_cursor(GameState.cursor_click)
	choicesContainer.display_multiple_choices(choices, scripts)
	
	choicesContainer.show()
	var choice = yield(choicesContainer, "choice_pressed")
	choicesContainer.hide()
	
	GameState.set_paused(false)
	Input.set_custom_mouse_cursor(GameState.cursor_sword)
#	print(picked_choice_script)
	emit_signal("choice_pressed", choice)



#func _on_ChoicesVBoxContainer_choice_pressed(script):
#	picked_choice_script = script
#	print("pciked script : ", script)
#	pass # Replace with function body.
