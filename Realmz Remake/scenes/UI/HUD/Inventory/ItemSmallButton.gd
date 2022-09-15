extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var colorRect : ColorRect = $colorRect
onready var iconsprite : Sprite = $"IconSprite"
onready var iconequipped : Sprite = $"IconEquipped"
onready var namelabel : Label= $"ItemnameLabel"
onready var infolabel : Label = $"IteminfoLabel"
#onready var inventoryrect : Control = get_parent().get_parent().inventoryrect
onready var chargesLabel : Label = $ChargesLabel
onready var statsLabel : Label = $ItemstatsLabel
onready var selectedSprite : Sprite = $SpriteSelected

#onready var buttonJoin : Button = $JoinButton
#onready var buttonSplit : Button = $SplitButton
#onready var textfield : TextEdit = $TextEdit

var item = null
var inventoryrect : Control = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	on_viewport_size_changed (OS.get_window_size())
#	var screensize : Vector2 = OS.get_window_size()
#	_set_size(Vector2(floor((screensize.x-320-44-20)/2), 40))
	pass # Replace with function body.


func on_viewport_size_changed(screensize):
	#needed to set size expand flags on this AND the parent vcontainer
#	print("itembutton on_viewport_size_changed ", namelabel.text, floor((screensize.x-320-44-20)/2))
	chargesLabel._set_position( Vector2(floor((screensize.x-320-44-20)/2) - 85 -10, 4) )
	statsLabel._set_position( Vector2(floor((screensize.x-320-44-20)/2) - 205 -10, 20) )
	colorRect._set_size(Vector2(floor((screensize.x-320-44-20)/2), 40))
#	_set_size(Vector2(floor((screensize.x-320-44-20)/2), 40))

#	SfxPlayer.stream = NodeAccess.__Resources().sounds_book["slurpy.ogg"]
#	SfxPlayer.play()


func set_item(nitem : Dictionary) -> void :
#	print("item : ",item)
	var screensize : Vector2 = OS.get_window_size()
	colorRect._set_size(Vector2(floor((screensize.x-320-44-20)/2), 40))
	_set_size(Vector2(floor((screensize.x-320-44-20)/2), 40))
	iconsprite.set_texture( nitem["texture"] )
	namelabel.text = nitem["name"]
	infolabel.text = nitem["type"]
	if nitem["equipped"] == 0 :
		iconequipped.hide()
	else :
		iconequipped.show()
	if nitem["charges_max"] == 0 :
		chargesLabel.hide()
	else :
		chargesLabel.show()
		chargesLabel.text = 'X '+String(nitem["charges"]) + ' / '+ String(nitem["charges_max"])
#		var screensize : Vector2 = OS.get_window_size()
		chargesLabel._set_position( Vector2(floor((screensize.x-320-44-20)/2) - 85 -10, 4) )
	if nitem.has("stats_mini") :
		statsLabel.text = nitem["stats_mini"]
#		var screensize : Vector2 = OS.get_window_size()
		statsLabel._set_position( Vector2(floor((screensize.x-320-44-20)/2) - 205 -10, 20) )
	else :
		statsLabel.text = ''
	item = nitem
#
#	if nitem["splittable"]==0:
#		remove_child(buttonJoin)
#		remove_child(buttonSplit)
#		remove_child()
#		queue_free()

func update_display() -> void :
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_drag_data(_pos):
	if inventoryrect==null :
		return
	if item["equipped"]==1 :
		return null
	# Use another colorpicker as drag preview
	var dragpreview = TextureRect.new()
	dragpreview.set_texture(item["texture"])
#	cpb.rect_size = Vector2(50, 50)
	set_drag_preview(dragpreview)
	# Return item and its owner character as data
	return [item, self.get_parent().get_parent().get_inventory_owner() ]  #parent is the vbox it came from

#
#func _on_ItemSmallButton_pressed():
#	print(item["name"], " was clicked !")




# to allow reordering items :
func can_drop_data(_pos, data):
	# good enough to prove it's an item !
	if not data[0].has("imgdata") :
		print("itemsmallbutton candropdata : item has no imgdata !")
		return false
	if (typeof(data[0]) == TYPE_DICTIONARY and data[0].has("imgdata") ) :
		var mycharacter = get_parent().get_parent().get_inventory_owner()
		var characteritemcamefrom = data[1]
		if typeof(characteritemcamefrom) != TYPE_STRING :
			if mycharacter == characteritemcamefrom :
				return true
			else :
				return data[0]["tradeable"]==1
		else : 
			if characteritemcamefrom == "Shop" :
#				var itemprice = int( data[0]["price"] * GameGlobal.get_shop(GameGlobal.currentShop)["sell_rate"] )
#				var canafford = null
				return mycharacter.can_add_inventory_item(data[0]) # check for money first
	return false

func drop_data(_pos, data):
	if inventoryrect==null :
		return
#	print("itemsmallbutton dropdata")
	var otheritem = data[0]
	var characteritemcamefrom = data[1]
	var mycharacter = get_parent().get_parent().get_inventory_owner()
	
	var myIndexInCharInv = mycharacter.inventory.find(item)
	
	if typeof(characteritemcamefrom) != TYPE_STRING :
		print(" in itemsmallbutton :  mycharacter.can_add_inventory_item(otheritem)",  mycharacter.can_add_inventory_item(otheritem))
		if mycharacter.can_add_inventory_item(otheritem) :
			#if selchar.drop_inventory_item(item) :
			characteritemcamefrom.inventory.erase(otheritem)
			mycharacter.add_inventory_item(otheritem, myIndexInCharInv)
		else :
			SfxPlayer.stream = NodeAccess.__Resources().sounds_book['generation error.ogg']
			SfxPlayer.play()
	
	else :
		if characteritemcamefrom == "Shop" :
			print ("char money : ", mycharacter.money[0], ", pool : ", GameGlobal.money_pool[0])
			if mycharacter.can_add_inventory_item(item) :
				#if selchar.drop_inventory_item(item) :
				var shop = GameGlobal.get_shop(GameGlobal.currentShop)
#				characteritemcamefrom.inventory.erase(item)
				
				inventoryrect.shopRect.remove_one_from_stock(item )
				mycharacter.add_inventory_item(otheritem, myIndexInCharInv)
				#deduct money
				var price = int(otheritem["price"]*shop["sell_rate"])
				print("price : ", price)
				var  removed = min(price, mycharacter.money[0])
				mycharacter.money[0]-=removed
				price -= removed
				GameGlobal.money_pool[0]-=price
				print ("char money : ", mycharacter.money[0], ", pool : ", GameGlobal.money_pool[0])
				inventoryrect.shopRect.goldLabel.text = String(mycharacter.money[0])
				inventoryrect.shopRect.poolLabel.text = String( GameGlobal.money_pool[0] )
				inventoryrect.shopRect.fillVbox(inventoryrect.shopRect.current_shop_category)
			else :
				SfxPlayer.stream = NodeAccess.__Resources().sounds_book['generation error.ogg']
				SfxPlayer.play()
#	characteritemcamefrom.inventory.erase(otheritem)
#	print(mycharacter.name," ", item["name"],' ',myIndexInCharInv)
#	mycharacter.inventory.insert(myIndexInCharInv,otheritem)
	
	
	inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxLeft, inventoryrect.inventoryBoxLeft.get_parent().get_inventory_owner())
	inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxRight, inventoryrect.inventoryBoxRight.get_parent().get_inventory_owner())
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass







func _on_ItemSmallButton_gui_input(event):
	if inventoryrect==null :
		return
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				inventoryrect.set_selected_item_ctrl(self)
#				print("# left button clicked")# left button clicked
#				if get_parent() == inventoryrect.inventoryBoxRight :
#					inventoryrect.set_selected_item_ctrl(self)
#				else :
#					inventoryrect.set_selected_item_ctrl(null)
				
			BUTTON_RIGHT:
				print("# right button clicked")
				if item["equippable"] == 1 :
					equip_item()
				if item.has("_on_field_use") :
					use_item()

func equip_item() :
	var itemowner = self.get_parent().get_parent().get_inventory_owner()
	print("owner is : ", itemowner)
	
	if item["equippable"] == 1 :
		if item["equipped"] == 0 :
			var couldequip : bool = itemowner.equip_item(item)
			if couldequip :
				SfxPlayer.stream = NodeAccess.__Resources().sounds_book[item["sound"]]
				SfxPlayer.play()
			else :
				SfxPlayer.stream = NodeAccess.__Resources().sounds_book["target error.ogg"]
				SfxPlayer.play()
			set_item(item)
			return
		if item["equipped"] == 1 :
			itemowner.unequip_item(item)
			SfxPlayer.stream = NodeAccess.__Resources().sounds_book[item["sound"]]
			SfxPlayer.play()
			set_item(item)
			return

func use_item() :
	# it's a PlayerCharacter.gd
	var itemowner = self.get_parent().get_parent().get_inventory_owner()
	print("owner is : ", itemowner)
	
	if item.has("_on_field_use") :
		print("ITEM RIGHT CLICKED HAS A _on_field_use")
		item["_on_field_use"]._on_field_use(itemowner, item)
		if item.has("delete_on_empty") and (item["delete_on_empty"] == 1) :
			if item.has("charges") and item["charges"]<=0 :
				var dropped = itemowner.drop_inventory_item(item)
				if dropped :
					pass
#					SfxPlayer.stream = NodeAccess.__Resources().sounds_book["drop item.ogg"]
#					SfxPlayer.play()
		GameGlobal.refresh_OW_HUD()
		set_item(item)
#		GameGlobal.refresh_OW_HUD()
	else :
		equip_item()

func _on_ItemSmallButton_mouse_entered():
	if inventoryrect==null :
		return
	inventoryrect.display_item_info(item)
	colorRect.color = Color(0.9, 0.9, 0.9, 1)
#	print("free hands : ",self.get_parent().get_parent().get_inventory_owner().free_hands)
#	var weight_string : String = "Weight : "
	var weight : int = item["weight"]+item["charges_weight"]*item["charges"]
	infolabel.set_text("Weight : "+String(weight) + " Price : "+String(item["price"]))
	infolabel.add_color_override("font_color", Color(0,0,0, 1) )

func _on_ItemSmallButton_mouse_exited():
	colorRect.color = Color(1,1,1, 1)
	infolabel.text = item["type"]
	infolabel.add_color_override("font_color", Color(1,0,0, 1) )

#func _on_JoinButton_pressed():
#	pass # Replace with function body.
#
#
#func _on_SplitButton_pressed():
#	pass # Replace with function body.
