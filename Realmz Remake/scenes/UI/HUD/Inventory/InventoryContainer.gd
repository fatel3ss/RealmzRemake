extends ScrollContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#does this display the inventory of the character selected in the main hud ?
export var is_hud_selected : bool = false

onready var mybox = self.get_child(0)
var inventoryrect = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func can_drop_data(_pos, data):
	# good enough to prove it's an item !
	if (typeof(data[0]) == TYPE_DICTIONARY and data[0].has("imgdata") ) :
		var mycharacter = get_inventory_owner()
		var characteritemcamefrom = data[1]
		if typeof(characteritemcamefrom) != TYPE_STRING :
			if mycharacter == characteritemcamefrom :
				return true
			else :
				return data[0]["tradeable"]==1
		else :
			if characteritemcamefrom == "Shop" :
				return mycharacter.can_add_inventory_item(data[0]) # check for money first

func drop_data(_pos, data):
	var item = data[0]
	var characteritemcamefrom = data[1]
	var mycharacter = get_inventory_owner()
	
	if typeof(characteritemcamefrom) != TYPE_STRING :
		if characteritemcamefrom == mycharacter :
			return
		else :
			
			if mycharacter.can_add_inventory_item(item) :
				#if selchar.drop_inventory_item(item) :
				characteritemcamefrom.inventory.erase(item)
				mycharacter.add_inventory_item(item)
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
				mycharacter.add_inventory_item(item)
				#deduct money
				var price = int(item["price"]*shop["sell_rate"])
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

#		characteritemcamefrom.inventory.erase(item)
#		mycharacter.inventory.append(item)
		inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxLeft, inventoryrect.inventoryBoxLeft.get_parent().get_inventory_owner())
		inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxRight, inventoryrect.inventoryBoxRight.get_parent().get_inventory_owner())
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_inventory_owner() :
	if is_hud_selected :
		return inventoryrect.hud.selected_character
	else :
		return inventoryrect.selectedTradeCharacter
