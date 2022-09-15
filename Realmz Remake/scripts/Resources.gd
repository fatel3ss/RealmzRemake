"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

#######################
### Resource Module ###
#######################

All resources are loaded and accessed through this module.
"""
extends Node

# Global resource variables #
#var g_thing_types = {}
#var g_stuff_book = {}
#var g_img_pack = {}
#var g_map_things = {}
var g_scripts = {}
#var g_texture_atlas = Image.new()

var images_book : Dictionary = {}
var tiles_book : Dictionary = {}	#contains data about the tiles used in maps
var items_book : Dictionary = {}	# contains models of standard items.


var maps_book : Dictionary = {}	#contains maps
var thingtypes : Dictionary = {"ground" : 0, "ground_level" : 1, "furnitures" : 2, "creatures" : 3, "structures" : 4}

var sounds_book : Dictionary = {}

var spells_book : Dictionary = {}

var musics_book : Dictionary = {}
var musics_types_book : Dictionary = {}

var special_encounters_book : Dictionary = {}

#var shopsGD = null

# Initialize resources #
func _ready():
	pass
	load_music_resources(Paths.datafolderpath+'Music/')
#	load_shared_ressources()
#	load_map_resources()
#	load_audios()

# Load data that any campaign can access
#func load_shared_ressources() ->void:
#	var path : String = "shared_assets/tiles/"
#	g_img_pack = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path + "img_pack.json"))
#	g_stuff_book = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"stuff_book.json"))
#	g_texture_atlas.load(path+"textureAtlas.png")
#	pass


# dict must have a SCRIPT_source  key with the script source as the value
func _add_script_to_dict_from_source(dict : Dictionary,scriptname : String , argsstring : String) :
#		print("adding script "+scriptname+" to "+dict["name"])
		var newscript : GDScript = GDScript.new()
		var source : String = "static func "+scriptname+argsstring + "  :\n" + dict[scriptname+"_source"]
		newscript.set_source_code(source)
		var _err_newscript_reload = newscript.reload()
		dict[scriptname] = newscript



func clear_ressources() -> void:
	tiles_book.clear()
	maps_book.clear()
	items_book.clear()
	sounds_book.clear()
	musics_book.clear()
	musics_types_book.clear()
	special_encounters_book.clear()
	spells_book.clear()
#	shopsGD = null
	load_music_resources(Paths.datafolderpath+'Music/')


func load_campaign_ressources( campaign : String = "") ->void :
	clear_ressources()
	load_tile_resources("shared_assets/tiles/")
	var tilesetspath : String = Paths.campaignsfolderpath + campaign + "/Tilesets/"
	var tilesets : Array = Utils.FileHandler.list_files_in_directory(tilesetspath)
	for ts in tilesets :
		load_tile_resources(tilesetspath + ts + '/')
	
	load_item_resources("shared_assets/items/")
	var itemsetpath : String = Paths.campaignsfolderpath + campaign + "/Items/"
	load_item_resources(itemsetpath)
	
	load_sound_ressources("shared_assets/sounds/")
	var soundsspath : String = Paths.campaignsfolderpath + campaign + "/Sounds/"
	load_sound_ressources(soundsspath)
	
#	print(sounds_book)
	load_music_resources(Paths.datafolderpath+'Music/')
	var musicspath = Paths.campaignsfolderpath + campaign + "/Music/"

#	print("load musics from campaing now")
#	print(Paths.datafolderpath+'Music/')
#	print(musicspath+'\n')
	
	load_music_resources(musicspath)
	
	load_spell_resources( "res://shared_assets/spells/" )
	var spellspath = Paths.campaignsfolderpath + campaign + "/Spells/"
	load_spell_resources(spellspath)
#	print("\n\n", "spell resources : \n", spells_book.keys() ,"\n\n")
	
	load_special_encounter_resources(campaign)
	# only done once on starting the campaign !
#	load_shops_resources(campaign, items_book)
	
	var mapspath : String =  Paths.campaignsfolderpath + campaign + "/Maps/"
	var mapnames : Array = Utils.FileHandler.list_files_in_directory(mapspath)
	for mn in mapnames :
		load_map_ressources(mapspath + mn + '/', mn)

#	print(maps_book.keys())
#	print (tiles_book["BYWATER_extrafloor"])

# Load tiles data, added to the tiles_book ressource dictionary #
func load_tile_resources( path : String ) -> void:		
	# load the tile data at the "path" location
	var n_tile_img_pack : Dictionary = {}
	n_tile_img_pack = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path + "img_pack.json"))
	
	var texture_atlas : Image = Image.new()
	var _err_textureatlasload = texture_atlas.load(path+"textureAtlas.png")
	
	for i in n_tile_img_pack :
		# Get position inside  texture atlas #
		var rect = Rect2(n_tile_img_pack[i]["0_ref_x"] * Utils.GRID_SIZE, n_tile_img_pack[i]["0_ref_y"] * Utils.GRID_SIZE, Utils.GRID_SIZE, Utils.GRID_SIZE)
		# Create a new texture for this thing #
		var texture = ImageTexture.new()
		var image = texture_atlas.get_rect(rect)
		# Loads texture from texture atlas #
		texture.create_from_image(image,0)
		images_book[i] = {}
		images_book[i]["img"] = image
		images_book[i]["tex"] = texture
	
	var n_tile_stuff_book : Dictionary = {}
	n_tile_stuff_book = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"stuff_book.json"))
	
	var n_tile_templates : Dictionary = {}
	n_tile_templates = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"tile_templates.json"))
	var n_tile_defs : Dictionary = {}
	n_tile_defs = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"tile_defs.json"))

	
	for thing_name in n_tile_stuff_book :
		# Iterate through each tile name, load image data for it #
		# Get img ref #
		var img_ref = n_tile_stuff_book[thing_name]["img_ptr"]
		# find texture in images_book :
		var texture = images_book[img_ref]["tex"]
		# assign texture
		n_tile_stuff_book[thing_name]["texture"] = texture
		
		for item in n_tile_templates[n_tile_defs[thing_name]].keys() :
			n_tile_stuff_book[thing_name][item] = n_tile_templates[n_tile_defs[thing_name]][item]

	for thing_name in n_tile_stuff_book :
		tiles_book[thing_name] = n_tile_stuff_book[thing_name]
#	var folderpath : String = Paths.realmzfolderpath + "Campaigns"

	return

func load_item_resources( path : String ) -> void:		
	# load the item data at the "path" location
	var n_item_img_pack : Dictionary = {}
	n_item_img_pack = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path + "img_pack.json"))
	var texture_atlas : Image = Image.new()
	var _err_textureatlasload = texture_atlas.load(path+"textureAtlas.png")

	for i in n_item_img_pack :
		# Get position inside  texture atlas #
		var rect = Rect2(n_item_img_pack[i]["0_ref_x"] * 32, n_item_img_pack[i]["0_ref_y"] * 32, 32, 32)
		# Create a new texture for this thing #
		var texture = ImageTexture.new()
		var image = texture_atlas.get_rect(rect)
		# Loads texture from texture atlas #
		texture.create_from_image(image,0)
		images_book[i] = {}
		images_book[i]["img"] = image
		images_book[i]["tex"] = texture

	var n_item_stuff_book : Dictionary = {}
	n_item_stuff_book = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"stuff_book.json"))
#	print("\nloaded n_item_stuff_book ?\n")
#	print(n_item_stuff_book)
	
	for item_name in n_item_stuff_book :
		var new_item = generate_item_from_json_dict(n_item_stuff_book[item_name])
		n_item_stuff_book[item_name] = new_item
		
#		print("done loading item "+new_item["name"]  )

	for item_name in n_item_stuff_book :
		items_book[item_name] = n_item_stuff_book[item_name]
#	var folderpath : String = Paths.realmzfolderpath + "Campaigns"

func generate_item_from_json_dict(json_dict : Dictionary) -> Dictionary :
	# sets  item's sound image etc from its dict data
	# need to load sounds first !

#	print(json_dict)

	var new_item : Dictionary = {}
	if not json_dict.has("imgdata"):
		# item comes from a  stuffbook... get the image from imagebook
		# Get img ref #
		var img_ref = json_dict["img_ptr"]
		# find texture in images_book :
		var texture = images_book[img_ref]["tex"]
		# assign texture
		new_item["texture"] = texture
		var image : Image = images_book[img_ref]["img"]
		
		#<old>
	#		new_item["imgdata"]  = Marshalls.raw_to_base64(image.get_data())
	#		</old
	#		<new>
		var imgdata : PoolByteArray = image.save_png_to_buffer()
		var imgdatasize : int = imgdata.size()
		var imgdatacompressed : PoolByteArray = imgdata.compress(File.COMPRESSION_GZIP)
		# use  imgdatacompressed.decompress(imgdatasize, File.COMPRESSION_GZIP)  to decompress
		# now i need to turn this into a string
		new_item["imgdatasize"] = imgdatasize
		new_item["imgdata"]  = Marshalls.raw_to_base64(imgdatacompressed)
		# use Marshalls.base64_to_raw(new_item["imgdata"]) to recover  the compressed image data
		#</new>
	else :
		#extract the image from the compressed poolbytearray
		var imgdatacompressed : PoolByteArray = Marshalls.base64_to_raw(json_dict["imgdata"])
		var imgdata : PoolByteArray = imgdatacompressed.decompress(json_dict["imgdatasize"], File.COMPRESSION_GZIP)
		var image : Image = Image.new()
		image.load_png_from_buffer(imgdata)
#		image.create_from_data(32,32,false,Image.FORMAT_RGBA8,imgdata)
		#create_from_data(width: int, height: int, use_mipmaps: bool, format: Format, data: PoolByteArray)

		var texture : ImageTexture = ImageTexture.new()
		texture.create_from_image(image, 0) # no flags, no filter
		new_item["texture"] = texture
		new_item["imgdata"] = json_dict["imgdata"]
	new_item["name"] = json_dict["name"]
	new_item["type"] = json_dict["type"]
	new_item["sound"] = json_dict["sound"]
	
	if json_dict.has("hands") :
		new_item["hands"] = json_dict["hands"]
	else :
		new_item["hands"] = 0
	
	if json_dict.has("delete_on_empty") :
		new_item["delete_on_empty"] = json_dict["delete_on_empty"]
	else :
		new_item["delete_on_empty"] = 0
	
	if json_dict.has("slots") :
		new_item["slots"] = json_dict["slots"]
	else :
		new_item["slots"] = []
	
	if json_dict.has("equippable") :
		new_item["equippable"] = json_dict["equippable"]
	else :
		new_item["equippable"] = 0
	
	if json_dict.has("stats") :
		new_item["stats"] = json_dict["stats"]
	else :
		if new_item.has('equippable') :
			new_item["stats"] = {}
	
	if json_dict.has("stats_mini") :
		new_item["stats_mini"] = json_dict["stats_mini"]
	
	if json_dict.has("charges") :
		new_item["charges_max"] = json_dict["charges_max"]
		new_item["charges"] = json_dict["charges"]
	else :
		new_item["charges_max"] = 0
		new_item["charges"] = 0
	
	new_item["equipped"] = 0
	
	if json_dict.has("tradeable") :
		new_item["tradeable"] = json_dict["tradeable"]
	else :
		new_item["tradeable"] = 1
	
	if json_dict.has("weight") :
		new_item["weight"] = json_dict["weight"]
	else :
		new_item["weight"] = 0
	
	if json_dict.has("price") :
		new_item["price"] = json_dict["price"]
	else :
		new_item["price"] = 0
	
	if json_dict.has("charges_weight") :
		new_item["charges_weight"] = json_dict["charges_weight"]
	else :
		new_item["charges_weight"] = 0
	
	if json_dict.has("splittable") :
		new_item["splittable"] = json_dict["splittable"]
	else :
		new_item["splittable"] = 0
	
	#Load Scripts !
#	print("checking for item scripts  in "+new_item["name"])

	if json_dict.has("_on_equipping_source") :
		new_item["_on_equipping_source"] = json_dict["_on_equipping_source"]
		_add_script_to_dict_from_source(new_item,"_on_equipping", "(character, item)")
#	print("lol")
	if json_dict.has("_on_field_use_source") :
		new_item["_on_field_use_source"] = json_dict["_on_field_use_source"]
		_add_script_to_dict_from_source(new_item,"_on_field_use", "(character, item)")

	if json_dict.has("_on_drop_source") :
		new_item["_on_drop_source"] = json_dict["_on_drop_source"]
		_add_script_to_dict_from_source(new_item,"_on_drop", "(character, item)")
	
	# load traits !
	if json_dict.has("traits") :
		new_item["traits"] = json_dict["traits"]
		for traitname in json_dict["traits"] :
			var newscript : GDScript = GDScript.new()

			if traitname.ends_with('.gd') :
				newscript = load("res://shared_assets/traits/"+traitname)
				var args : Array = json_dict["traits"][traitname]
				new_item[traitname] = newscript.new(args)
			else :
				new_item[traitname+"_source"] = json_dict[traitname+"_source"]
				newscript.set_source_code(new_item[traitname+"_source"])
				var _err_newscript_reload = newscript.reload()
				if _err_newscript_reload != OK :
					print("ERROR LOADING ITEM TRAIT SCRIPT "+new_item["name"] + " "+traitname+ " , error code : "+_err_newscript_reload)
				new_item[traitname] = newscript.new()

#				else :
#					print("NO ERROR LOADING ITEM TRAIT SCRIPT "+new_item["name"] + " "+traitname)
			
#				print("\n\n")
#				print("new_item "+new_item["name"]+ " "+traitname+" \n" , new_item[traitname] )
#				print("\n\n")
	return new_item
	

func load_sound_ressources( path : String ) -> void :
	var filenames : Array = Utils.FileHandler.list_files_in_directory(path)
	var soundnames : Array = []
	for s in filenames :
		if s.ends_with(".ogg") :
			soundnames.append(s)
	print ("sounds in folder : ",soundnames)
	for s in soundnames :
#		print("sound path : ", path+s)
		var loadedsound : AudioStream
		# DOESNT WORK IN  OUTSIDE FOLDERS !
		if path == "shared_assets/sounds/" :
			loadedsound = load(path+s)
		else :
			var ogg_file = File.new()
			ogg_file.open(path+s, File.READ)
			var bytes = ogg_file.get_buffer(ogg_file.get_len())
			if s.ends_with("ogg") :
				loadedsound = AudioStreamOGGVorbis.new()
			elif s.ends_with("mp3") :
				loadedsound = AudioStreamMP3.new()
			elif s.ends_with("wav") :
				loadedsound = AudioStreamSample.new()
			loadedsound.data = bytes
			ogg_file.close()
		
		sounds_book[s] = loadedsound

func load_music_resources(path : String) :
	#path =  path to  a Music folder that may have subfolders
	#Paths.datafolderpath+"Music/"
	var subfoldernames = Utils.FileHandler.list_files_in_directory(path)
	#list all subfolders, this is just an array of Strings
	for sf in subfoldernames :
		if not musics_types_book.has(sf) :
			musics_types_book[sf] = {}
		var sfpath = path + sf #+ '/'
		var sfmusicnames = Utils.FileHandler.list_files_in_directory(sfpath)
		#again just an array of Strings
		for sfmn in sfmusicnames :
			var musicdict = {}
			if sfmn.ends_with("ogg") :
				musicdict["type"] = 'ogg'
				#just load .. NOTB ECAUSE IT S OUSTIDE res://
#				musicdict["sound"] = load(sfpath+'/'+sfmn)
				var ogg_file = File.new()
				ogg_file.open(sfpath+'/'+sfmn, File.READ)
				var bytes = ogg_file.get_buffer(ogg_file.get_len())
				var loadedsound = AudioStreamOGGVorbis.new()
				loadedsound.data = bytes
				ogg_file.close()
				musicdict["sound"] = loadedsound
			elif sfmn.ends_with("mp3") :
				musicdict["type"] = 'mp3'
				var mp3_file = File.new()
				mp3_file.open(sfpath+'/'+sfmn, File.READ)
				var bytes = mp3_file.get_buffer(mp3_file.get_len())
				var loadedsound = AudioStreamMP3.new()
				loadedsound.data = bytes
				mp3_file.close()
				musicdict["sound"] = loadedsound
			elif sfmn.ends_with(".mod") or sfmn.ends_with(".xm") :
				musicdict["type"] = 'mod'
			
			musicdict["path"] = sfpath+'/'+sfmn
				#the modplayer addon uses the path
			musics_types_book[sf][sfmn] = musicdict
			musics_book[sfmn]= musicdict
#			print("music resource loaded : "+sfmn,","+String(musicdict))
#	pass
#	print("MSUIC LOADED")
#	print(musics_book)

func load_spell_resources(path : String) :
	print("resources.gd load_spell_resources "+path)
#	print("load_spell_resources : "+ path +"spells_book.json")
	var n_spells_book = Utils.FileHandler.read_json_dic_from_file(path +"spells_book.json")
#	print("n_spells_book : ", n_spells_book)
	for sn in n_spells_book :
#		print("adding " +sn)

		var spellscript : GDScript = GDScript.new()
		var spellsource = n_spells_book[sn]
#		print("resources.gd before setting spell source code for "+sn)
#		print(spellsource)
		spellscript.set_source_code(spellsource)
#		print("resources.gd DONE set source code for "+sn+" , before reload()")

		var _err_newscript_reload = spellscript.reload()
#		print(_err_newscript_reload)
		var newscript = spellscript.new()
		spells_book[sn] = { "name" : sn, "source" : spellsource, "script" : newscript}
#		print("resources.gd DONE reload() for "+sn)
		
#		print("LITTLE TEST, ", spells_book[sn]["script"].get_min_damage(7))

# load map data, convert to an array, added to the maps_book ressource dictionary
func load_map_ressources( path : String , _name : String) -> void :
	var newmapdict : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path+"map_things.json"))
	var newmapinfo : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path+"map_info.json"))
	var newmapscriptareas : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path+"map_scriptareas.json"))
	
	var newmapscripts : GDScript = load(path + "map_scripts.gd" )
	
	var sizey : int = newmapinfo[ "size_y"]
	var sizex : int = newmapinfo[ "size_x"]
	var mapname : String = newmapinfo[ "name"]
	var maptype : String = newmapinfo["map_type"]
	var mapmusictype : String = newmapinfo["music_type"]
	var outdoor_riding : bool = newmapinfo["outdoor_riding"]
	var darkness_level : int = newmapinfo["darkness_level"]
	# build the array
	var newmapdata : Array = []
	for _y in range(sizey) :
		var newline : Array = []
		for _x in range(sizex) :
			newline.append([])
		newmapdata.append(newline)
	# fill the array with the items found in the json
	for t in newmapdict[ "map_units" ] :

		var x = t["x"]
		var y = t["y"]
#		var z = t["z"]
#		if z == 3 :
		var light : bool = bool(t["has_light"])
		var items : Array = Array(t["items"])
		items.sort_custom(self, "sort_item_type" )
		# items should be organized by layer
		var newtiledata : Dictionary = {"items":items, "light":light}

		newmapdata[x][y].append(newtiledata)
	maps_book[mapname] = [newmapdata, newmapscriptareas, newmapscripts, maptype,mapmusictype, outdoor_riding, darkness_level]
	return


func load_special_encounter_resources(campaign : String) :
	var encounters_folder_path = Paths.campaignsfolderpath+ campaign + "/Special Encounters/"
	var encounter_file_names : Array = Utils.FileHandler.list_files_in_directory(encounters_folder_path)
	for fn in encounter_file_names :
		var enc = load(encounters_folder_path+fn).new()
		special_encounters_book[fn] = enc
#	print("special encounters : ", special_encounters_book.keys())



func sort_item_type(a : String, b : String):
	# comparator for sorting items by  layer as defined in  thing_types.json
	return thingtypes[tiles_book[a]["type"]] < thingtypes[tiles_book[b]["type"]]



""" Accessible resources """

# Tiles Book :
func get_tiles_book() -> Dictionary:
	return tiles_book

func get_sounds_book() -> Dictionary:
	return sounds_book

# Img Pack
#func get_img_pack() -> Dictionary:
#	return g_img_pack

# Stuff Book
#func get_stuff_book() -> Dictionary:
#	return g_stuff_book

# Map things
#func get_map_things() -> Dictionary:
#	return g_map_things

# Thing types - Layers
#func get_thing_types() -> Array:
#	return g_thing_types
#
## Get texture Atlas #
#func get_texture_atlas() -> Image:
#	return g_texture_atlas


