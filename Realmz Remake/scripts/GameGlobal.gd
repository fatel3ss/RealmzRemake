"""
# Authors: Samuel Rebrearu , Francisco De Biaso Neto
# email: kikinhobiaso@gmail.com

##################
### GameGlobal ###
##################

This module is responsible for wrapper the game logic.
"""
extends Node

var playerCharacterGD : GDScript = preload("res://Creature/PlayerCharacter.gd")
var gameScreenTSCN : PackedScene = preload("res://scenes/UI/HUD/OWHUDControl.tscn")
var gamescreenInstance

enum eGameStates {off,startGame,inGame,saveGame,endGame}
enum eCombatStates {off,startCombat,inCombat,endCombatFail,endCombatSuccess}

var currentcampaign : String = ''
var currentcampaign_onload_script : GDScript = null
var campaign_global_script = null
var currentprofile : String = 'Default Profile'
var profile_characters_list : Array = []


var currentmap : String = 'Default Map'
var currentShop : String = ''
var currentSpecialEncounterName : String = "default.gd"
var gamespeed : float = 0.2

var time : int = -1  #the time (date) in-game. -1 = invalid
var player_characters : Array = []
var light_time : int = 0
var light_power : int = 0
var camping : bool = false
var money_pool : Array = [0,0,0] # coins gems jewels
var money_banked : Array = [0,0,0] # coins gems jewels

var shopScript = null # a script that initializes shops on campaign start and may run script on accessing shops
var shops_dict : Dictionary = {}

var in_combat : bool = false

#var selecting_several_characters_count : int = 0
#var selected_several_characters : Array = []



func _ready():
	pass
# UI start ------------------- #

# Hide all UI elements #
func hideAllUI():
	NodeAccess.Get.__UI().__hide()
	
func show_menu(menu : CanvasItem) :
	UI.show_only(menu)

func setupDefaultUI():
	gamescreenInstance = UI.ow_hud
	gamescreenInstance.initialize()

func create_new_profile(newprofilename : String ) -> bool :
	var profilesfolderpath = Paths.profilesfolderpath
	

	# http://docs.godotengine.org/en/latest/classes/class_lineedit.html#class-lineedit
	var dir = Directory.new()
	print("dir exists ? ",  dir.dir_exists(profilesfolderpath))
	if not dir.dir_exists(profilesfolderpath+"/" + newprofilename) :
		dir.make_dir_recursive(profilesfolderpath+"/" + newprofilename)
		dir.make_dir_recursive(profilesfolderpath+"/" + newprofilename +"/Characters/")
		dir.make_dir_recursive(profilesfolderpath+"/" + newprofilename +"/Saves/")
		
		var settingscfgFile = File.new()
		var path = Paths.profilesfolderpath+newprofilename
		print("new char path : ", path)
		dir.make_dir_recursive(path)
		settingscfgFile.open(path+'/profile_settings.cfg', File.WRITE)
#		settingscfgFile.store_line('{"}')
		settingscfgFile.close()
		
		print("created profile folder for "+newprofilename+" at " +profilesfolderpath + newprofilename)

		return true

	else:
		return false

func set_current_profile(profilename : String) -> void :
	
	Paths.currentProfileFolderName = profilename
	#save this profile as the current one to the game wide cfg
	Utils.FileHandler.set_cfg_setting(Paths.realmzfolderpath+"settings.cfg","SETTINGS","current_profile", profilename)
	#load the settings from this profile
	var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/profile_settings.cfg'
	#get_cfg_setting(path, section, key, default) :
	for type in MusicStreamPlayer.oneofeachtype.keys() :
		var favofthistype : String = Utils.FileHandler.get_cfg_setting(path, "MUSIC", type, "No Music")
		MusicStreamPlayer.set_type_music_choice(type,favofthistype)
	GameGlobal.load_profile_characters()


func load_profile_characters() :
	profile_characters_list.clear()
	#load all the characters
	var characterfoldernameslist = Utils.FileHandler.list_files_in_directory(Paths.profilesfolderpath+"/"+Paths.currentProfileFolderName+"/Characters/")
	for c in characterfoldernameslist :
		load_character_to_profile(c)
#		var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'+c
#		print("charpick rect charpath : ",path)
#		var newchar = Utils.FileHandler.load_character(path)
#		print("loaded char ", newchar.name)
#		profile_characters_list.append(newchar)
#		charactersdict[newchar.name] = newchar


func load_character_to_profile(c : String) :
	var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'+c
	print("charpick rect charpath : ",path)
	var newchar = Utils.FileHandler.load_character(path)
	print("loaded char ", newchar.name)
	profile_characters_list.append(newchar)

func pass_time(seconds : int) :
	time += seconds
	
	if campaign_global_script.has_on_time_pass :
		campaign_global_script._on_time_pass(seconds)
	
	for character in player_characters :
		character._on_time_pass(seconds)
	
#	player_characters[0].stats["curHP"] = seconds
	gamescreenInstance.updateTimeDisplay()
	gamescreenInstance.updateCharPanelDisplay()
	light_time = clamp(light_time-seconds,0,31536000)
	if light_time == 0 :
		light_power = 0

func add_light_effect(p : int, t : int) :
	light_power = max(light_power, p)
	light_time = (light_power*light_time+p*t)/light_power

func load_shops_script(campaign : String) :
	var shopsgd_path = Paths.campaignsfolderpath+ campaign + "/shops.gd"
	shopScript = load(shopsgd_path).new()
	print("GameGlobal loaded shops script : ", shopScript)


func campaign_start_load_shops_resources(itemsbook : Dictionary) :
	# only on starting new campaign, not loading
	shops_dict = shopScript.build_shops(itemsbook)

func get_shop(shopname : String) :
	return shopScript.get_shop(shopname, shops_dict[shopname])

func refresh_OW_HUD() :
	gamescreenInstance.updateCharPanelDisplay()
	gamescreenInstance.updateTimeDisplay()
	var invrect = gamescreenInstance.inventoryRect
	if invrect.visible :
#		invrect.when_Items_Button_pressed()
		invrect.fill_inventory_Vbox(invrect.inventoryBoxRight, gamescreenInstance.selected_character)
		if invrect.traderect.visible :
			invrect.fill_inventory_Vbox(invrect.inventoryBoxLeft, invrect.selectedTradeCharacter)
	
func show_loot_menu(items:Array, money : int, experience : int) :
	gamescreenInstance.show_loot_menu(items,money,experience)



func set_current_campaign(campname : String) :
	currentcampaign = campname
	# get the campaign's info and restrictions script
	currentcampaign_onload_script = load(Paths.campaignsfolderpath + currentcampaign + "/on_select.gd" )


func get_currentcampaign_description() -> String:
	if currentcampaign_onload_script==null :
		print("NO currentcampaign_onload_script loaded !!!")
		return "NO currentcampaign_onload_script loaded !!!"
	return currentcampaign_onload_script.description

func get_currentcampaign_restrictions_description() -> String:
	if currentcampaign_onload_script==null :
		print("NO currentcampaign_onload_script loaded !!!")
		return "Pick a campaign first !"
	return currentcampaign_onload_script.restrictions_description

func can_character_enter_currentcampaign(chara) -> bool :
	if currentcampaign_onload_script==null :
		print("NO currentcampaign_onload_script loaded !!!")
		return false
	return currentcampaign_onload_script.can_character_enter(chara)

func get_currentcampaign_max_party_size() -> int :
	if currentcampaign_onload_script==null :
		print("NO currentcampaign_onload_script loaded !!!")
		return 0
	return currentcampaign_onload_script.characters_limit


func allow_character_swap(yes : bool) :
	# enables the party swap button until you move
	gamescreenInstance.set_party_swap_enabled(yes)

func allow_money_change(yes : bool) :
	# enables the party swap button until you move
	gamescreenInstance.set_money_change_enabled(yes)

func change_map(mapname : String, x : int, y : int) :
	print("change_map : "+mapname+" ; "+String(Vector2(x,y)))
	var map = NodeAccess.__Map()
	currentmap = mapname
	map.load_map(currentcampaign, currentmap)
	MusicStreamPlayer.play_music_map()
	map.set_ow_character_icon(GameGlobal.player_characters[0].icon)


func rest() :
	pass_time(5)

func set_money_change_enabled(yes : bool) :
	gamescreenInstance.moneyControl.set_money_change_enabled(yes)

#	NodeAccess.__MainScene().add_child(gamescreenInstance)
# UI end ------------------- #

#func startCampaign(campaign : String) :
#	print(" GameGlobal.startCampaign : " + campaign)
#	# load ressources specific to this campaign :
#	var resources = NodeAccess.__Resources()
#	resources.load_campaign_ressources( campaign )
#	var map = NodeAccess.__Map()
#	map.load_map( campaign, "default" )
#	NodeAccess.__Map().visible = true
