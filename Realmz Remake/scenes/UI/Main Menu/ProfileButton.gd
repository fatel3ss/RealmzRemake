extends Button

onready var profilespopup : PopupMenu = $ProfilePopupMenu
onready var newCampaignButton : Button = $NewCampaignButton
onready var newCampaignPanel : Panel = $NewCampaignButton/NewCampaignPanel
onready var newCharacterButton : Button = $NewCharacterButton
onready var newCharacterPanel : Panel = $NewCharacterButton/NewCharacterPanel
var profileslist : Array =  []

# Called when the node enters the scene tree for the first time.
func _ready():	
	var _err_on_Button_pressed = connect("pressed", self, "_on_Button_pressed")
	var _err_on_Profile_Selected = profilespopup.connect("id_pressed", self, '_on_Profile_Selected')
	var _err_on_newCampaignButton_pressed = newCampaignButton.connect("pressed", self, 'on_newCampaignButton_pressed')
	var _err_on_newCharacterButton_pressed = newCharacterButton.connect("pressed", self, 'on_newCharacterButton_pressed')
	build_profiles_list()
	var profilefromcfg = Utils.FileHandler.get_cfg_setting(Paths.realmzfolderpath+"settings.cfg","SETTINGS","current_profile", "Default Profile")
	var dir = Directory.new()
	if dir.dir_exists(Paths.profilesfolderpath+"/" + profilefromcfg) :
		GameGlobal.set_current_profile(profilefromcfg)
		self.text = profilefromcfg
		newCampaignButton.disabled = false
		newCharacterButton.disabled = false

func _on_Button_pressed() -> void :
	profilespopup.set_position ( self.get_position() )
	profilespopup.popup()
	profilespopup.show()

func _on_Profile_Selected(id :  int) -> void :
	newCampaignButton.disabled = false
	newCharacterButton.disabled = false
	self.text = profileslist[id]
	GameGlobal.set_current_profile(profileslist[id])




func build_profiles_list() -> void :
	profilespopup.clear()
#	for child in profilespopup.get_children() :
#		profilespopup.remove_child(child)
#		child.queue_free()
	profileslist = Utils.FileHandler.list_files_in_directory(Paths.profilesfolderpath)
	for i in range(profileslist.size()) :
		#add_item(label: String, id: int = -1, accel: int = 0)
		profilespopup.add_item(profileslist[i])

func on_newCampaignButton_pressed() -> void :
	newCampaignPanel.fill()
	newCampaignPanel.show()
	newCharacterButton.hide()

func on_newCharacterButton_pressed() ->void :
	newCharacterPanel.set_clean_character()
	newCharacterPanel.fill()
	newCharacterPanel.show()
	newCampaignButton.hide()
