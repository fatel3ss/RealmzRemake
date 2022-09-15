extends Button
## A character or other mobile scripted object on the overworld (out of combat)


var map = null
var tile_position_x = 0
var tile_position_y = 0

onready var sprite : Sprite = get_node("Sprite")


# Called when the node enters the scene tree for the first time.
func _ready():	
	# Player start Layer #
#	z_index = 4
	map = NodeAccess.__Map()
	move(Vector2(3,3))


func set_icon(icon : Texture) :
	sprite.texture = icon


# Game inputs #
#func _input(event):
#	if event is InputEventKey and event.pressed:
#		if event is InputEventKey and event.scancode == KEY_UP:
#			position.y -= Utils.GRID_SIZE
#			tile_position_y-=1
#		elif event is InputEventKey and event.scancode == KEY_DOWN:
#			position.y += Utils.GRID_SIZE
#			tile_position_y+=1
#		elif event is InputEventKey and event.scancode == KEY_RIGHT:
#			position.x += Utils.GRID_SIZE
#			tile_position_x+=1
#		elif event is InputEventKey and event.scancode == KEY_LEFT:
#			position.x -= Utils.GRID_SIZE
#			tile_position_x-=1
#		if self==map.focuscharacter :
#			map.update()

func move(dir : Vector2) :
	rect_position  = rect_position  + Utils.GRID_SIZE * dir
	tile_position_x += dir.x
	tile_position_y += dir.y
	if dir.x<0 :
		sprite.set_flip_h(false)
	if dir.x>0 :
		sprite.set_flip_h(true) 
	if self==map.focuscharacter :
		map.update()
	
#func _process(delta):
#	pass
#
#func on_thing_enter():
#	pass
#
#func on_thing_leave():
#	pass

func get_pixel_position()->Vector2 :
	return rect_position
