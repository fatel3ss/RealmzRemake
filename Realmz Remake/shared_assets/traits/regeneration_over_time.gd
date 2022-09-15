const name : String = 'regeneration_over_time.gd'

var power : float = 0
var duration : int = 0

#var saved_variables : Array = [power, duration]

func _init(args : Array) :
	#npower : float, nduration : int
	power = args[0]
	duration = args[1]

func get_saved_variables() :
	return [power, duration]

func _on_time_pass(character, s : int) :
	#print('regeneration_over_time.gd ! ')
	character.stats['curHP'] += s*power
	if duration >=0 :
		duration -= s
		if duration <= 0 :
			character.remove_trait(self)
#	character.name = 'debug'
