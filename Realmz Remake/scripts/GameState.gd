extends Node

""" 
	The game state module representing a finite state machine to control the 
	game.
	# the game states must be reshaped according to the game. See GameGlobal.gd #
"""

var _state = GameGlobal.eGameStates.off
var _gameStateFileConfigs

var paused : bool = false

var map
var tiles_book : Dictionary = {}  #point to Resources
var sounds_book : Dictionary = {}
var last_dir_input : Vector2 = Vector2.ZERO
var time_since_last_dir_input : float = 0


var cursor_sword = load("res://shared_assets/cursors/sword.png")
var cursor_N = load("res://shared_assets/cursors/north.png")
var cursor_NE = load("res://shared_assets/cursors/northeast.png")
var cursor_E = load("res://shared_assets/cursors/east.png")
var cursor_SE = load("res://shared_assets/cursors/southeast.png")
var cursor_S = load("res://shared_assets/cursors/south.png")
var cursor_SW = load("res://shared_assets/cursors/southwest.png")
var cursor_W = load("res://shared_assets/cursors/west.png")
var cursor_NW = load("res://shared_assets/cursors/northwest.png")
var cursor_stop = load("res://shared_assets/cursors/stop.png")
var cursor_map_dict : Dictionary = {Vector2(0,1) : cursor_S, Vector2(1,1) : cursor_SE,
									Vector2(1,0) : cursor_E, Vector2(1,-1) : cursor_NE,
									Vector2(0,-1) : cursor_N, Vector2(-1,-1) : cursor_NW,
									Vector2(-1,0) : cursor_W, Vector2(-1,1) : cursor_SW,
									Vector2.ZERO : cursor_stop}
var cursor_click = load("res://shared_assets/cursors/click.png")
var cursor_0 = load("res://shared_assets/cursors/number_0.png")
var cursor_1 = load("res://shared_assets/cursors/number_1.png")
var cursor_2 = load("res://shared_assets/cursors/number_2.png")
var cursor_3 = load("res://shared_assets/cursors/number_3.png")
var cursor_4 = load("res://shared_assets/cursors/number_4.png")
var cursor_5 = load("res://shared_assets/cursors/number_5.png")
var cursor_6 = load("res://shared_assets/cursors/number_6.png")
var cursor_7 = load("res://shared_assets/cursors/number_7.png")
var cursor_8p = load("res://shared_assets/cursors/number_8p.png")
var cursor_numbers = [cursor_0,cursor_1,cursor_2,cursor_3,cursor_4,cursor_5,cursor_6,cursor_7,cursor_8p]


func _ready():
	map = NodeAccess.__Map()
	tiles_book = NodeAccess.__Resources().get_tiles_book()
	sounds_book = NodeAccess.__Resources().get_sounds_book()

# here will occur the game logic #
func update(delta : float):
	if paused :
		return
	if _state == GameGlobal.eGameStates.startGame :
		doStartGame()
		setState(GameGlobal.eGameStates.inGame)
	elif _state == GameGlobal.eGameStates.saveGame :
		doSaveGame()
		setState(GameGlobal.eGameStates.inGame)	
	elif _state == GameGlobal.eGameStates.inGame :	
		doInGame(delta)
	elif _state == GameGlobal.eGameStates.endGame :	
		doEndGame()
	pass

func set_paused(p : bool) :
	paused = p

func load(path : String):
	# load your json files with combat system config them add initiate those 
	# values.
	_gameStateFileConfigs = Utils.FileHandler.read_json_dic_from_file(path)	
	_state = _gameStateFileConfigs["state"]
	print("Game current state: [" + String(_state) + "]")
	pass

#warning-ignore:unused_argument
func save(path : String):
	print("Saving game state!")
	pass
	
func setState(state : int):
	_state = state

func doSaveGame():
	# save the game then return to inGame state #
	pass

func doStartGame():
	#not for LOADING games !
	var campaign : String = GameGlobal.currentcampaign
	# load the campaign's on_campaign_start.gd script and run it
	var onstartGD : GDScript = load(Paths.campaignsfolderpath + GameGlobal.currentcampaign + "/on_campaign_start.gd" )
	
	onstartGD.before_loading_ressources()
	
	GameGlobal.campaign_global_script = load(Paths.campaignsfolderpath + GameGlobal.currentcampaign + "/campaign_global_script.gd" ).new()
	
	var resources = NodeAccess.__Resources()
	resources.load_campaign_ressources( campaign )
	# only on starting new game !!!
#	resources.load_shops_resources(campaign, resources.items_book)
	GameGlobal.load_shops_script(campaign)
	GameGlobal.campaign_start_load_shops_resources(resources.items_book)
	
	
	onstartGD.after_loading_ressources()
	
	map.load_map( campaign, GameGlobal.currentmap )
#	print(map.tiles_book["bags"])
	map.visible = true
	
	GameGlobal.show_menu(UI.ow_hud)
	GameGlobal.setupDefaultUI()
	
	#var itemmodel = NodeAccess.__Resources().items_book["Leather Cap"]
	#print(itemmodel)
	print("items_book")
	print(NodeAccess.__Resources().items_book.keys())
	
	
	var leatherhelm = NodeAccess.__Resources().items_book["Leather Cap"]
#	leatherhelm["equipped"] = 0
	GameGlobal.player_characters[0].inventory.append(leatherhelm.duplicate(true))
	
	var healpotion = NodeAccess.__Resources().items_book["Health Potion"]
	GameGlobal.player_characters[0].inventory.append(healpotion.duplicate(true))
	
	var dagger = NodeAccess.__Resources().items_book["Dagger"]
	GameGlobal.player_characters[0].inventory.append(dagger.duplicate(true))
	GameGlobal.player_characters[0].inventory.append(dagger.duplicate(true))
	
	var buckler = NodeAccess.__Resources().items_book["Buckler"]
	GameGlobal.player_characters[0].inventory.append(buckler.duplicate(true))
	GameGlobal.player_characters[0].inventory.append(buckler.duplicate(true))
	
	var lantern = NodeAccess.__Resources().items_book["Lantern"]
	GameGlobal.player_characters[0].inventory.append(lantern.duplicate(true))
	
	var shieldblue = NodeAccess.__Resources().items_book["Shield of the Blue Oxen"]
	GameGlobal.player_characters[0].inventory.append(shieldblue.duplicate(true))
	
	var ringregen = NodeAccess.__Resources().items_book["Ring of Regeneration"]
	GameGlobal.player_characters[0].inventory.append(ringregen.duplicate(true))
	
	if(GameGlobal.player_characters.size()>=2) :
		var ironhelm = NodeAccess.__Resources().items_book["Iron Cap"]
#		ironhelm["equipped"] = 0
		GameGlobal.player_characters[1].inventory.append(ironhelm.duplicate(true))
	

func doEndGame():
	doSaveGame()
	pass
	
func doInGame(_delta : float):
	if map.visible :
		manage_map_inputs(_delta)
	if GameGlobal.gamescreenInstance.inventoryRect.visible :
		manage_inventorymenu_inputs(_delta)

func manage_inventorymenu_inputs(_delta : float) :
	var invRect = GameGlobal.gamescreenInstance.inventoryRect
	var selectedctrl = invRect.selected_item_ctrl
	if selectedctrl == null :

		if Input.is_action_just_pressed("move_up") :
			if invRect.inventoryBoxRight.get_child_count()>0 :
				# select the last item in the inventory
				var invsize = invRect.hud.selected_character.inventory.size()
				invRect.set_selected_item_ctrl( invRect.inventoryBoxRight.get_child(invsize-1) )
				return
		if Input.is_action_just_pressed("move_down") :
			if invRect.inventoryBoxRight.get_child_count()>0 :
				# select the first item in the R list
				invRect.set_selected_item_ctrl( invRect.inventoryBoxRight.get_child(0) )
				return
		if (Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right") ):
			if invRect.traderect.visible :
				if invRect.inventoryBoxLeft.get_child_count()>0 :
					invRect.set_selected_item_ctrl( invRect.inventoryBoxLeft.get_child(0) )
					return
			# if traderect not visible and contains suff, nothing happens
	
	else : # selectedctrl not null
		var vbox = selectedctrl.get_parent()
		var ownerchar = selectedctrl.get_parent().get_parent().get_inventory_owner()
		var item_index_in_owner_inv = ownerchar.inventory.find(selectedctrl.item)
		var ownerinvsize = ownerchar.inventory.size()
		var vdir : int = 0
		if Input.is_action_just_pressed("move_up") :
			vdir = -1
		if Input.is_action_just_pressed("move_down") :
			vdir = 1
		if vdir != 0 :
			var new_selected_item = ownerchar.inventory[(item_index_in_owner_inv+vdir) % ownerinvsize]
			var newselectedctrl = null
			for ctrl in vbox.get_children() :
				if ctrl.item == new_selected_item :
					newselectedctrl = ctrl
					break
			if newselectedctrl != null :
				invRect.set_selected_item_ctrl(newselectedctrl)
			return
		if (Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right") ):
			if invRect.traderect.visible :
#				var is_ok : bool = false
				if vbox == invRect.inventoryBoxRight :
					if invRect.inventoryBoxLeft.get_child_count()>0 :
						invRect.set_selected_item_ctrl( invRect.inventoryBoxLeft.get_child(0) )
						return
				else :
					if invRect.inventoryBoxRight.get_child_count()>0 :
						invRect.set_selected_item_ctrl( invRect.inventoryBoxRight.get_child(0) )
						return

					


func manage_map_inputs(delta : float) :
	if map.mouseinside :
		var cursorpos = get_dir_input_from_mouse(delta)
		Input.set_custom_mouse_cursor(cursor_map_dict[cursorpos])
	else :
		Input.set_custom_mouse_cursor(cursor_sword)
	if map.pressed :
		last_dir_input = get_dir_input_from_mouse(delta)
	else :
		last_dir_input = get_dir_input(delta)
#	print(time_since_last_dir_input,' / ',GameGlobal.gamespeed)
	if time_since_last_dir_input >= GameGlobal.gamespeed and last_dir_input!=Vector2.ZERO :
#		print("move")
		time_since_last_dir_input = 0
		
		GameGlobal.allow_character_swap(false)
		GameGlobal.currentSpecialEncounterName = "default.gd"
		GameGlobal.money_pool = [0,0,0]
		GameGlobal.currentShop = ''
		GameGlobal.set_money_change_enabled(false)
		if GameGlobal.camping and last_dir_input != Vector2.ZERO :
			UI.ow_hud._on_CampButton_pressed()
			
		
		var playerposx : int = map.focuscharacter.tile_position_x
		var playerposy : int = map.focuscharacter.tile_position_y
		var tilestack : Array = map.mapdata[playerposx+last_dir_input.x][playerposy+last_dir_input.y]
#		print(tilestack)
		var attemptedpos : Vector2 = Vector2(playerposx+last_dir_input.x, playerposy+last_dir_input.y)
		var canmoveandtime : Array = on_trying_to_move_to_tile_stack(tilestack[0], attemptedpos )
		if canmoveandtime[0] :
			map.focuscharacter.move(last_dir_input)
			GameGlobal.pass_time(canmoveandtime[1])

	pass

func get_dir_input(delta)->Vector2 :
	var dir = Vector2.ZERO
	if (Input.is_action_pressed("move_up")):
		dir += Vector2.UP
	if (Input.is_action_pressed("move_down")):
		dir += Vector2.DOWN
	if (Input.is_action_pressed("move_left")):
		dir += Vector2.LEFT
	if (Input.is_action_pressed("move_right")):
		dir += Vector2.RIGHT
	if (Input.is_action_pressed("move_upleft")):
		dir = Vector2.UP+Vector2.LEFT
	if (Input.is_action_pressed("move_upright")):
		dir = Vector2.UP+Vector2.RIGHT
	if (Input.is_action_pressed("move_downleft")):
		dir = Vector2.DOWN+Vector2.LEFT
	if (Input.is_action_pressed("move_downright")):
		dir = Vector2.DOWN+Vector2.RIGHT
	if dir == Vector2.ZERO :
		time_since_last_dir_input = GameGlobal.gamespeed
	else :
		time_since_last_dir_input+= delta
	return dir

func get_dir_input_from_mouse(delta)->Vector2 :
	var dir = Vector2.ZERO
	var mousepos : Vector2 = map.get_local_mouse_position()
	var mouseposrelative : Vector2 = mousepos - map.charactersnode.position - map.focuscharacter.get_pixel_position() - Vector2(16,16)
	if (-16 <= mouseposrelative.x and mouseposrelative.x <=16 and
	-16 <= mouseposrelative.y and mouseposrelative.y <=16) :
		time_since_last_dir_input = GameGlobal.gamespeed
		return dir
	else :
		var angle = mouseposrelative.angle()
		if abs(angle)<=PI/8 :
			dir = Vector2.RIGHT
		if abs(angle - PI/4 )<=PI/8 :
			dir =  Vector2.RIGHT + Vector2.DOWN
		if abs(angle - PI/2 )<=PI/8 :
			dir = Vector2.DOWN
		if abs(angle - 3*PI/4 )<=PI/8 :
			dir = Vector2.LEFT + Vector2.DOWN
		if abs(angle)>7*PI/8 :
			dir = Vector2.LEFT
		if abs(angle + PI/4 )<=PI/8 :
			dir =  Vector2.RIGHT + Vector2.UP
		if abs(angle + PI/2 )<=PI/8 :
			dir =  Vector2.UP
		if abs(angle + 3*PI/4 )<=PI/8 :
			dir =  Vector2.LEFT + Vector2.UP
		time_since_last_dir_input+= delta
		return dir

func on_trying_to_move_to_tile_stack(stack : Dictionary, position : Vector2) :
	var canwalk : bool = true
	var soundplayed : bool = false
	stack["light"] = true
#	for tile in stack["items"] :
#		##TODO  run script on  trytowalk with tile
#		if tiles_book[tile]['wall'] != '0' :
#			canwalk = false
	var stacksize = stack["items"].size()
	var timetowalk : int = 0
	for i  in range(stack["items"].size()) :
#		print(stack["items"][stacksize-i-1])
		var idef = tiles_book[stack["items"][stacksize-i-1]]
#		print (idef)
		timetowalk += int(idef["time"])
		if idef['wall'] != '0' :
			canwalk = false
		if not soundplayed and idef['sound'] != [] :
			soundplayed = true
			var soundslist : Array = idef['sound']
			soundslist.shuffle()
			
			SfxPlayer.stream = sounds_book[soundslist[0]]
			SfxPlayer.play()
			
	# check for scripts on the map :
	canwalk = canwalk and check_map_script(position)
#	var lastinstack : Dictionary = tiles_book[stack["items"][stack["items"].size()-1]]
#	print(lastinstack)
#	print('\n')
	return [canwalk, timetowalk ]

func check_map_script(position) ->bool :
	var canwalk = true
	for s in map.mapscriptareas :
		var sr = map.mapscriptareas[s]
		var l = sr["leftTopPoint"]['x']
		var u = sr["leftTopPoint"]['y']
		var r = sr["rightBotPoint"]['x']
		var d = sr["rightBotPoint"]['y']
		if l<=position.x and position.x<=r :
			if u<=position.y and position.y<=d :
				print("Script rectangle : ", s , ", script : ", sr["scriptToLoad"])
				#find the script
				map.mapscripts.call(sr["scriptToLoad"])
				map.update()
				GameGlobal.refresh_OW_HUD()
	return canwalk

func set_cursor_number(n:int) :
	Input.set_custom_mouse_cursor(cursor_numbers[clamp(n,0,8)])
