"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

##########
### UI ###
##########

This module represents a user interface.
All operations over UI should use this wrapper.
"""
extends Node

onready var main_menu : CanvasItem = $MainMenuNode2D
onready var ow_hud : Control = $OWHUDControl
onready var allmenus : Array = [main_menu, ow_hud]

func _ready():	
	pass

# Hide all user interface #
func __hide():
	# 0 is the root above canvasLayer #
	get_child(0).hide()

func show_only(menu : CanvasItem) :
	print(allmenus)
	for m in allmenus :
		if menu == m :
			menu.show()
		else :
			m.hide()

