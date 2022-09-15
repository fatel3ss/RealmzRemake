extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var itemLootButton : PackedScene

onready var itemsRect = $itemsRect
onready var botrightpanel = $BotRightLootInfo
onready var itemsContainer : GridContainer = $itemsRect/ScrollContainer/ItemContainer

onready var itemTextureRect : TextureRect = $BotRightLootInfo/ItemInfoRect/ItemTextureRect
onready var itemNameLabel : Label = $BotRightLootInfo/ItemInfoRect/ItemNameLabel
onready var itemStatsLabel : Label = $BotRightLootInfo/ItemInfoRect/ItemStatsLabel
onready var itemsWeightLabel : Label = $BotRightLootInfo/ItemInfoRect/ItemWeightLabel

onready var moneyLabel : Label = $BotRightLootInfo/ItemInfoRect/MoneynLabel

signal done_looting

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func on_viewport_size_changed(screensize : Vector2) :
	itemsRect._set_size(Vector2(screensize.x-320, screensize.y))
	botrightpanel._set_position(Vector2(screensize.x-320,screensize.y-200))
	#set itemcontainer max columns
	var width = screensize.x-320
	var columns = floor(width/50)
	itemsContainer.set_columns(columns)  # 9 if width<480


# take inspiration from textrect script
func display(items : Array, money : int, experience : int) :
	update_money_label()
	#fill the gridcontainer
	for i in items :
		var newButton = itemLootButton.instance()
		var newtex : Texture = i["texture"]
		newButton.find_node("ItemTextureRect").set_texture( newtex )
		newButton.connect("pressed",self,"_on_itemlootbutton_pressed",[i, newButton])
		newButton.connect("mouse_entered",self,"_on_itemlootbutton_mouse_entered",[i,newButton])
		newButton.connect("mouse_exited",self,"_on_itemlootbutton_mouse_exited")
		
		#ibutton.connect("pressed",self, "_on_dropentry_pressed", [i] )
		itemsContainer.add_child(newButton)
	show()

func _on_itemlootbutton_mouse_entered(item : Dictionary, button : Button) :
	if button.disabled :
		_on_itemlootbutton_mouse_exited()
		return
	itemTextureRect.show()
	itemNameLabel.show()
	itemStatsLabel.show()
	itemsWeightLabel.show()
	
	itemTextureRect.set_texture(item["texture"])
	var iname = item["name"]
	if item.has("charges_max") :
		if item["charges_max"]>0 :
			iname = iname + ' X' + String(item["charges"])
	itemNameLabel.text = iname+" ("+item["type"]+")"
	itemStatsLabel.text = item["stats_mini"]
	itemsWeightLabel.text = "Weight : " +String(item["weight"]+item["charges_weight"]*item["charges"])

func _on_itemlootbutton_mouse_exited() :
	itemTextureRect.hide()
	itemNameLabel.hide()
	itemStatsLabel.hide()
	itemsWeightLabel.hide()


func _on_itemlootbutton_pressed(item:Dictionary, button : Button) :
	var looter = GameGlobal.gamescreenInstance.selected_character
#	print(looter.name," picks up ", item["name"])
#	return
	var looted : bool = looter.add_inventory_item(item)
	if looted :
		# to keep an empty spot
		button.set_disabled(true)
		button.release_focus()
#		button.disconnect("pressed",self,"_on_itemlootbutton_pressed")
		for child in button.get_children() :
#			button.remove_child(child)
			child.queue_free()
		GameGlobal.gamescreenInstance.updateCharPanelDisplay()

func close() :
	#empty the gridcontainer
	for child in itemsContainer.get_children() :
		itemsContainer.remove_child(child)
		child.queue_free()
	get_parent().set_charactersRect_type(0)
	get_parent().moneyControl.close()
	NodeAccess.__Map().show()
	emit_signal( "done_looting")
	hide()


func _on_ButtonDone_pressed():
	close()

func update_money_label() :
	var moneytext : String = ''
	for c in GameGlobal.money_pool :
		moneytext += String(c)+'\n'
	moneyLabel.set_text(moneytext)

func _on_PoolButton_pressed():
	get_parent().moneyControl._on_PoolButton_pressed()
	update_money_label()


func _on_ShareButton_pressed():
	get_parent().moneyControl._on_ShareButton_pressed()
	update_money_label()
