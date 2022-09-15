extends Control

var charsmallpanelTSCN : PackedScene = preload("res://scenes/UI/HUD/Characters Panel/CharacterSmallPanel.tscn")

#var characters : Array =  []

var selected_character = null

onready var charsVContainer : VBoxContainer = $CharactersRect/CharScrollContainer/VBoxContainer
onready var timeCntrLabel : Label = $"TimeRect/TimeCntrLabel"
onready var lightcntrLabel : Label = $"TimeRect/LightCntrLabel"
onready var lightpwrLabel : Label  = $TimeRect/LightPCntrLabel
onready var xPosLabel : Label = $TimeRect/XnumberLabel
onready var yPosLabel : Label = $TimeRect/YnumberLabel

onready var inventoryRect = $InventoryRect

onready var canvaslayer : CanvasLayer = $Canvaslayer

onready var charactersrect = $CharactersRect
onready var charscrollcont = $CharactersRect/CharScrollContainer
onready var timerect = $TimeRect
onready var botrightpanel = $BotRightPanel


#onready var inventoryBoxCont = $"InventoryRect/InvScrollContainer/VBoxContainer"

onready var textRect = $TextRect
onready var charSwapRect = $CharSwapRect

onready var treasureControl = $TreasureControl
onready var settingsControl = $SettingsRect
onready var encounterControl = $EncounterControl
onready var moneyControl = $MoneyRect
onready var spellcastButton : Button = $"BotRightPanel/SpellButton"
onready var spellcastMenu = $SpellsRect

onready var restTimer : Timer = $"BotRightPanel/RestButton/RestTimer"
var timebetweenrests : float = 0.05  #in seconds
#var timesincelastrest : float = timebetweenrests

var selecting_several_characters : bool = false
var selecting_several_characters_needed : int = 0
var selecting_several_characters_count : int = 0
var selected_several_characters : Array = []

signal done_picking_pc
signal pc_picked
#signal done_looting

func initialize() : # takes an array of Characters GD class objects !
#	for c in ncharacters :
#		print(c.charname)
	charsVContainer.add_constant_override ("separation",0)
#	inventoryBoxCont.add_constant_override ("separation",0)
#	characters = GameGlobal.player_characters
	fillCharactersRect()
	called_on_CharPanel_SelectButton_pressed(charsVContainer.get_child(0))
	selected_character = GameGlobal.player_characters[0]
	charsVContainer.get_child(0).toggle_SelectButton_Icon(true)
	updateTimeDisplay()
	NodeAccess.__Map().set_ow_character_icon(GameGlobal.player_characters[0].icon)
	set_party_swap_enabled(false)
	settingsControl._initialize()
#	spellcastMenu.connect("spell_picked", self,"_on_spell_picked"
	#Error connect(signal: String, target: Object, method: String, binds: Array = [  ], flags: int = 0)

	
	MusicStreamPlayer.play_music_map()

func _on_viewport_size_changed() :
#	if self.visible :
	var screensize : Vector2 = OS.get_window_size()
	var newscalex = min(1.0, screensize.x/800)
	var newscaley = min(1.0, screensize.y/400)
#	set_scale(Vector2(newscalex,newscaley))
	print(screensize)
#	screensize.x = (1/newscalex)*screensize.x
#	screensize.y = (1/newscaley)*screensize.y
	if screensize.x<800 :
		screensize.x = 800
	if screensize.y<400 :
		screensize.y = 400
	set_scale(Vector2(newscalex, newscaley))
	

	
#	botrightpanel._set_position(Vector2(screensize.x-320, screensize.y-200))
	timerect._set_position(Vector2(screensize.x-320, screensize.y-200-40))
	charactersrect._set_position(Vector2(screensize.x-320,0))
	charactersrect._set_size(Vector2(320, screensize.y-200-40))
#	charsVContainer._set_size(Vector2(320, screensize.y-200-40))
	charscrollcont._set_size(Vector2(320, screensize.y-200-40))
	inventoryRect.on_viewport_size_changed(screensize)
	textRect.on_viewport_size_changed(screensize)
	encounterControl.on_viewport_size_changed(screensize)
	
	botrightpanel._set_position(Vector2(screensize.x-320,screensize.y-200))

	treasureControl.on_viewport_size_changed(screensize)
	charSwapRect.on_viewport_size_changed(screensize)
	settingsControl.on_viewport_size_changed(screensize)
	moneyControl.on_viewport_size_changed(screensize)

	spellcastMenu.on_viewport_size_changed(screensize)

func get_mofified_screensize() :
	var screensize : Vector2 = OS.get_window_size()
	var newscalex = min(1.0, screensize.x/800)
	var newscaley = min(1.0, screensize.y/400)
#	set_scale(Vector2(newscalex,newscaley))
#	print(screensize)
#	screensize.x = (1/newscalex)*screensize.x
#	screensize.y = (1/newscaley)*screensize.y
	if screensize.x<800 :
		screensize.x = 800
	if screensize.y<400 :
		screensize.y = 400
	return screensize

func show() :
	.show()
	for c in canvaslayer.get_children() :
		c.show()

func hide() :
	.hide()
	for c in canvaslayer.get_children() :
		c.hide()

func fillCharactersRect() :
	for child in charsVContainer.get_children() :
		charsVContainer.remove_child(child)
		child.queue_free()
	for c  in GameGlobal.player_characters :
		var charpanel = charsmallpanelTSCN.instance()
		charsVContainer.add_child(charpanel)
#		charpanel._set_global_position(Vector2(0,300*i) )
		charpanel.set_character(c)
		charpanel.update_display()

func set_charactersRect_type(t : int, showdropmenu : bool = true) :
	#type :  0:map 1:loot 2:combat
		for child in charsVContainer.get_children() :
			child.set_type(t,showdropmenu)


func updateTimeDisplay() :
	var time = GameGlobal.time
	var day = time / 86400
	var hour = (time-86400*day) / 3600
	var minute = (time-86400*day-3600*hour) / 60
	var second = (time-86400*day-3600*hour-60*minute) % 60
	timeCntrLabel.text = "Day %02d, %02dh %02dm %02ds" % [day, hour, minute, second]
	var ltime = GameGlobal.light_time
	if ltime >= 86400 :
		lightcntrLabel.text = String(ltime/86400)+' d'
	elif ltime >= 3600 :
		lightcntrLabel.text = String(ltime/3600)+' h'
	elif ltime >= 60 :
		lightcntrLabel.text = String(ltime/60)+' m'
	else :
		lightcntrLabel.text = String(ltime)+' s'
#	lightcntrLabel.text = String(GameGlobal.light_time)+' s'
	lightpwrLabel.text = 'P:'+String(GameGlobal.light_power)
	var mapdisplay = NodeAccess.__Map()
	xPosLabel.text = String(mapdisplay.focuscharacter.tile_position_x)
	yPosLabel.text = String(mapdisplay.focuscharacter.tile_position_y)

func updateCharPanelDisplay() :
	for p in charsVContainer.get_children() :
		p.update_display()

func called_on_CharPanel_SelectButton_pressed(panel) :
	print("called_on_CharPanel_SelectButton_pressed. Selecting several?", selecting_several_characters, ', ',panel.character.name)
	if selecting_several_characters :
		if panel.select_several_counter_label.text != '' :
			#remove that character from selection
#			print("should remove this char frm array")
			selected_several_characters.erase(panel.character)
			panel.set_targeted_number(0)
			selecting_several_characters_count += 1
			GameState.set_cursor_number(selecting_several_characters_count)
			# reset the number display on the other selected characters
			for cp in charsVContainer.get_children() :
				var cindex = selected_several_characters.find(cp.character)
				if cindex >= 0 :
					cp.set_targeted_number(selecting_several_characters_needed-cindex)
		else :
			# add that character to selection
			selected_several_characters.append( panel.character )
			panel.set_targeted_number(selecting_several_characters_count)
			selecting_several_characters_count -= 1
			GameState.set_cursor_number(selecting_several_characters_count)
			if selecting_several_characters_count == 0 :
				selecting_several_characters = false
				# emit a signal for the yield in the script
				print("selected characters : ", selected_several_characters)
				emit_signal("done_picking_pc")
				# remove the selcted graphics/label
				for cp in charsVContainer.get_children() :
					cp.set_targeted_number(0)
#				# reset the array
#				selected_several_characters = []
				return
	# just selecting...
	else :
		for p in charsVContainer.get_children() :
			if p==panel :
				p.toggle_SelectButton_Icon(true)
			else :
				p.toggle_SelectButton_Icon(false)
		selected_character = panel.character
		spellcastButton.disabled = (selected_character.spells.size()==0)
		inventoryRect.reset_trade_panel()
		if inventoryRect.visible :
			inventoryRect.when_Items_Button_pressed()
			if inventoryRect.shopRect.visible :
				inventoryRect.shopRect._on_character_selected(panel.character)

func request_pc_pick(n : int) :
	GameState.set_paused(true)
	n = int( min(n, GameGlobal.player_characters.size()) )
	GameState.set_cursor_number(n)
	selecting_several_characters = true
	selecting_several_characters_needed = n
	selecting_several_characters_count = n
	selected_several_characters = []
	yield(self, "done_picking_pc")
	emit_signal( "pc_picked", selected_several_characters)
	GameState.set_paused(false)
	Input.set_custom_mouse_cursor(GameState.cursor_sword)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	var i : int = 0

#		print(c.charname)
#		i +=1
#	print(characters[0].charname)



func _on_InventoryButton_pressed():

#	print("inventory : ", selected_character.name)
	if inventoryRect.visible :
		inventoryRect.shopRect._on_LeaveShopButton_pressed()
		inventoryRect.hide()
		set_charactersRect_type(0)
		#type :  0:map 1:loot 2:combat
		NodeAccess.__Map().show()
		MusicStreamPlayer.play_music_map()
		GameState.set_paused(false)
		return
	if GameState.paused :
		return
	if not inventoryRect.visible :
		NodeAccess.__Map().hide()
#		set_charactersRect_type(1, false) done in trade mode
		inventoryRect.when_Items_Button_pressed()
		MusicStreamPlayer.play_music_type("Items")
		GameState.set_paused(true)
		return

func set_party_swap_enabled(enabled : bool) :
	$"BotRightPanel/CharSwapButton".disabled = not enabled

func _on_CharSwapButton_pressed():
	print('_on_CharSwapButton_pressed')
	if charSwapRect.visible :
		charSwapRect.hide()
		GameState.set_paused(false)
		MusicStreamPlayer.play_music_map()
		return
	if GameState.paused :
		return
#	print("inventory : ", selected_character.name)
#	if inventoryRect.visible :
#		inventoryRect.hide()
#		NodeAccess.__Map().show()
	if not charSwapRect.visible :
		GameState.set_paused(true)
		charSwapRect.show()
		MusicStreamPlayer.play_music_type("Create")
#	else :
#		GameState.set_paused(false)


func show_loot_menu(items:Array, money : int, experience : int) :
#	if GameState.paused :
#		return
##	if inventoryRect.visible :
##		inventoryRect.hide()
##		NodeAccess.__Map().show()
#	else :
	NodeAccess.__Map().hide()
	set_charactersRect_type(1) #loot style !
	
	
	GameState.set_paused(true)
	treasureControl.display(items, money, experience)
	MusicStreamPlayer.play_music_type("Treasure")
	yield(treasureControl, "done_looting")
	MusicStreamPlayer.play_music_map()
	GameState.set_paused(false)


func _on_SettingsButton_pressed():
	if GameState.paused :
		return
	GameState.set_paused(true)
	settingsControl.show()
	MusicStreamPlayer.play_music_type("Create")



func _on_EncounterButton_pressed():
	if not encounterControl.visible :
		if not GameState.paused :
			encounterControl.show()
		#	encounterControl.disablerButton.show()
		#	textRect.disablerButton.show()
			encounterControl.initialize(GameGlobal.currentSpecialEncounterName)
	else :
		if encounterControl.stopButton.visible :
			encounterControl.close()


func _on_CampButton_pressed():
	if GameState.paused :
		return
	GameGlobal.camping = ! GameGlobal.camping
	if GameGlobal.camping :
		MusicStreamPlayer.play_music_type("Camp")
	else :
		MusicStreamPlayer.play_music_map()
	NodeAccess.__Map().set_ow_character_icon(GameGlobal.player_characters[0].icon)



func _on_RestTimer_timeout():
	GameGlobal.rest()
	restTimer.start(timebetweenrests)

func _on_RestButton_button_down():
	if GameState.paused :
		return
	restTimer.set_paused(false)
	restTimer.start(0.00001)

func _on_RestButton_button_up():
	restTimer.set_paused(true)


func _on_MoneyButton_pressed():
	pass # Replace with function body.moneyControl
	if not moneyControl.visible :
		if (not GameState.paused) or (treasureControl.visible or inventoryRect.visible) :
			GameState.set_paused(true)
			moneyControl.show()
		#	encounterControl.disablerButton.show()
		#	textRect.disablerButton.show()
			moneyControl.initialize(GameGlobal.player_characters)
	else :
			moneyControl.close()
			

func on_moneyControl_close() :
	if not (treasureControl.visible or inventoryRect.visible) :
		GameState.set_paused(false)

func set_money_change_enabled(yes : bool) :
	moneyControl.set_money_change_enabled(yes)


func _on_SpellButton_pressed():
	if selected_character == null :
		return
	GameState.set_paused(true)
	spellcastMenu.initialize(selected_character)
	spellcastMenu.show()
#	yield(spellcastMenu, "spell_picked")

func _on_spell_picked(character, spell, powerlevel) :
	if typeof(spell) == TYPE_STRING :
		return
	print("_on_spell_picked : ",character.name," ", spell)
	var spelldata :  Dictionary = character.get_spell_data(spell, powerlevel)
	var target_number : int = spelldata["tg_number"]#spell.get_target_number(powerlevel)
	print("target_number : ", target_number)
	if not GameGlobal.in_combat :
		if target_number > 0 :
			print("pick targets among party members")
			var screensize : Vector2 = OS.get_window_size()
			charactersrect._set_position(Vector2(screensize.x-320-60,0) )
			var charrectheight = charactersrect.get_size().y
			charactersrect._set_size(Vector2(60,charrectheight+40))
			request_pc_pick(target_number)
			var picked_targets = yield(self, "pc_picked")
			for target in picked_targets :
				print ("cast "+spell.name+" on "+target.name)
				SfxPlayer.stream = NodeAccess.__Resources().sounds_book[spell.sounds[1]]
				SfxPlayer.play()
				show_spell_effect_on_char_menu( target, spell.graphics[1] )
				#actual effect :
				character.stats["curSP"] -= spelldata["sp_cost"]
#				var attack = character._on_spell_cast(spell, powerlevel)
#				GameGlobal.generate_attack(character, spell, powerlevel)
#				GameGlobal.resolve_action(attack, target)
				updateCharPanelDisplay()
			charactersrect._set_position(Vector2(screensize.x-320,0) )
			charactersrect._set_size(Vector2(320,charrectheight))
	spellcastMenu.hide()
	textRect.textLabel.parse_bbcode('')
	GameState.set_paused(false)

func show_spell_effect_on_char_menu(chara, effect_texture_frame : int) :
	for p in charsVContainer.get_children() :
		if p.character == chara :
			p.show_spell_effect(effect_texture_frame)
