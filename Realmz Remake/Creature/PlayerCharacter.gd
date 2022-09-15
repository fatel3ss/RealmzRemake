extends 'res://Creature/Creature.gd' # Weird, right?



var portrait : Texture = null
var icon : Texture = null

var exp_tnl : int = 999999999999

var classgd : GDScript = null
var racegd : GDScript = null

var can_dual_wield : bool = false
var hands : int = 2
var free_hands : int = 2

var equippable_types : Dictionary = {
	"Mace" : 1,
	"Club" : 1,
	"Hammer" : 1,
	"Warhammer/Maul" : 1, # Two handed big blunt weapons
	"Dagger" : 1, # Better thana  knife ?
	"Shortsword" : 1, # Good for rogues and archers
	"Arming Sword" : 1, # Long 1 handed sword
	"Longsword" : 1,  # 2 handed or bastard swords
	"Short Axe" : 1,
	"Staff" : 1,
	"Pole Axe" : 1,
	"Spear" : 1,
	"Eastern Weapon" : 1,
	"Dart" : 1,
	"Throwing Bottle" : 1,
	"Throwing Dagger" : 1,
	"Throwing Rock" : 1,
	"Throwing Axe" : 1,
	"Throwing Hammer" : 1,
	"Throwing Spear" : 1,
	"Whip" : 1,
	"Bow" : 1,
	"Crossbow" : 1,
	"Quiver" : 1,
	"Throwing Aid" : 1,
	"Misc. Melee Weapon" : 1,
	"Misc Ranged Weapon" : 1,
	"Belt" : 1,
	"Necklace" : 1,
	"Ring" : 1,
	"Hat" : 1,  #cloth headwear
	"Soft Helmet" : 1, # Leather Cap...
	"Light Helmet" :1, # iron Cap
	"Great Helm" : 1, # Big Warrior helmet
	"Small Shield" : 1, #Bucklers for Fencers/Rogues...
	"Medium Shield" : 1,
	"Large Shield" : 1, #Kite/Tower shields
	"Bracers" : 1,
	"Cloth Gloves" : 1,
	"Leather Gloves" : 1,
	"Metal Gloves" : 1,
	"Cloak/Cape" : 1,
	"Robe" : 1,
	"Gambeson" : 1, #can be worn with plate armor ?
	"Leather Armor" : 1,
	"Chainmail Armor" : 1,
	"Splint Armor" : 1,
	"Plate Armor" : 1,
	"Soft Boots" : 1,
	"Hard Boots" : 1,
	"Scroll Case" : 1
}


# 0 =  free, 1 =  occupied
var equipment_slots : Dictionary = {
	"Melee Weapon" : 0,
	"Ranged Weapon" : 0,
	"Ammunition" : 0,
	"Head" : 0,
	"Body" : 0,
	"Hands" : 0,
	"Shield" : 0,
	"Feet" : 0,
	"Neck" : 0,
	"Belt" : 0,
	"Accessory" : 0
}

func _init(data : Dictionary, new_icon : ImageTexture, new_portrait : ImageTexture, new_classgd : GDScript, new_racegd : GDScript):
#	print("PlayerCharacterGD .init data :")
#	print(data)
	if not ("name" in data) :
		name = "NO NAME SET YET"
	else :
		name = data['name']
#		level = data["level"]
	level = 0
	portrait = new_portrait
	icon = new_icon
	classgd = new_classgd
	racegd = new_racegd
	
	if data.has("money") :
		money = data["money"]
	else :
		money = [0,0,0]
	
	if data.has("spells") :
		spells = data["spells"]
		for slevel in spells :
			for spelldict in slevel :
				var spellscript : GDScript = GDScript.new()
				var spellsource = spelldict["source"]
				spellscript.set_source_code(spellsource)
				var _err_newscript_reload = spellscript.reload()
				var newscript = spellscript.new()
				spelldict["script"] = newscript
	else :
		spells = []
		
	if classgd :
		classgd._mod_equippable(self)
	if racegd :
		racegd._mod_equippable(self)
	apply_raceclass_base_stats()
	
	for i in range(data["level"]) :
#		print("lvel up to ",data["level"]," : ", level)
		level_up()
	
	# generate inventory from the data dict :
	if data.has("inventory") :
		var data_inventory = data["inventory"]
		var resources = NodeAccess.__Resources()
		for item_dict in data_inventory :
			var new_item = resources.generate_item_from_json_dict(item_dict)
			add_inventory_item(new_item)
			if new_item["equipped"] == 2 : #had been marked for equipping in Utils save_character
				equip_item(new_item)
	if data.has("traits") :
		var data_traits = data["traits"]  #{source:"",
		for trait_dict in data_traits :
			if trait_dict["type"] == "standard" :
				var traitscript = load("res://shared_assets/traits/"+trait_dict["name"])
				add_trait(traitscript.new( trait_dict["saved_variables"] ) )
			elif  trait_dict["type"] == "custom" :
				var newscript = GDScript.new()

				var source = trait_dict["source"]
				newscript.set_source_code(source)
				var _err_newscript_reload = newscript.reload()
				if _err_newscript_reload != OK :
					print("ERROR LOADING CHaracter TRAIT SCRIPT "+" , error code : "+_err_newscript_reload)

				if trait_dict["saved_variables"] != [] :
					add_trait(newscript.new(trait_dict["saved_variables"]) )
				else :
					add_trait(newscript.new() )
		
func apply_raceclass_base_stats() :
	classgd._add_base_stats(self)
	racegd._add_base_stats(self)
	base_stats = stats.duplicate(true)
	
	stats["curHP"] = base_stats["maxHP"]
	stats["curSP"] = base_stats["maxSP"]
	print(name," has curHP maxHP : ", stats["curHP"], ' ',stats["maxHP"])
	can_dual_wield = classgd.can_dual_wield and racegd.can_dual_wield




func level_up() :
	racegd._level_up(self)
	classgd._level_up(self)
	level +=1

func equip_item(item) -> bool :  #returns true iff could equip
	# check if item is in my inventory first !
	if not inventory.has(item) :
		print("ERROR : This character doesn't own this item lol")
		return false
	# Actually Equip the item
	if can_equip_item(item) :
		
		for s in item["slots"] :
			equipment_slots[s]=1
		
		if item.has("hands") :
			free_hands -= item["hands"]
		
		item["equipped"] = 1
		if item.has("_on_equipping") :
#			print("item "+item["name"]+" on equipping")
			item["_on_equipping"]._on_equipping(self, item)
		else :
			print("item has no \"_on_equipping\" script")
		
		if item.has("traits") :
			for t in item["traits"] :
				add_trait(item[t])
				
		
		print(item.name, " equipped : ", item["equipped"])
		recalculate_stats()
		return true
	else :
		return false



func unequip_item(item) :
	# check if item is in my inventory first !
	if not inventory.has(item) :
		print("ERROR : This character doesn't own this item lol")
		return
	# Actually Unequip the Item :
	
	for s in item["slots"] :
		equipment_slots[s]=0
	
	if item.has("hands") :
		free_hands += item["hands"]
	
	if item.has("traits") :
		for t in item["traits"] :
			remove_trait(item[t])
	
	item["equipped"] = 0
	recalculate_stats()
	print(item.name, " equipped : ", item["equipped"])

func can_equip_item(item) -> bool :

	print(equipment_slots)
	var hasfreeslots : bool = true
	for s in item["slots"] :
		hasfreeslots = hasfreeslots and (equipment_slots[s]==0)
	if item.has("hands") :
	
	# you can equip two 1 handed melee weapons if you can dual wield
	# however you may still equip  only  one shield
		if item["slots"].has("Shield") :
			hasfreeslots = hasfreeslots and (free_hands >= item["hands"])
		else :
			hasfreeslots = can_dual_wield and (free_hands >= item["hands"])
	return equippable_types[item["type"]]>0 and hasfreeslots



