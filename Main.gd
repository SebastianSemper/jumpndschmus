extends Spatial

var mapped_range = 0.0
var explored_range = 0.0
var room_list = []
var room_builder: RoomBuilder
var game_started = false

export var debug = true

onready var debug_explored = .get_node("debug/explored")
onready var debug_rooms = .get_node("debug/rooms")
onready var debug_state = .get_node("debug/state")
onready var debug_phys = .get_node("debug/phys")


# Called when the node enters the scene tree for the first time.
func _ready():
	room_builder = RoomBuilder.new()
	add_child(room_builder)
	room_builder.player = $Player
	
	var zeroth_room = room_builder.build_room(true)
	add_child(zeroth_room)
	room_list.append(zeroth_room)
	
	var first_room = room_builder.build_room(true)
	zeroth_room.translation.x = - (first_room.width + zeroth_room.width)/2
	add_child(first_room)
	room_list.append(first_room)
	mapped_range += first_room.width / 2
	
	_setup_debug()
	
func _setup_debug():
	$debug.visible = debug
	$Menu.visible = !debug
	$Player.can_move = debug
	$music.playing = !debug

func add_new_room():
	var room = room_builder.build_room(false)
	room.translation = Vector3(mapped_range + room.width/2, 0, 0)
	add_child(room)
	room_list.append(room)
	mapped_range += room.width

func rem_old_room():
	room_list.pop_front().queue_free()
	
func new_room_needed():
	return mapped_range < explored_range + room_list.back().width

func _process(delta):
	explored_range = max(explored_range, $Player.translation.x)
	
	if new_room_needed():
		add_new_room()
		if room_list.size() > 4:
			rem_old_room()
	
	if debug:
		debug_explored.text = str(explored_range)
		debug_rooms.text = str(room_list.size())
		debug_state.text = str($Player.flx_curr_state)
		debug_phys.text = str($Player.flx_curr_phy)


func _on_Container_start_game():
	$Player.can_move = true
