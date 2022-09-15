extends NinePatchRect

onready var vbox : VBoxContainer = $ScrollContainer/VBoxContainer
onready var qtybox : GridContainer = $QtyGridContainer
onready var bgroup: ButtonGroup = ButtonGroup.new()


onready var coinsLabel : Label = $CoinsTextureRect/LabelPatchRect/CoinsLabel
onready var gemsLabel : Label = $GemsTextureRect/LabelPatchRect/GemsLabel
onready var jewelsLabel : Label = $JewelsTextureRect/LabelPatchRect/JewelsLabel

var charmoneypanelTSCN : PackedScene = preload( "res://scenes/UI/HUD/MoneyRect/CharacterMoneyPanel.tscn" )


var selected_character = null
var selected_character_control = null
var quantity : int = 1

#var pool : Array = [0,0,0]

var money_changing_available : bool = false

var goldstogem : float = 0.01
var gemtogolds : int = 90
var gemstojews : float = 0.01
var jewstogems : int = 90

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(characters : Array) :
	set_money_change_enabled(money_changing_available)
	$CoinsTextureRect/LabelPatchRect/CoinsLabel.text = String(GameGlobal.money_pool[0])
	$GemsTextureRect/LabelPatchRect/GemsLabel.text = String(GameGlobal.money_pool[1])
	$JewelsTextureRect/LabelPatchRect/JewelsLabel.text = String(GameGlobal.money_pool[2])
	for child in vbox.get_children() :
		vbox.remove_child(child)
		child.queue_free()
	for c in GameGlobal.player_characters :
		var charmoneypanel = charmoneypanelTSCN.instance()
		charmoneypanel.setup(self, c)
		vbox.add_child(charmoneypanel)
	for b in qtybox.get_children() :
		b.set_button_group(bgroup)

func close() :
#	GameState.set_paused(false)
	get_parent().on_moneyControl_close()
	hide()

func character_button_pressed(cb, chara) :
	selected_character = chara
	selected_character_control = cb
	print("selected_character : ",selected_character,", control : ",selected_character_control)
	for child in vbox.get_children() :
		child.set_selected(child==cb)


func on_viewport_size_changed(screensize) :
	_set_size(Vector2(screensize.x-320, screensize.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_money_change_enabled(yes : bool) :
	money_changing_available = yes
	if yes :
		$"MoneyChangingLabel".set_text("Money Changing is available.")
		$"MoneyChangingLabel".add_color_override("font_color", Color(0,1,0, 1) )
		$GemsTextureRect/ButtonUp.show()
		$JewelsTextureRect/ButtonUp.show()
		$CoinsTextureRect/ButtonDown.show()
		$GemsTextureRect/ButtonDown.show()
	else :
		$"MoneyChangingLabel".set_text("Money Changing is not available.")
		$"MoneyChangingLabel".add_color_override("font_color", Color(1,0,0, 1) )
		$GemsTextureRect/ButtonUp.hide()
		$JewelsTextureRect/ButtonUp.hide()
		$CoinsTextureRect/ButtonDown.hide()
		$GemsTextureRect/ButtonDown.hide()


func _on_DoneButton_pressed():
	close()

func _on_QtyButton_toggled(button_pressed, qty : int):
	quantity = qty

func _on_changeArrow_pressed(from, to) :
	print("_on_changeArrow_pressed ",from,' ',to)
	var q = min(quantity, GameGlobal.money_pool[from])
#	q = int(floor(q/10)*10) #always a multiple of 10
	if from == 0 : #coins :
		# round q to the neartest multiple of 100
		q = 100*floor(q/100)
		GameGlobal.money_pool[0] -= int(q)
		GameGlobal.money_pool[1] += int(q*goldstogem)
		print("converted ",q," coins into ", int(q*goldstogem), " gems")
	elif from == 1 : #gems :
		if to == 0 : #gems to gold
			GameGlobal.money_pool[1] -= int(q)
			GameGlobal.money_pool[0] += int(q*gemtogolds)
			print("converted ",q," gems into ", int(q*gemtogolds), " coins")
		elif to==2 : #gems to jew BANNDED lol
			q = 100*floor(q/100)
			GameGlobal.money_pool[1] -= int(q)
			GameGlobal.money_pool[2] += int(q*gemstojews)
			print("converted ",q," gems into ", int(q*gemstojews), " jews")
	elif from == 2 :
		GameGlobal.money_pool[2] -= int(q)
		GameGlobal.money_pool[1] += int(q*jewstogems)
		print("converted ",q," jews into ", int(q*jewstogems), " gems")
	$CoinsTextureRect/LabelPatchRect/CoinsLabel.text = String(GameGlobal.money_pool[0])
	$GemsTextureRect/LabelPatchRect/GemsLabel.text = String(GameGlobal.money_pool[1])
	$JewelsTextureRect/LabelPatchRect/JewelsLabel.text = String(GameGlobal.money_pool[2])
	
	
func _on_poolArrow_pressed(mult : int, currency : int) :
	print("_on_poolArrow_pressed")
	if selected_character == null :
		return
	var q : int = quantity
	if mult == -1 :
		q = min (quantity, selected_character.money[currency])
		
	else :
		q = min (quantity, GameGlobal.money_pool[currency])
		q = min(q, selected_character.get_stat("Weight_Limit") - selected_character.get_inventory_weight() )
	selected_character.money[currency] += mult*q
	GameGlobal.money_pool[currency] -= mult * q
	selected_character_control.setup(self,selected_character)
	$CoinsTextureRect/LabelPatchRect/CoinsLabel.text = String(GameGlobal.money_pool[0])
	$GemsTextureRect/LabelPatchRect/GemsLabel.text = String(GameGlobal.money_pool[1])
	$JewelsTextureRect/LabelPatchRect/JewelsLabel.text = String(GameGlobal.money_pool[2])
	for charpanel in get_parent().charsVContainer.get_children() :
		if charpanel.character == selected_character :
			charpanel.update_display()

func _on_PoolButton_pressed():
	for currency in range(3) :
		for character in GameGlobal.player_characters :
			GameGlobal.money_pool[currency] += character.money[currency]
			character.money[currency] = 0
	$CoinsTextureRect/LabelPatchRect/CoinsLabel.text = String(GameGlobal.money_pool[0])
	$GemsTextureRect/LabelPatchRect/GemsLabel.text = String(GameGlobal.money_pool[1])
	$JewelsTextureRect/LabelPatchRect/JewelsLabel.text = String(GameGlobal.money_pool[2])
	for charpanel in get_parent().charsVContainer.get_children() :
		charpanel.update_display()
	
	for child in vbox.get_children() :
		child.setup(self, child.character)

func _on_ShareButton_pressed():
#	var can_carry_more : bool = true
	var chara_number : int = GameGlobal.player_characters.size()
	for c in range(3) :
		var currency : int = 2-c
		while GameGlobal.money_pool[currency]>0 :
			var min_weight_left : int = get_min_weight_left()
			if min_weight_left == 0 :
#				can_carry_more = false
				break
			var give_to_each = min(min_weight_left, floor( float(GameGlobal.money_pool[currency]) / float(chara_number) ) )
			if give_to_each > chara_number : #give in bulk
				for character in GameGlobal.player_characters :
					character.money[currency] += give_to_each
				GameGlobal.money_pool[currency] -= give_to_each * chara_number
			else : #give the last munnies one by one
				while GameGlobal.money_pool[currency]>0 :
					for character in GameGlobal.player_characters : 
						var charweightleft = character.get_stat("Weight_Limit") - character.get_inventory_weight()
						if charweightleft>0 :
							character.money[currency] += 1
							GameGlobal.money_pool[currency] -= 1
							min_weight_left = get_min_weight_left()
							if min_weight_left == 0 :
				#				can_carry_more = false
								break
	$CoinsTextureRect/LabelPatchRect/CoinsLabel.text = String(GameGlobal.money_pool[0])
	$GemsTextureRect/LabelPatchRect/GemsLabel.text = String(GameGlobal.money_pool[1])
	$JewelsTextureRect/LabelPatchRect/JewelsLabel.text = String(GameGlobal.money_pool[2])
	for charpanel in get_parent().charsVContainer.get_children() :
		charpanel.update_display()
	
	for child in vbox.get_children() :
		child.setup(self, child.character)
				
func get_min_weight_left() -> int :
			var min_weight_left : int = 9223372036854775807
			for character in GameGlobal.player_characters :
				var weightleft = character.get_stat("Weight_Limit") - character.get_inventory_weight()
				min_weight_left = min(min_weight_left, weightleft)
			return min_weight_left
