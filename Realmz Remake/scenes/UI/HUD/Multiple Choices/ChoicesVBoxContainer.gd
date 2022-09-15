extends VBoxContainer

signal choice_pressed

#var buttonupTextureUp : Texture = load("res://shared_assets/UI/buttonUP.png")
#var buttonupTextureDn : Texture = load("res://shared_assets/UI/buttonPRESSED.png")

var borderstyle : StyleBox = preload("res://shared_assets/UI/styleboxtexture_framenocenter_margins.stylebox")
#var tex = preload("res://shared_assets/UI/RadioButtonOn.png")

export var choices_button_tscn : PackedScene
export var separator_tscn : PackedScene
export var choices_yesno_tscn : PackedScene
export var choices_stop_tscn : PackedScene

var height : float = 0

func display_multiple_choices(choices : Array, scripts : Array) :
	print("ChoicesVBoxContainer display_multiple_choices")
	print(" ",choices,scripts)
	if choices.size() != scripts.size() :
		print("display_multiple_choices : Not as many scripts and choices !")
		return

	
	for c in get_children() :
		remove_child(c)
		c.queue_free()
	
	height = 0
	for i in range(choices.size()) :
		
		if scripts[i]!='STOP' and scripts[i]!='YESNO' :
			var newButton = choices_button_tscn.instance()
			newButton.set_text(choices[i])
			newButton.connect("pressed", self, "_on_choice_button_pressed", [scripts[i]])
			
			if scripts[i]=="TEXT" :
				newButton.set_just_text()
			
			add_child(newButton)
			var separation = separator_tscn.instance()
			add_child(separation)
			print("panel ", choices[i], " size : ", newButton.get_line_count())
			height += max(newButton.get_line_count()*17, 30)+10
		
		if scripts[i]=='STOP' :
			var newStop = choices_stop_tscn.instance()
			newStop.connect("pressed", self, "_on_choice_button_pressed", ["STOP"])
			add_child(newStop)
			height += 74
		
		if scripts[i]=="YESNO" :
			var newYesNo = choices_yesno_tscn.instance()
			newYesNo.connectbuttonstome(self)
			add_child(newYesNo)
			height += 40
		
#		newButton.set_meta("script", scripts[i])
#		newButton.add_constant_override("hseparation",0)
		
#		var newStyle : StyleBoxTexture = StyleBoxTexture.new()
#		newStyle.set_draw_center(true)
#		newStyle.set_texture(buttonupTextureUp )
#		newStyle.set_region_rect(Rect2(0,0,50,50)) 
#
#		newButton.add_stylebox_override("hover", newStyle )
#		newButton.add_stylebox_override("pressed", newStyle )
#		newButton.add_stylebox_override("focus", newStyle )
#		newButton.add_stylebox_override("disabled", newStyle )
#		newButton.add_stylebox_override("normal", newStyle )
#
		
		
#		newButton.text = choices[i]

#		newButton._set_size(Vector2(200,200))
		#connect(signal: String, target: Object, method: String, binds: Array = [  ], flags: int = 0)

#		separation.add_constant_override("separation", 10)
#		separation.add_constant_override("separator", StyleBoxEmpty)
#		separation.set("custom_styles/separator", StyleBoxEmpty)
#		separation.add_stylebox_override("separator", StyleBoxEmpty)
#		separation._set_size(Vector2(100,100))
		
		#TRUE
#		print("has_stylebox " , separation.has_stylebox("separator"))
		
		

		#		separation.hide()
		
	print("height : ",height)
	var screensize : Vector2 = OS.get_window_size()
	on_viewport_size_changed(screensize)


func _on_choice_button_pressed(script) :
		emit_signal( "choice_pressed", script)

func on_viewport_size_changed(screensize) :
	_set_global_position(Vector2((screensize.x-320-380)/2+10,(screensize.y-200-height)/2))
	_set_size(Vector2(380,screensize.y-210))
	update()

# Called when the node enters the scene tree for the first time.
func _ready():
#	self.set("custom_constants/separation", 100)
#	add_constant_override("separation", 100)
	pass
#	connect("choice_pressed", get_parent(), "_on_ChoicesVBoxContainer_choice_pressed")

#func _process(delta):
#	update()

func _draw() :
	print("drawinga  stylebox lol")
#	draw_texture(tex,get_position()+Vector2(-20,-20))
#	var gpos = Vector2(-10)
	draw_style_box(borderstyle, Rect2(Vector2(-18,-10),Vector2(get_size().x+18,height+20)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
