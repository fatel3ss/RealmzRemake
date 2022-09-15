extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var charpickbuttonTSCN : PackedScene = preload("res://scenes/UI/Party Selection/CharPickButton.tscn")

onready var eligibleContainer : VBoxContainer = $EligibleListRect/EligibleScrollContainer/EligibleVBoxContainer
onready var teamContainer : VBoxContainer = $TeamListRect/TeamScrollContainer/TeamVBoxContainer

var selectedcharbutton = null

var characterfoldernameslist : Array = [] # array of String
#var characterslist : Array = [] # array of Character.gd objects
#var charactersdict : Dictionary = {}  #  name : characterGD


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func fill() :
	$RestrictionsLabel.text = GameGlobal.get_currentcampaign_restrictions_description()
	print("charpickretct fill()  :")
#	characterslist = []
#	charactersdict = {}
	characterfoldernameslist = Utils.FileHandler.list_files_in_directory(Paths.profilesfolderpath+"/"+Paths.currentProfileFolderName+"/Characters/")
	
	#load all the characters
#	for c in characterfoldernameslist :
#		var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'+c
#		print("charpick rect charpath : ",path)
#		var newchar = Utils.FileHandler.load_character(path)
#		print("loaded char ", newchar.name)
#		characterslist.append(newchar)
##		charactersdict[newchar.name] = newchar
	
	# clean the scroll containers
	for child in eligibleContainer.get_children() :
		eligibleContainer.remove_child(child)
		child.queue_free()
	for child in teamContainer.get_children() :
		teamContainer.remove_child(child)
		child.queue_free()
	
	for c in GameGlobal.profile_characters_list :
		print("charîckrect  adding panel for ", c.name)
		var charpickpanel = charpickbuttonTSCN.instance()
#		charpickpanel.set_text(c.name)
		var allowed = GameGlobal.can_character_enter_currentcampaign(c)
		charpickpanel.set_character(c, allowed)
		charpickpanel.connect("pressed", self, "_on_char_button_pressed", [charpickpanel])
		if GameGlobal.player_characters.has(c) :
			teamContainer.add_child(charpickpanel)
		else :
			eligibleContainer.add_child(charpickpanel)
	
func _on_char_button_pressed(bp) :
#	print("_on_char_button_pressed ", bp.character.name)
	for b in eligibleContainer.get_children() :
		b.set_highlighted(b==bp)
	for b in teamContainer.get_children() :
		b.set_highlighted(b==bp)
	selectedcharbutton = bp


func _on_AddButton_pressed():
	if selectedcharbutton == null  or selectedcharbutton.get_parent()!=eligibleContainer :
		return
	var partysize = $"TeamListRect/TeamScrollContainer/TeamVBoxContainer".get_child_count()
	if GameGlobal.get_currentcampaign_max_party_size() <= partysize :
		return
		
	eligibleContainer.remove_child(selectedcharbutton)
	teamContainer.add_child(selectedcharbutton)
	_on_char_button_pressed(selectedcharbutton)
	
	check_party_ok()

func _on_DropButton_pressed():
	if selectedcharbutton == null  or selectedcharbutton.get_parent()!=teamContainer :
		return
	teamContainer.remove_child(selectedcharbutton)
	eligibleContainer.add_child(selectedcharbutton)
	_on_char_button_pressed(selectedcharbutton)
	
	check_party_ok()


func check_party_ok() :
	var party : Array = []
	for cp in $"TeamListRect/TeamScrollContainer/TeamVBoxContainer".get_children() :
		party.append(cp.character)
	if party.size() <= GameGlobal.get_currentcampaign_max_party_size() and party.size()>0 :
		get_parent().set_ready(true, party)
	else :
		get_parent().set_ready(false, party)
