extends Spatial

var mapped_range = 0.0
var explored_range = 0.0

var room_list: Array = []

var room_builder: RoomBuilder

var last_room_check: float = 0
var room_check_intervall: float = 5

var game_running: bool = false

onready var player
var player_start_pos: Vector3

export var debug: bool = true
export var mobile: bool = true

onready var debug_explored = .get_node("debug/explored")
onready var debug_rooms = .get_node("debug/rooms")
onready var debug_state = .get_node("debug/state")
onready var debug_phys = .get_node("debug/phys")

signal pause_game

func _ready():
	room_builder = RoomBuilder.new()
	add_child(room_builder)
	room_builder.hang_ropes = !mobile
	player = $Player
	room_builder.player = player
	player_start_pos = player.translation
	
	_setup_debug()
	
	if debug:
		_start_fresh()
		game_running = true

func _start_fresh():
	if room_list.size():
		for rr in room_list.size():
			room_list.pop_back().queue_free()
		
	var zeroth_room = room_builder.build_room(true)
	add_child(zeroth_room)
	room_list.append(zeroth_room)
	
	var first_room = room_builder.build_room(true)
	zeroth_room.translation.x = - (first_room.width + zeroth_room.width)/2
	add_child(first_room)
	room_list.append(first_room)
	
	mapped_range = first_room.width / 2
	explored_range = 0
	
	last_room_check = room_check_intervall
	
	player.translation = player_start_pos


func _setup_debug():
	$debug.visible = debug
	$Menu.visible = !debug
	player.can_move = debug
	$music.playing = !debug
	$Controls.visible = debug
	
func _update_debug():
	debug_explored.text = str(explored_range)
	debug_rooms.text = str(room_list.size())
	debug_state.text = str(player.flx_curr_state)
	debug_phys.text = str(player.flx_curr_phy)

func add_new_room():
	var room = room_builder.build_room(false)
	room.translation = Vector3(mapped_range + room.width/2, 0, 0)
	add_child(room)
	room_list.append(room)
	mapped_range += room.width

func prune_old_rooms():
	if room_list.size() > 4:
		room_list.pop_front().queue_free()
	
func new_room_needed():
	return mapped_range < explored_range + room_list.back().width

func manage_rooms(delta: float):
	last_room_check += delta
	if last_room_check > room_check_intervall:
		if new_room_needed():
			prune_old_rooms()
			add_new_room()
		last_room_check = 0

func _process(delta: float):
	if not game_running:
		return 
		
	explored_range = max(explored_range, player.translation.x)
	
	$Camera.translation.x = player.translation.x
	
	manage_rooms(delta)
	
	if debug:
		_update_debug()
		
	if Input.is_action_pressed("key_pause"):
		emit_signal("pause_game")

func _on_Menu_start_game():
	$blend._start_fade_in()
	_start_fresh()
	
	player.can_move = true
	game_running = true


func _on_Main_pause_game():
	$blend._start_fade_in()
	
	player.can_move = false
	game_running = false


func _on_blend_fade_in_done():
	$Menu.visible = not $Menu.visible
	$Controls.visible = not $Controls.visible


func _on_Main_ready():
	$blend._start_fade_out(4000)


func _on_Menu_end_game():
	get_tree().quit()
