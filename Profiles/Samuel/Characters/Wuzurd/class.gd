#extends 'res://Creature/classrace_base.gd' # Weird, right?

const classrace_name  : String = "Sorcerer"
const classrace_definition : String = "Can use MAGIC !"

const can_dual_wield : bool = false

#Applied once on character creation
const base_stat_bonuses : Dictionary = {
	"MaxMovement" : -1,		#Movement points
	"MaxActions" : 0,			#Actions per round
	"Weight_Limit" : 0,
	"Strength" : -2,
	"Intellect" : +2,
	"Wisdom" : +1,
	"Dexterity" : 0,
	"Vitality" : -1,
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


const levelup_bonuses : Dictionary = {
	"MaxMovement" : 0,		#Movement points
	"MaxActions" : 0,			#Actions per round
	"Weight_Limit" : 0,
	"Strength" : 0,
	"Intellect" : 0,
	"Wisdom" : 0,
	"Dexterity" : 0,
	"Vitality" : 0,
	"curHP" : 3,
	"curSP" : 0,
	"maxHP" : 3,
	"maxSP" : 0,
	"HP_regen_base" : 0.0,
	"SP_regen_base" : 0.0,
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



static func _mod_equippable(character) :
	character.equippable_types["Dagger"] +=1
	character.equippable_types["Throwing Dagger"] -=1
	character.equippable_types["Dart"] +=1
	character.equippable_types["Plate Armor"] -=10
	character.equippable_types["Splint Armor"] -=10
	character.equippable_types["Chainmail Armor"] -=10
	character.equippable_types["Large Shield"] -=10
	character.equippable_types["Medium Shield"] -=10
	character.equippable_types["Great Helm"] -=10
	character.equippable_types["Light Helmet"] -=10
	character.equippable_types["Arming Sword"] -=10
	character.equippable_types["Warhammer/Maul"] -=10

static func _add_base_stats(character) :
	for s in base_stat_bonuses :
		if typeof (base_stat_bonuses[s] ) == TYPE_DICTIONARY  :
			if not character.stats.has(s) :
				character.stats[s] = {}
				for t in base_stat_bonuses[s] :
					character.stats[s][t] = 0
			for t in base_stat_bonuses[s] :
				character.stats[s][t] += base_stat_bonuses[s][t]
		else :
			if not character.stats.has(s) :
				character.stats[s] = 0
			character.stats[s] += base_stat_bonuses[s]



static func _level_up(character) :
	for s in levelup_bonuses :
		if typeof (levelup_bonuses[s] ) == TYPE_DICTIONARY  :
			if not character.stats.has(s) :
				character.stats[s] = {}
			for t in levelup_bonuses[s] :
				character.stats[s][t] += levelup_bonuses[s][t]
		else :
			if not character.stats.has(s) :
				character.stats[s] = 0
			character.stats[s] += levelup_bonuses[s]

static func can_learn_spell(character, spell) -> bool :
	return true

static func _character_creation_gifts(character) :
	var resources = NodeAccess.__Resources()
	resources.load_item_resources("shared_assets/items/")
	var dagger = resources.items_book["Dagger"]
	character.inventory.append(dagger.duplicate(true))
	resources.items_book.clear()
	
	print("class.gd adding spell to newly created  sorcerer "+character.name)
	resources.load_spell_resources( "res://shared_assets/spells/" )
	print("class.gd load_spell_resources  finished")
	character.add_spell_from_spells_book("Heal Minor Wounds") #fuction in creature.gd
	print("class.gd DONE adding spell to newly created  sorcerer "+character.name)