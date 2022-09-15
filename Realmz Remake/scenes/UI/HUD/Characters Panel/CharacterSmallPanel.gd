extends Panel

export var dropItemEntryTSCN : PackedScene
onready var inventoryrect = get_parent().get_parent().get_parent().get_parent().inventoryRect

var character = null#: GDScript = null
var type : int = 0  #type :  0:map 1:loot 2:combat

onready var nameLabel : Label = $CharnameLabel
onready var faceButton : Button = $PortraitButton
onready var curHPLabel : Label= $"HPLabel/CurHPLabel"
onready var maxHPLabel : Label= $"HPLabel/MaxHPLabel"
onready var curSPLabel : Label= $"SPLabel/CurSPLabel"
onready var maxSPLabel : Label= $"SPLabel/MaxSPLabel"

onready var selectButton : Button = $"SelectButton"
onready var selectedOffIcon : Texture = load("res://scenes/UI/HUD/Characters Panel/CharPanelSelectOff.png")
onready var selectedOnIcon : Texture = load("res://scenes/UI/HUD/Characters Panel/CharPanelSelectOn.png")
onready var select_several_counter_label : Label = $PortraitButton/NumberLabel

onready var hpLabel = $HPLabel
onready var spLabel = $SPLabel
onready var lootRect = $lootRect
onready var dropbutton=$lootRect/DropItemButton/
onready var dropPopup : PopupPanel = $lootRect/DropItemButton/DropPopup
#onready var dropRect = $lootRect/DropItemButton/DropRect
onready var dropVBox : VBoxContainer = $lootRect/DropItemButton/DropPopup/DropScroll/DropVBox
onready var dropScroll : ScrollContainer = $lootRect/DropItemButton/DropPopup/DropScroll
#onready var dropPopup =$lootRect/DropItemButton/PopupMenu
#onready var dropPupupMenu = $lootRect/DropItemButton/PopupMenu
onready var itemsnumberLabel : Label = $lootRect/lootRect2/ItemsNLabel
onready var curWeightLabel : Label = $"lootRect/LoadCNLabel"
onready var maxWeightLabel : Label = $"lootRect/LoadMNLabel"

onready var effect_sprite : Sprite = $"PortraitButton/EffectSprite"
var effect_sprite_frame_counter : int = 0
onready var effect_sprite_timer : Timer = $"PortraitButton/EffectSprite/Timer"

func _ready():
	pass

func set_character(chara) -> void :
#	print("charname : ", chara.charname)
	character = chara
	nameLabel.text = chara.name
	faceButton.icon = chara.portrait 

func set_type(t : int, showdropmenu : bool = true) :
	#type :  0:map 1:loot 2:combat
	if type != t :
		type = t
		if t==0 :
			hpLabel.show()
			spLabel.show()
		else :
			hpLabel.hide()
			spLabel.hide()
			if showdropmenu :
				dropbutton.show()
			else :
				dropbutton.hide()
		if t==1 :
			lootRect.show()
			itemsnumberLabel.text = String(character.inventory.size())
			curWeightLabel.text = String(character.get_inventory_weight())
			maxWeightLabel.text = String(character.get_stat("Weight_Limit"))
		else :
			lootRect.hide()
#		update_display()

func update_display() ->void :
	#type :  0:map 1:loot 2:combat
	nameLabel.text = character.name
	faceButton.icon = character.portrait 
	curHPLabel.text = String(character.stats["curHP"])
	maxHPLabel.text = String(character.stats["maxHP"])
	curSPLabel.text = String(character.stats["curSP"])
	maxSPLabel.text = String(character.stats["maxSP"])
	
	itemsnumberLabel.text = String(character.inventory.size())
	curWeightLabel.text = String(character.get_inventory_weight())
	maxWeightLabel.text = String(character.get_stat("Weight_Limit"))

func _on_SelectButton_pressed():
	UI.ow_hud.called_on_CharPanel_SelectButton_pressed(self)

func toggle_SelectButton_Icon(s : bool) :
	if s :
		selectButton.set_button_icon(selectedOnIcon)
	else :
		selectButton.set_button_icon(selectedOffIcon)
		


func set_targeted_number(n : int) :
	select_several_counter_label.set_text(String(n))
	if n == 0 :
		select_several_counter_label.set_text('')

func can_drop_data(_pos, data):
	# good enough to prove it's an item !
	return ( data[1]!=character and ( typeof(data[0]) == TYPE_DICTIONARY and data[0].has("imgdata") ))

func drop_data(_pos, data):
	var item = data[0]
	var characteritemcamefrom = data[1]
	if characteritemcamefrom == character :
		return
	else :
		print(" smallpanels character is ", character.name)
#		print(inventoryrect.inventoryBoxLeft.get_parent().get_inventory_owner())  #was nil
#		print(inventoryrect.inventoryBoxRight.get_parent().get_inventory_owner()) #  was not nil
		characteritemcamefrom.inventory.erase(item)
		character.inventory.append(item)
		inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxLeft, inventoryrect.inventoryBoxLeft.get_parent().get_inventory_owner())
		inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxRight, inventoryrect.inventoryBoxRight.get_parent().get_inventory_owner())




func _on_DropItemButton_pressed():
	print("_on_DropItemButton_pressed")
	for child in dropVBox.get_children() :
		dropVBox.remove_child(child)
		child.queue_free()
	var char_inventory = character.inventory
	var prev_ib = null
	var n = 0
	for i in char_inventory :
		var ibutton = dropItemEntryTSCN.instance()
#		ibutton.set_text_align(Button.ALIGN_LEFT)
#		ibutton.set_flat(true)
		var text : String = i["name"]
		if i.has("charges_max") :
			if i["charges_max"]>0 :
				text = text + ' X' + String(i["charges"])
		ibutton.text = text
		if i["equipped"]==1 :
			ibutton.set_disabled(true)
		if prev_ib!=null :
			ibutton.set_focus_neighbour(MARGIN_TOP,prev_ib.get_path())
			prev_ib.set_focus_neighbour(MARGIN_BOTTOM,ibutton.get_path())
		#connect(signal: String, target: Object, method: String, binds: Array = [  ], flags: int = 0)
		ibutton.connect("pressed",self, "_on_dropentry_pressed", [i] )
#		ibutton.connect("focus_entered",self, "_on_dropentry_focused", [ibutton.get_position().y,n])
#		ibutton.connect("gui_input",self, "_on_dropentry_gui_input")
		dropVBox.add_child(ibutton)
		prev_ib = ibutton
		n +=1
#	dropRect.show()
	# calculate availlable height for the popup
	var globalpos = get_global_position()
	var screeny = UI.ow_hud.get_mofified_screensize().y
	var ysize = screeny-globalpos.y-60
	var itemysize = 20+14*n
	ysize = min(ysize, itemysize)
#	ysize = max(ysize, 200)
	dropPopup.popup(Rect2(globalpos+Vector2(60,50), Vector2(150,ysize)))

	#focus_neighbour_top(value)
	#focus_neighbour_bottom(value)
	#set_focus_neighbour
	

func _on_dropentry_pressed(i : Dictionary) :
#	print("_on_dropentry_pressed")
	character.drop_inventory_item(i)
	update_display()
	dropPopup.hide()

func show_spell_effect(effect_texture_frame) :
	effect_sprite.show()
	effect_sprite_frame_counter = 0
	effect_sprite.frame = effect_texture_frame
	effect_sprite_timer.start(0.1)


func _on_EffectSprite_Timer_timeout():
	effect_sprite_frame_counter+=1
	if effect_sprite_frame_counter <7 :
		effect_sprite_frame_counter = 0
		effect_sprite_timer.stop()
		effect_sprite.hide()
	else :
		effect_sprite_timer.start(0.1)
	effect_sprite.frame+=1
	pass # Replace with function body.
#func _on_dropentry_focused(pos, n ) :
#	print(pos,n)

#func _on_dropentry_gui_input(event : InputEvent):
##	print("_on_dropentry_gui_input")
#	print(event)
#	if event is InputEventKey and not event.echo:
##		print("inouteventkeey")
#		#if and ev.scancode == KEY_K
#		if InputMap.event_is_action ( event, "ui_up" ) :
#			dropScroll.set_v_scroll(dropScroll.get_v_scroll()-7)
#		if InputMap.event_is_action ( event, "ui_down" ) :
#			dropScroll.set_v_scroll(dropScroll.get_v_scroll()+7)
#		#event_is_action ( InputEvent event, String action ) const
	



