# useless ! expanding on this doesnt let you use const variables !

const classrace_name  : String = "Class or Race Name"
const classrace_definition : String = "Class or Race Definition"

#Applied once on character creation
const base_stat_bonuses : Dictionary = {
	"Movement" : 0,		#Movement points
	"Actions" : 0,			#Actions per round
	"Strength" : 0,
	"Intellect" : 0,
	"Wisdom" : 0,
	"Dexterity" : 0,
	"Vitality" : 0,
	"HP" : 0,
	"SP" : 0,
	"HP_regen_base" : 1.0,
	"SP_regen_base" : 1.0,
	"HP_regen_mult" : 0.0, #added to the character's multiplier
	"SP_regen_mult" : 0.0, #added to the character's multiplier
	"Accuracy" : {"Melee" : 0, "Ranged" : 0, "Magic" : 0},
	"Evasion" : {"Melee" : 0, "Ranged" : 0, "Magic" : 0},
	"Resistances" : {"Physical" : 0.0, "Fire" : 0.0, "Ice" : 0.0, "Elect" : 0.0, "Poison" : 0.0, "Chemical" : 0.0, "Disease" : 0.0, "Magic" : 0.0, "Healing" : 0.0},
	# Resistances is damage  taken substracted, Multipliers is damage taken multiplied.
	# Damage taken = (base_damage - damage_resistance)*damage_multiplier
	"Multipliers" : {"Physical" : 1.0, "Fire" : 1.0, "Ice" : 1.0, "Elect" : 1.0, "Poison" : 1.0, "Chemical" : 1.0, "Disease" : 1.0, "Magic" : 1.0, "Healing" : -1.0},
}


const levelup_bonuses : Dictionary = {
	"Movement" : 0,		#Movement points
	"Actions" : 0,			#Actions per round
	"Strength" : 0,
	"Intellect" : 0,
	"Wisdom" : 0,
	"Dexterity" : 0,
	"Vitality" : 0,
	"HP" : 0,
	"SP" : 0,
	"HP_regen_base" : 0.0,
	"SP_regen_base" : 0.0,
	"HP_regen_mult" : 0.0, #added to the character's multiplier
	"SP_regen_mult" : 0.0, #added to the character's multiplier
	"Accuracy" : {"Melee" : 0.0, "Ranged" : 0.0, "Magic" : 0.0},
	"Evasion" : {"Melee" : 0.0, "Ranged" : 0.0, "Magic" : 0.0},
	"Resistances" : {"Physical" : 0, "Fire" : 0, "Ice" : 0, "Elect" : 0, "Poison" : 0, "Chemical" : 0, "Disease" : 0, "Magic" : 0, "Healing" : 0},
	# Resistances is damage  taken substracted, Multipliers is damage taken multiplied.
	# Damage taken = (base_damage - damage_resistance)*damage_multiplier
	"Multipliers" : {"Physical" : 0.0, "Fire" : 0.0, "Ice" : 0.0, "Elect" : 0.0, "Poison" : 0.0, "Chemical" : 0.0, "Disease" : 0.0, "Magic" : 0.0, "Healing" : -0.0},
}

var extra_items : Array = []
var extra_abilities :  Array = []
var extra_effects : Array = []

#mostly meant to be used on character creation / levelup to apply stat bonuses
static func _add_base_stats(character) :
	for s in base_stat_bonuses :
		if typeof (base_stat_bonuses[s] ) == TYPE_DICTIONARY  :
			if not character.stats.has(s) :
				character.stats[s] = {}
			for t in base_stat_bonuses[s] :
				character.stats[s][t] = base_stat_bonuses[s][t]
		else :
			if not character.stats.has(s) :
				character.stats[s] = 0
			character.stats[s] = base_stat_bonuses[s]

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

