#extends 'res://Creature/classrace_base.gd' # Weird, right?

const classrace_name  : String = "Elf"
const classrace_definition : String = "Like you, but better."
const can_dual_wield : bool = true

#Applied once on character creation
const base_stat_bonuses : Dictionary = {
	"MaxMovement" : 1,		#Movement points
	"MaxActions" : 1,			#Actions per round
	"Weight_Limit" : 0,
	"Strength" : 9,
	"Intellect" : 11,
	"Wisdom" : 11,
	"Dexterity" : 11,
	"Vitality" : 8,
	"curHP" : 0,
	"curSP" : 0,
	"maxHP" : 3,
	"maxSP" : 1,
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
	character.equippable_types["Bow"] +=1


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

static func _character_creation_gifts(character) :
	return