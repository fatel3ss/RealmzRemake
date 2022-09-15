static func before_loading_ressources() :
	pass

static func after_loading_ressources() :
	GameGlobal.time = 86401	#set starting dime  (day 1, 1s)
	GameGlobal.currentmap = "default_map"	# set starting map