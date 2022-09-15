#SpellsRect is the script for the spells menu on the HUD
extends NinePatchRect




# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var spellbuttonTSCN : PackedScene = preload("res://scenes/UI/HUD/Spells/SpellButton.tscn")

onready var spellButtonIconGray : Texture = preload("res://scenes/UI/HUD/Spells/SpellButtonIconGray.png" )
onready var spellButtonIconGreen: Texture = preload("res://scenes/UI/HUD/Spells/SpellButtonIconGreen.png" )
onready var spellButtonIconRed : Texture = preload("res://scenes/UI/HUD/Spells/SpellButtonIconRed.png" )

onready var spellLevelsRect = $"TopContainer/SpellLevelsRect/SpellLevelsContainer"
onready var spelllistContainer = $"TopContainer/SpellsListRect/ScrollContainer/SpellListContainer"

onready var spellPowersContainer = $"MiddleContainer/PowerLevelsRect/PowerLevelsContainer"

onready var charportrait : TextureRect = $"BottomContainer/PortraitFrameRect/PortraitRect"
onready var charnameLabel : Label = $"MiddleContainer/SpellInfoRect/CharNameRect/CharNameLabel"

onready var levelgroup: ButtonGroup = ButtonGroup.new()
onready var powerbgroup: ButtonGroup = ButtonGroup.new()

#boxes for screen reszing
onready var topcontainer : HBoxContainer = $"TopContainer"
onready var midcontainer : HBoxContainer = $"MiddleContainer"
onready var botcontainer : HBoxContainer = $"BottomContainer"

# spell info controls
onready var aoeTextureRect : TextureRect = $"MiddleContainer/SpellInfoRect/SpellAoERect/AoETextureRect"
onready var dmgminLabel : Label = $"MiddleContainer/SpellInfoRect/StatsRect/DamageMinLabel"
onready var dmgmaxLabel : Label = $"MiddleContainer/SpellInfoRect/StatsRect/DamageMaxLabel"
onready var durminLabel : Label = $"MiddleContainer/SpellInfoRect/StatsRect/DurationMinLabel"
onready var durmaxLabel : Label = $"MiddleContainer/SpellInfoRect/StatsRect/DurationMaxLabel"
onready var rngLabel : Label = $"MiddleContainer/SpellInfoRect/StatsRect/RangeLabel"
onready var rotLabel : Label = $"MiddleContainer/SpellInfoRect/StatsRect/RotationLabel"
onready var losLabel : Label = $"MiddleContainer/SpellInfoRect/StatsRect/LoSLabel"
onready var trgLabel : Label = $"MiddleContainer/SpellInfoRect/StatsRect/TargetsLabel"
onready var attributesLabel : Label = $"MiddleContainer/SpellInfoRect/AttributesLabel"
onready var costformulaLabel : Label = $"MiddleContainer/SpellInfoRect/CostFormulaLabel"
onready var powerLabel : Label = $"MiddleContainer/SpellInfoRect/SpellCostBGRect/PowerLabel"
onready var spcostLabel : Label = $"MiddleContainer/SpellInfoRect/SpellCostBGRect/SPCostLabel"
onready var charaspLabel : Label = $"MiddleContainer/SpellInfoRect/SpellCostBGRect/CharaSPLabel"

onready var textRect  = $"../TextRect"

onready var castButton : Button = $BottomContainer/CastButton

var picked_character = null
var picked_level = 1
var picked_spell = null
var picked_power : int = 1

onready var plevelbutton1 = $"MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton1"
onready var plevelbutton2 = $"MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton2"
onready var plevelbutton3 = $"MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton3"
onready var plevelbutton4 = $"MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton4"
onready var plevelbutton5 = $"MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton5"
onready var plevelbutton6 = $"MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton6"
onready var plevelbutton7 = $"MiddleContainer/PowerLevelsRect/PowerLevelsContainer/PLevelButton7"
onready var plevelbuttons : Array = [plevelbutton1,plevelbutton2,plevelbutton3,plevelbutton4,plevelbutton5,plevelbutton6,plevelbutton7]

signal spell_picked

# Called when the node enters the scene tree for the first time.
func _ready():
	yield ( UI, "ready")
	connect("spell_picked", UI.ow_hud,"_on_spell_picked" )
	#Error connect(signal: String, target: Object, method: String, binds: Array = [  ], flags: int = 0)

func on_viewport_size_changed(screensize) :
	
	if screensize.y <=600 :
		topcontainer.set_custom_minimum_size(Vector2(320,175))
		topcontainer.set_size(Vector2(320,275))
		set_scale( Vector2(1, screensize.y/600) )
#		topcontainer.set_size(Vector2(320,275))
#		midcontainer.set_size(Vector2(320,275))

	else :
		var h = max(screensize.y-325 , 175)
		set_scale( Vector2.ONE )
		topcontainer.set_custom_minimum_size(Vector2(320,h))
		topcontainer.set_size(Vector2(320,h))
		midcontainer.set_position(Vector2(0,screensize.y-325))
		botcontainer.set_position(Vector2(0,screensize.y-50))
#	_set_size(Vector2(320, h))


func initialize(character) :
	picked_spell = null
	castButton.disabled = true
	print("initialize spell menu for "+character.name)
	picked_character = character
	charnameLabel.text = picked_character.name
	charportrait.texture = picked_character.portrait
#	print("spell menu with ", character.name, "\n spells : ", character.spells)
	var allowed_level : int = character.spells.size()
	for c in spellLevelsRect.get_children() :
		if c.get_index() >0 :
			c.set_button_group(levelgroup)
			c.disabled = (c.get_index() > allowed_level)
	
	for c in spellPowersContainer.get_children() :
		if c.get_index() >0 :
			c.set_button_group(powerbgroup)
	
	_on_SLevelButton_pressed(0)
	_on_PLevelButton_pressed(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CastButton_pressed():
	print("_on_CastButton_pressed")
#	hide()
#	picked_spell = "some spell "+String(randi()%1000)
	emit_signal("spell_picked", picked_character, picked_spell, picked_power )


func _on_AbortButton_pressed():
	hide()
	picked_spell = "abort"
	emit_signal("spell_picked", picked_character, picked_spell, picked_power )
	UI.ow_hud._on_viewport_size_changed()
	UI.ow_hud.emit_signal( "pc_picked", [])

func _on_LeftButton_pressed():
	var pcid : int = GameGlobal.player_characters.find(picked_character)-1
	var teamsize : int = GameGlobal.player_characters.size()
	#find the magic user before picked_character
	var prevchar = GameGlobal.player_characters[(pcid)%teamsize]
	while prevchar.spells.size()==0 :
		pcid = (pcid-1)%teamsize
		prevchar = GameGlobal.player_characters[(pcid)%teamsize]
	if prevchar == picked_character :
		return
	else :
		initialize(prevchar)
	#selected_character.spells.size()>0


func _on_RightButton_pressed():
	var pcid : int = GameGlobal.player_characters.find(picked_character)+1
	var teamsize : int = GameGlobal.player_characters.size()
	#find the magic user before picked_character
	var nextchar = GameGlobal.player_characters[(pcid)%teamsize]
	while nextchar.spells.size()==0 :
		pcid = (pcid+1)%teamsize
		nextchar = GameGlobal.player_characters[(pcid)%teamsize]
	if nextchar == picked_character :
		return
	else :
		initialize(nextchar)


func _on_SLevelButton_pressed(slevel : int):
	picked_spell = null
	display_spell_info()
	picked_level = slevel
	for c in spelllistContainer.get_children() :
		c.queue_free()
		c.free()
	for s in picked_character.spells[slevel] :
		print("adding spell button for "+s["name"])
		var new_button : Button = spellbuttonTSCN.instance()
		new_button.text = s["name"]
		new_button.connect("pressed", self, "_on_spell_selected", [s, new_button])
		spelllistContainer.add_child(new_button)


func _on_PLevelButton_pressed(power : int):
	picked_power = power
	display_spell_info()

func _on_spell_selected(spelldict : Dictionary, button) :
	UI.ow_hud.emit_signal( "pc_picked", [])
	show()
	# this was to avoid changing the spell while picking targets
	# without preventing chosing a new on with
	# ow_hud.selecting_several_characters : bool
	print("selected "+spelldict["name"])
	picked_spell = spelldict["script"]
	print(spelldict.keys())
	for b in spelllistContainer.get_children() :
		if b == button :
			b.set_button_icon(spellButtonIconGreen)
		else :
			b.set_button_icon(spellButtonIconGray)
	display_spell_info()
	
	if picked_spell.get("max_plevel") :
		var maxplevel = min(7,picked_spell.max_plevel)
		for i in range(7) :
			var pbutton = plevelbuttons[i]
			pbutton.set_disabled(i>=maxplevel)
		if picked_power >= maxplevel :
			var pbutton = plevelbuttons[maxplevel-1]
			pbutton.set_pressed(true)
			_on_PLevelButton_pressed(maxplevel-1)
	else :
		for b in plevelbuttons :
			b.set_disabled(false)

func display_spell_info() :
	if picked_spell == null :
		castButton.disabled = true
		# remove all labels text
		dmgminLabel.text = ''
		dmgmaxLabel.text = ''
		durminLabel.text = ''
		durmaxLabel.text = ''
		rngLabel.text = ''
		trgLabel.text = ''
		losLabel.text = ''
		rotLabel.text = ''
		attributesLabel.text = ''
		powerLabel.text = ''
		spcostLabel.text = ''
		charaspLabel.text = ''
		textRect.textLabel.parse_bbcode('')
		return
	print(typeof(picked_spell))
	print(picked_spell)
	castButton.disabled = false
	dmgminLabel.text = String(  picked_spell.get_min_damage(picked_power, picked_character)   )
	dmgmaxLabel.text = String(  picked_spell.get_max_damage(picked_power, picked_character)   )
	durminLabel.text = String(  picked_spell.get_min_duration(picked_power, picked_character)   )
	durmaxLabel.text = String(  picked_spell.get_max_duration(picked_power, picked_character)   )
	rngLabel.text = String(  picked_spell.get_range(picked_power, picked_character)   )
	trgLabel.text = String(  picked_spell.get_target_number(picked_power, picked_character) )
	
	
	
	
	
	if picked_spell.los :
		losLabel.text = "Yes"
	else :
		losLabel.text = "No"
	if picked_spell.rot :
		rotLabel.text = "Yes"
	else :
		rotLabel.text = "No"
	powerLabel.text = String(picked_power)
	attributesLabel.text =  String(  picked_spell.attributes  )
	spcostLabel.text = String(picked_character.get_spell_cost(picked_spell, picked_power))#String(  picked_spell.get_sp_cost(picked_power, picked_character)   )
	charaspLabel.text = String(  picked_character.get_stat("curSP")  )
	textRect.textLabel.parse_bbcode(picked_spell.description)
#	textRect.set_text(picked_spell.description)
#	textRect.disablerButton.hide()
#		textLabel.clear()
