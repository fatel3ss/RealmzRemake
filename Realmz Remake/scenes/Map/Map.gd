"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

##################
### Map Module ###
##################

Loads Things and add them into this Node.
"""

extends Node2D

# Get Thing Scene By default #
export (PackedScene) var _thing

var show_scripts : bool = true

var mapdata : Array = []
var mapscriptareas : Dictionary = {}
var mapscripts : GDScript = null
var maptype : String = ""
var mapmusictype : String = ""
var outdoor_riding : bool = false

var cam_x : int = 0
var cam_y : int = 0

var widthtiles : int = 32
var heighttiles : int = 18
const RIGHTPANELWIDTH : int = 320
const BOTTOMPANELHEIGHT : int = 200

var mouseinside : bool = false # true iff the mouse is inside teh map area / button
var pressed : bool = false # true iff the map (and not a character) is being clicked, used for movements.

onready var focuscharacter = get_node("Characters/OWPlayer")
onready var owcharacter = focuscharacter
onready var charactersnode = get_node("Characters")
onready var blacktexture : Texture = preload("res://shared_assets/Map Symbols/tileBlack.png")
onready var darktexture : Texture = preload("res://shared_assets/Map Symbols/tileDark.png")


var tiles_book : Dictionary = {}

var darkness_level : int = 0  #how dark is the map with no extra light from GameGlobals.light_time
const darkness_offset : int = 156
onready var darkness_00 : Texture= preload("res://scenes/Map/Darkness/darkness_00.png")
onready var darkness_01 : Texture= preload("res://scenes/Map/Darkness/darkness_01.png")
onready var darkness_02 : Texture= preload("res://scenes/Map/Darkness/darkness_02.png")
onready var darkness_03 : Texture= preload("res://scenes/Map/Darkness/darkness_03.png")
onready var darkness_04 : Texture= preload("res://scenes/Map/Darkness/darkness_04.png")
onready var darkness_05 : Texture= preload("res://scenes/Map/Darkness/darkness_05.png")
onready var darkness_06 : Texture= preload("res://scenes/Map/Darkness/darkness_06.png")
onready var darkness_array : Array = [darkness_00,darkness_01,darkness_02,darkness_03,darkness_04,darkness_05,darkness_06]

onready var riding_character : Texture = preload( "res://shared_assets/Map Symbols/Riding.png" )
onready var camping_character: Texture = preload( "res://shared_assets/Map Symbols/Camp.png" )

# Call functions to load the map #
func _ready():
	pass
#	load_map()

func set_ow_character_icon(icon : Texture) :
	if GameGlobal.camping :
		owcharacter.set_icon(camping_character)
		return
	elif outdoor_riding :
		owcharacter.set_icon(riding_character)
		return
	
	owcharacter.set_icon(icon)

# Load the game map #
func load_map( _campaign : String, mapname : String) -> void:
	var resources = NodeAccess.__Resources()
	mapdata = resources.maps_book[mapname][0]
	mapscriptareas = resources.maps_book[mapname][1]
	mapscripts = resources.maps_book[mapname][2]
	tiles_book = NodeAccess.__Resources().tiles_book
	maptype = resources.maps_book[mapname][3]
	mapmusictype = resources.maps_book[mapname][4]
	outdoor_riding = resources.maps_book[mapname][5]
	darkness_level = resources.maps_book[mapname][6]
#func update() :
#	manage_inputs()
#
#func manage_inputs() :
#	var dirpressed = Vector2.ZERO
#

func _on_viewport_size_changed() :
	var screensize : Vector2 = OS.get_window_size()
	
	var vscale =Vector2.ONE
	if screensize.x<512 :
		vscale.x = screensize.x/512
	if screensize.y<400 :
		vscale.y = screensize.y/400

	
	widthtiles = ceil(screensize.x/32)-(vscale.x*RIGHTPANELWIDTH/32)+3
	heighttiles = ceil(screensize.y/32)-(vscale.y*BOTTOMPANELHEIGHT/32)+1
	update()

func _draw() :
	
	cam_x = focuscharacter.tile_position_x - int((widthtiles)/2) +1
	cam_y = focuscharacter.tile_position_y - int((heighttiles)/2)
	charactersnode.position = Vector2(-cam_x*32,-cam_y*32)
	
	for x in range(widthtiles) :
		for y in range(heighttiles) :
			var tile = mapdata[cam_x+x][cam_y+y]
#			print(tile)
			if tile.empty() or tile[0]["items"].empty() :
				draw_texture_rect(blacktexture, Rect2(32*x,32*y,32,32), true)
			else :
				if !tile[0]["light"] :
					draw_texture_rect(darktexture, Rect2(32*x,32*y,32,32), true)
				else :
					for i in tile[0]["items"] :
#						print(i)
#						print(stuffbook[i]){image:[Image:1191], type:ground}
						draw_texture_rect(tiles_book[i]["texture"], Rect2(32*x,32*y,32,32), true)
	
	
	if darkness_level >=0 : 
		var light_level : int = darkness_level + GameGlobal.light_power
		light_level = int(clamp(light_level, 0, 6))
		if light_level <= 6 and light_level >=0:
			var focuschar_pos : Vector2 = focuscharacter.get_global_position()
			draw_texture_rect( darkness_array[light_level], Rect2( focuschar_pos-Vector2(darkness_offset,darkness_offset),Vector2(352,352)) , false )
			draw_rect(Rect2(Vector2(0,0),Vector2(widthtiles*16-darkness_offset,heighttiles*32) ), Color.black, true)
			draw_rect(Rect2(Vector2(widthtiles*16+darkness_offset-8,0),Vector2(widthtiles*16-darkness_offset,heighttiles*32) ), Color.black, true)
			draw_rect(Rect2(Vector2(0,0),Vector2(widthtiles*32,heighttiles*16-darkness_offset) ), Color.black, true)
			draw_rect(Rect2(Vector2(0,heighttiles*16+darkness_offset),Vector2(widthtiles*32,heighttiles*16-darkness_offset) ), Color.black, true)
	
	if show_scripts :
		for s in mapscriptareas :
#			print (s)
			var sp = mapscriptareas[s]
			var tl : Vector2 = Vector2( 32*sp["leftTopPoint"]['x'] , 32*sp["leftTopPoint"]['y'] )
			var sz : Vector2 = Vector2( 32*(sp["rightBotPoint"]['x']+1) , 32*(sp["rightBotPoint"]['y']+1) ) - tl
			var camoffset : Vector2 = Vector2(32*cam_x, 32*cam_y)
			var rect : Rect2 = Rect2(tl-camoffset, sz)
			draw_rect(rect, Color(1,0,0.8, 1), false, 2.0,false)
#			draw_string(font: Font, rect.position, s, Color( 1, 0, 0.8, 1 ), -1)

	return


# for some reason it didnt trigger
#func _on_MapMouseControlButton_toggled(button_pressed):
#	pressed = button_pressed
#	print('lol')


func _on_MapMouseControlButton_button_down():
	pressed = true


func _on_MapMouseControlButton_button_up():
	pressed = false


func _on_MapMouseControlButton_mouse_entered():
	mouseinside = true


func _on_MapMouseControlButton_mouse_exited():
	mouseinside = false
