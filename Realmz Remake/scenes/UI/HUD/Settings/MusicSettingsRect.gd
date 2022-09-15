extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var type0Button = $"Type0Label/Type0Button"
onready var type1Button = $"Type1Label/Type1Button"
onready var type2Button = $"Type2Label/Type2Button"
onready var type3Button = $"Type3Label/Type3Button"
onready var type4Button = $"Type4Label/Type4Button"
onready var type5Button = $"Type5Label/Type5Button"
onready var type6Button = $"Type6Label/Type6Button"
onready var type7Button = $"Type7Label/Type7Button"
onready var type8Button = $"Type8Label/Type8Button"
onready var type9Button = $"Type9Label/Type9Button"
onready var type10Button =$"Type10Label/Type10Button"
onready var typebuttons : Array = [type0Button,type1Button,type2Button,type3Button,type4Button,type5Button,type6Button,type7Button,type8Button,type9Button,type10Button]

const types : Array = ["Battle", "Camp", "Cave", "Create", "Dungeon", "Indoor", "Items", "Outdoor", "Shop", "Temple", "Treasure"]
const typeindexesdict : Dictionary = {"Battle":0, "Camp":1, "Cave":2, "Create":3, "Dungeon":4, "Indoor":5, "Items":6, "Outdoor":7, "Shop":8, "Temple":9, "Treasure":10}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _initialize() :
	print("\n\n\n MusicSettingsRect READY")
	var index : int = 0
	var favourites = MusicStreamPlayer.oneofeachtype
	
	
	for b in typebuttons :
		b.connect("pressed", self, "_on_typebutton_pressed", [b,index])
#		index = b.get_index()
		var btype : String = types[index]
		b.set_text(favourites[btype])
		#get all the musics of this type
		var typemusicnames : Array = NodeAccess.__Resources().musics_types_book[btype].keys()
		typemusicnames.append("Random !")
		typemusicnames.append("No Change")
		typemusicnames.append("No Music")
		#add buttons with musicnames to the popup vbox
		var bvbox = b.get_child(0).get_child(0).get_child(0)
		for m in typemusicnames :
			var nbutton : Button = Button.new()
			nbutton.set_text(m)
			nbutton.connect("pressed", self, "_on_typepopup_button_pressed", [btype,m,b])
			bvbox.add_child(nbutton)
		index +=1
#		popup.set_global_position(bposition+Vector2(2,20))
#		popup.set_size(Vector2(196,popupvsize),true)
	print("\n\n\n")

func _on_typepopup_button_pressed(type : String, mname : String, typebutton) :
		typebutton.get_child(0).hide()
		typebutton.set_text(mname)
		print(type + " "+ mname)
		#set this in the profile_settings.cfg
#		Utils.FileHandler.set_cfg_setting(path, section, key, value) :
		var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/profile_settings.cfg'
		print("Utils.FileHandler.set_cfg_setting : ",path)
		MusicStreamPlayer.set_type_music_choice(type,mname)
		Utils.FileHandler.set_cfg_setting(path, "MUSIC", type, mname)
#		Paths.profilesfolderpath+newprofilename+'/profile_settings.cfg'

func _on_typebutton_pressed(button, index : int) :
		var popup : PopupPanel = button.get_child(0)
		var bglobalpos : Vector2 = button.get_global_position()
		
		var screeny = UI.ow_hud.get_mofified_screensize().y
		var ysize = screeny-bglobalpos.y-60
		
		var dropmenusize : int = button.get_child(0).get_child(0).get_child(0).get_child_count()
		
#		var popupvsize :float = min( ysize , dropmenusize*20+20)
		popup.popup( Rect2( bglobalpos+Vector2(0,20), Vector2(196,ysize) ) )

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
