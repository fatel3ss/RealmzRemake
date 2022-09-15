extends Panel

onready var campaignsItemList : ItemList = $CampaignsItemList

onready var startButton : Button = $StartButton

onready var charPickRect : Control = $CharPickRect 


var campaignslist : Array = [] # array of Strings
var characterfoldernameslist : Array = [] # array of String
var characterslist : Array = [] # array of Character.gd objects
var charactersdict : Dictionary = {}  #  name : characterGD


var selectedCampaign : String = ''

var pickedparty : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err_connnectcampaign = campaignsItemList.connect("item_selected", self, "_on_campaign_selected")
#	campaignsItemList.connect("nothing_selected", self, "_on_campaign_unselected")
	var _err_connectstartbutton = startButton.connect("pressed", self, "_on_StartButton_pressed")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_CancelButton_pressed() -> void :
	self.hide()
	self.get_parent().get_parent().newCharacterButton.show()

func _on_campaign_selected(idx : int) -> void :
#	print(idx, campaignsItemList.get_item_text(idx))
	selectedCampaign = campaignsItemList.get_item_text(idx)
	GameGlobal.set_current_campaign(selectedCampaign)
	$SelectedCampaignNameLabel.text = selectedCampaign
	$SelectedCampaignDescrLabel.text = GameGlobal.get_currentcampaign_description()
	#reset the character picking panel
	charPickRect.fill()

func _on_StartButton_pressed() -> void :
#	var howmany =  pickedcharsItemList.get_item_count()
#	if howmany == 0 or howmany > 6 :
#		return
#	##TODO  also check scenario restrictions !
#	var pickedCharactersNames : Array = []
#	for p in range(howmany) :
#		pickedCharactersNames.append(pickedcharsItemList.get_item_text(p))
#	var pickedCharacters : Array = []
#	for p in pickedCharactersNames :
#		pickedCharacters.append(charactersdict[p])	
#
	GameGlobal.time = 0  #TODO  depends on campaign ? done by scrit now
	GameGlobal.player_characters = pickedparty


#	GameGlobal.currentcampaign = selectedCampaign
	GameState._state = GameGlobal.eGameStates.startGame
#	GameGlobal.startCampaign(selectedCampaign)
	#get_tree().get_root().remove_child(get_parent().get_parent().get_parent())
#
	return
		




func fill() -> void :
	charPickRect.fill()

	campaignslist = Utils.FileHandler.list_files_in_directory(Paths.campaignsfolderpath)
	campaignsItemList.clear()
	for c in campaignslist :
		campaignsItemList.add_item(c)

	return

func set_ready(rdy : bool, party : Array) :
	startButton.disabled = not rdy
	if rdy :
		pickedparty = party#GameGlobal.player_characters = party
	else :
		pickedparty = []
#	print("characters : ",characterlist)
