"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

####################
### Utils Module ###
####################

This module contains auxiliary functions and constantes.
"""
extends Node

# Constant #
const GRID_SIZE := 32

# File manipulator #
class FileHandler:	
	static func read_json_array_from_txt(txt) -> Array:
		var data_parse = JSON.parse(txt)
		if data_parse.error != OK:
			return []
		return data_parse.result	
	
	static func read_json_dic_from_file(path) -> Dictionary:
		return read_json_dictionary_from_txt(read_txt_from_file(path))

	static func read_json_dictionary_from_txt(txt) -> Dictionary:
		var data_parse = JSON.parse(txt)
		if data_parse.error != OK:
			return {}
		return data_parse.result

	static func read_txt_from_file(path) -> String:
		var data_file = File.new()
		if data_file.open(path, File.READ) != OK:
			return ""
		var data_text = data_file.get_as_text()
		data_file.close()
		return data_text
		
	static func list_files_in_directory(path) -> Array :  #copied from profileslist.gd
		# from https://godotengine.org/qa/5175/how-to-get-all-the-files-inside-a-folder
		var files = []
		var dir = Directory.new()
		var err = dir.open(path)
		if err!= 0 :
			print("listfile path error : ", err, " "+path)
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				files.append(file)
		dir.list_dir_end()
		return files
		
	static func get_cfg_setting(path, section, key, default) :
		var config = ConfigFile.new()
#		print(Paths.realmzfolderpath+"settings.cfg")
		var err = config.load(path)
		if err == OK: # if not, something went wrong with the file loading
			return config.get_value(section, key, default)	
	#	if not config.has_section_key(section, key):
	#			print(section, key)
		else :
			print("err",err)
				
	static func set_cfg_setting(path, section, key, value) :
		var config = ConfigFile.new()
		var err = config.load(path)
		if err == OK: # if not, something went wrong with the file loading
			# Look for the display/width pair, and default to 1024 if missing
	#		var screen_width = config.get_value("display", "width", 1024)
			# Store a variable if and only if it hasn't been defined yet
	#		if not config.has_section_key("audio", "mute"):
			config.set_value(section, key, value)
			print(key, value)
		else :
			print("err",err, " set_cfg_setting ",path)
		# Save the changes by overwriting the previous file
		config.save(path)
	
	static func load_character(path)-> GDScript :		
		var img = Image.new()
		var err = img.load(path+"/icon.png")
		if (err!=0) :
			print("error loading image at "+path+"/portrait.png")

		var newicon = ImageTexture.new()
		newicon.create_from_image(img)
		
		err = img.load(path+"/portrait.png")
		if (err!=0) :
			print("error loading image at "+path+"/portrait.png")
		
		var newportrait = ImageTexture.new()
		newportrait.create_from_image(img)		
		var jsonresult = read_json_dic_from_file(path+'/data.json')		
#		var newname = jsonresult['name']
#		var newavaillable = jsonresult['free']		
		
		var classgd : GDScript = load(path + "/class.gd")
		var racegd : GDScript = load(path + "/race.gd")
		
		var newchar = GameGlobal.playerCharacterGD.new(jsonresult, newicon, newportrait, classgd, racegd)
#		newchar.apply_raceclass_base_stats()
		
		return newchar
	
	
	static func save_character(path : String, chara) :
		print("Utils : saving character "+chara.name)
		var save_char = File.new()
		save_char.open(path+'/data.json', File.WRITE)
		#save simple stuff
		save_char.store_line('{"name":"'+chara.name+'", "level" : '+String(chara.level)+',"free":1, "money" : '+String(chara.money)+',')
		
		#save inventory 
		#to avoid saving traits from equiopment, temporarily unequip all
		var temp_unequipped_items : Array = []
		for item in chara.inventory :
			if item["equipped"] == 1 :
				if chara.unequip_item(item) :
					item["equipped"] == 2  #unequipped but tagged for re equipping
					temp_unequipped_items.append(item)
		
		save_char.store_line('"inventory" : [')
		var addcomma : String = ''
		for item in chara.inventory :
			var inventoryJSONstring : String = JSON.print(item)
			save_char.store_line(addcomma+inventoryJSONstring)
			addcomma = ','
		save_char.store_line('],')
		
		for item in temp_unequipped_items :
			chara.equip_item(item)
		
		#save spells
		var spellsJSONstring : String = JSON.print(chara.spells)
		save_char.store_line('"spells" : ')
		save_char.store_line(spellsJSONstring)
		save_char.store_line(',')
		
		#save traits :
		save_char.store_line('"traits" : [')
		addcomma = ''
		for trait in chara.traits :
			if trait.name.ends_with('.gd') :
				var savedvars = JSON.print(trait.get_saved_variables())
				var line : String = '{"type" : "standard", "name" : "'+trait.name+'", "saved_variables" : '+savedvars+'}'
				save_char.store_line(addcomma+line)
			else :
				var tsourcecode : String = trait.get_script().get_source_code()
	#			tsourcecode = "SAUCE"
				var savedvars = '[]'
				if trait.get("saved_variables") :
					savedvars = JSON.print(trait.get_saved_variables())
				save_char.store_line(addcomma+'{"type" : "custom", "source" : "'+tsourcecode +'", "saved_variables" : '+savedvars+'}')
			addcomma = ','
		save_char.store_line(']')
		save_char.store_line('}')
		save_char.close()

		
		
		var classsource : String = chara.classgd.get_source_code()
		save_char.open(path+'/class.gd', File.WRITE)
		save_char.store_string(classsource)
		save_char.close()
		var racesource : String = chara.racegd.get_source_code()
		save_char.open(path+'/race.gd', File.WRITE)
		save_char.store_string(racesource)
		save_char.close()

		var _err_savepng_portrait = chara.portrait.get_data().save_png(path+"/portrait.png")
		var _err_savepng_icon = chara.icon.get_data().save_png(path+"/icon.png")
	
		print("Utils : DONE saving character "+chara.name)
	
class Render:
	static func setAllChildrenLayers(nodeFather):
		if nodeFather == null:
			return
		for N in nodeFather.get_children():
			if N.get_child_count() > 0:  
				setAllChildrenLayers(N)
			else:			
				N.z_index = N.z_index + definition.Render.get_layer_space()		
				print(N.z_index)

func _ready() :
	pass
