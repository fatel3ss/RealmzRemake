extends Object
#Only custom classes that inherit from Object or another class can be extended (have child classes)

# Declare member variables here. Examples:
var name : String = 'Base Creature'

var aiPackage : GDScript = null

var position : Vector2 = Vector2.ZERO # in tiles, coordinates should be positive integers. 0,0 = top left of map.
var size : Vector2 = Vector2.ONE
var dirfaced : int = 1  #  <0  is left, >0 is right
var selected : bool = false
var textureL : Texture = null #the image for the creature, facing left
var textureR : Texture = null # the image for the creature facing right
#if after initialization  TextureR is null, it will be just a horizontally flipped version of textureL

var baseFaction : int = 1 #0= allies of player. 1=Enemy, 2=Neutral. More faction ally/enemy relations can be defined in scenario data.
var curFaction : int = baseFaction # if a creature is attacked by its friends  or Charmed by another faction, they may temporarily switch sides and help another faction.

var money : Array = [0,0,0]  #gold gems jewels

var spells : Array = []


var stats : Dictionary = {
	"MaxMovement" : 0,		#Movement points
	"MaxActions" : 0,			#Actions per round
	"Strength" : 0,
	"Intellect" : 0,
	"Wisdom" : 0,
	"Dexterity" : 0,
	"Vitality" : 0,
	"Weight_Limit" : 0,
	"curHP" : 0,
	"curSP" : 0,
	"maxHP" : 0,
	"maxSP" : 0,
	"HP_regen_base" : 1.0,
	"SP_regen_base" : 1.0,
	"HP_regen_mult" : 0.0, #added to the character's multiplier
	"SP_regen_mult" : 0.0, #added to the character's multiplier
	"AccuracyMelee" : 0,
	"AccuracyRanged" :0,
	"AccuracyMagic" : 0,
	"EvasionMelee" : 0,
	"EvasionRanged" : 0,
	"EvasionMagic" : 0,
	"ResistancePhysical" : 0.0,
	"ResistanceFire" : 0.0,
	"ResistanceIce" : 0.0,
	"ResistanceElect" : 0.0,
	"ResistancePoison" : 0.0,
	"ResistanceChemical" : 0.0,
	"ResistanceDisease" : 0.0,
	"ResistanceMagic" : 0.0,
	"ResistanceHealing" : 0.0,
	"MultiplierPhysical" : 0.0,
	"MultiplierFire" : 0.0,
	"MultiplierIce" : 0.0,
	"MultiplierElect" : 0.0,
	"MultiplierPoison" : 0.0,
	"MultiplierChemical" : 0.0,
	"MultiplierDisease" : 0.0,
	"MultiplierMagic" : 0.0,
	"MultiplierHealing" : 0.0
	# Resistances is damage  taken substracted, Multipliers is damage taken multiplied.
	# Damage taken = (base_damage - damage_resistance)*damage_multiplier
	
} 

var base_stats = stats.duplicate(true)

var level : int = 0 # Except for Players, this is only indicative of a Creature's power

var abilities : Array = [] #Melee attack, magic, items etc
var inventory : Array = [] # items worn/carried and usable/dropped by this creature


#var innateEffects : Array = []   # Array of objets of class "StatusEffect"
#var equipmentEffects : Array = []
#var temporaryEffects : Array = []


var traits : Array = [] 
var tags : Array = [] # Reptilian, Humanoid, Undead, Intelligent etc



func set_textures(lefttext : Texture, righttext : Texture = null)->void :
	textureL = lefttext
	if righttext == null :
		var  img = lefttext.get_data().flip_x()
		textureR = ImageTexture.new()
		textureR.create_from_image(img,0)
	else :
		textureR = righttext

func move(dir : Vector2)->void :
	position += dir

func move_to(newpos : Vector2)->void :
	position = newpos

#func get_effects()->Array :
#	var alleffects : Array = []
#	for e in innateEffects :
#		alleffects.append({e : innateEffects[e]} )
#	for e in equipmentEffects :
#		alleffects.append({e : innateEffects[e]})
#	for e in temporaryEffects :
#		alleffects.append({e : innateEffects[e]})
#	return alleffects

func get_mp_cost_for_tile(tile : Dictionary)->int : #<0 means not walkable
	var walkeffects : Array = []
	for e in traits  :
		if e.has_method("_on_walking_on_item") :
			walkeffects.append(e)
	var cost : float = 0
	for e in walkeffects :
		for i in tile["items"] :
			if i.is_wall :
				return -1
	#		var icost = 0
			var icostfromeffect = e._on_walking_on_item(i)
			if icostfromeffect[1] :  #should return now
				return int(max(0, icostfromeffect[0]))
			else :
				cost += icostfromeffect[0]
	return int(min(cost,1))

		
func recalculate_stats() :
	print("called creaturegd.recalculate_stats")
#	NodeAccess.__MainScene().get_tree().quit()
#	print(name," max hp is ",stats["maxHP"], " cur hp is ",stats["curHP"])
	for s in stats :
		if s != 'curHP' and s != 'curSP' :
			stats[s] = base_stats[s]
	for e in  inventory :
		if e["equipped"] == 1 :
			for s in e["stats"] :
				stats[s] += e["stats"][s]
	for t in traits :
		for s in stats :
#			if t.has_method("_on_calculate_"+s) :
#				stats[s] += t.call("_on_calculate_"+s)
#			var tproperties = t.get_property_list()
			if "_on_calculate_"+s in t :
				stats[s] += t.get("_on_calculate_"+s)
#	print("stats recalculated for ", name)
#	print(name," max hp is ",stats["maxHP"], " cur hp is ",stats["curHP"])

func get_stat(stat : String) :
	if stat == "Weight_Limit" :
		return 1200
	return stats[stat]

# checks for weight or other limitations and scripts
func can_add_inventory_item(item : Dictionary) ->bool :
#	print("creature can add inventory item :")
#	print(get_inventory_weight()+item_get_weight(item),' <> ',stats["Weight_Limit"])
	return get_inventory_weight()+item_get_weight(item)<=get_stat("Weight_Limit")

func item_get_weight(item : Dictionary)->int :
	return item["weight"]+item["charges_weight"]*item["charges"]

func get_inventory_weight() -> int :
	var carriedweight : int = 0
	for i in inventory :
		carriedweight += item_get_weight(i)
	carriedweight += ( money[0] +money[1] +money[2] )
	return carriedweight

func get_movement() ->int :
	return int(ceil(stats["MaxMovement"]*get_inventory_weight()/get_inventory_weight()))

func add_inventory_item(item : Dictionary,  index = -1) ->bool :
	if true :
		if index==-1 :
			inventory.append(item)
		else :
			inventory.insert(index,item)
		return true
	else :
		return false

func drop_inventory_item(item : Dictionary) -> bool :
	print(name+" drop_inventory_item "+item["name"])
	if item["equipped"]!=0 :
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book['generation error.ogg']
		SfxPlayer.play()
		return false
	var dropped = true
	if item.has("_on_drop_source") :
		var returned = item["_on_drop"]._on_drop(self,item)
		if returned != null :
			dropped = returned
	if dropped :
		inventory.erase(item)
	return dropped



func add_trait(traitscript) :
	traits.append(traitscript)
	print(name, traits)

func remove_trait(traitscript) :
	traits.erase(traitscript)
	print(name, traits)


func add_spell_from_source(spellname : String, spellsource : String) :
	var spellscript  = GDScript.new()
	spellscript.set_source_code(spellsource)
	var _err_newscript_reload = spellscript.reload()
	var level = spellscript.level
	spells[level-1].append({"name":spellname, "source":spellsource, "script":spellscript})

func add_spell_from_spells_book(spellname : String) :
	var resources = NodeAccess.__Resources()
	var spelldict = resources.spells_book[spellname]
	var level = spelldict["script"].level
	while spells.size() < level :
		spells.append([])
	spells[level-1].append(spelldict)

func _on_time_pass(seconds : int) :
#	print("time pass ",name, traits)
	for t in traits :
#		print ("trait "+t.name )
		if t.has_method("_on_time_pass") :
#			print(name+" "+t.name+" _on_time_pass  execution")
			t._on_time_pass(self, seconds)
#		else :
#			print ("trait "+t.name+" has no _on_time_pass method")


# returns stats of the spell when cast by this character
func get_spell_data(spell, power : int) :
	var spelldata : Dictionary = {}
	
	for vn in ["attributes", "resist", "aoe", "los", "graphics","sounds"  ] :
		var datum = spell.get(vn)
		var methodname : String = "_on_get_spell_"+vn
		for t in traits :
			if t.has_method(methodname) :
				# Object. Variant call(method: String, ...) vararg
				datum = t.call(methodname, datum, spell, power, self)
		spelldata[vn] = datum

	var hits = spell.get_hits(power, self)
	for t in traits :
		if t.has_method("_on_get_spell_hits") :
			hits = t._on_get_spell_hits(hits,spell, power, self)
	spelldata["hits"] = hits
	
	var srange = spell.get_range(power, self)
	for t in traits :
		if t.has_method("_on_get_spell_range") :
			srange = t._on_get_spell_range(srange,spell, power, self)
	spelldata["range"] = srange

	var sp_cost = spell.get_sp_cost(power, self)
	for t in traits :
		if t.has_method("_on_get_spell_sp_cost") :
			sp_cost = t._on_get_spell_sp_cost(sp_cost,spell, power, self)
	spelldata["sp_cost"] = floor(sp_cost)

	var tg_number = spell.get_target_number(power, self)
	for t in traits :
		if t.has_method("_on_get_spell_target_number") :
			tg_number = t._on_get_spell_target_number(tg_number,spell, power, self)
	spelldata["tg_number"] = floor(tg_number)

	return spelldata

func get_spell_cost(spell,power : int) :
	var sp_cost = spell.get_sp_cost(power, self)
	for t in traits :
		if t.has_method("_on_get_spell_sp_cost") :
			sp_cost = t._on_get_spell_sp_cost(sp_cost,spell, power, self)
	return floor(sp_cost)


#func _on_spell_cast(spell, powerlevel) -> Array:
#	var spcost = spell.get_sp_cost(powerlevel)
##	var attacks = {Attributes, Damage, }
#	for t in traits :
#		if t.has_method("_spell_cost_mod") :
#			spcost = t._spell_cost_mod(spell, powerlevel, spcost)
#	stats["curSP"] -= int(spcost)
#
#	var attacks : Array = []
#	for h in range(spell.hits) :
#		var new_attack : Dictionary = {}
#		new_attack["Attributes"] = spell.attributes
#		new_attack["Damage"] = spell.get_damage_roll(powerlevel)
#
#
#
#		attacks.append(new_attack)
#	for t in traits :
#		if t.has_method("_spell_mod") :
#			attacks = t._spell_mod(attacks, spell, powerlevel)
#	return attacks


# Called when the node enters the scene tree for the first time.
func _ready():
	print("wow i actually  can use a  ready function")
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

