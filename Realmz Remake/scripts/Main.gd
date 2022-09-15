extends Node

export var debug = false

onready var _combatSystem # child from main #
#onready var _gameState # child from main # Now Autoloaded

func _ready():
	_combatSystem = get_node("CombatSystem") # access the child #
#	_gameState = get_node("GameState") # access the child #
	# load all game modules.
	_combatSystem.load("configs/combatConfigs.json")	
	GameState.load("configs/gameState.json")	
	pass # Replace with function body.
	var _err1 = get_tree().root.connect("size_changed", NodeAccess.__Map(), "_on_viewport_size_changed")
	var _err2 = get_tree().root.connect("size_changed", UI.ow_hud, "_on_viewport_size_changed")
	NodeAccess.__Map()._on_viewport_size_changed()
	UI.show_only(UI.main_menu)
	
# THE MAIN LOOP GAME ARCHITECTURE #
func _process(delta: float):	
	# 1) process input (dont need to manipulate, godot is already doing) #
	# 2) game update #
	# --> access your classes and update them, if they have any logic, process:
	_combatSystem.update(delta)
	GameState.update(delta)
	# 3) render (can be done automatic by godot) # 
	pass

func _exit_tree():
	_combatSystem.save("configs/combatConfigs.json")
	GameState.save("configs/gameState.json")
	pass
