extends Spatial

var mapped_range = 0.0
var explored_range = 0.0

var room_list: Array = []

var room_builder: RoomBuilder

var last_room_check: float = 0
var room_check_intervall: float = 1

onready var player
var player_start_pos: Vector3

export var debug: bool = true
export var mobile: bool = true

onready var debug_explored = .get_node("debug/explored")
onready var debug_rooms = .get_node("debug/rooms")
onready var debug_state = .get_node("debug/state")
onready var debug_phys = .get_node("debug/phys")

var game_running = false
signal pause_game

func _ready():
	room_builder = RoomBuilder.new()
	add_child(room_builder)
	room_builder.hang_ropes = false
	player = $Player
	room_builder.player = player
	player_start_pos = player.translation
	
	if mobile:
		$Camera.translation.z *= 0.8
	
	_setup_debug()
	
	if debug:
		_start_fresh()

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
	
	game_running = true
	player.can_move = true

func _stop_game():
	
	game_running = false
	player.can_move = false

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
	if room_list.empty():
		return true
	return mapped_range < explored_range + room_list.back().width

func manage_rooms(delta: float):
	last_room_check += delta
	if last_room_check > room_check_intervall:
		if new_room_needed():
			prune_old_rooms()
			add_new_room()
		last_room_check = 0

func _process(delta: float):
	explored_range = max(explored_range, player.translation.x)
	
	$Camera.translation.x = player.translation.x
	
	manage_rooms(delta)
	
	if debug:
		_update_debug()
		
	if Input.is_action_just_pressed("key_pause"):
		if not game_running:
			_on_Menu_end_game()
		else:
			emit_signal("pause_game")

func _on_Menu_start_game():
	$blend._start_fade_in()
	_start_fresh()
	
	
func _on_Main_pause_game():
	$blend._start_fade_in()
	
	_stop_game()
	
func _on_blend_fade_in_done():
	$Menu.visible = not $Menu.visible
	$Controls.visible = (not $Controls.visible) and mobile


func _on_Main_ready():
	$blend._start_fade_out(4000)


func _on_Menu_end_game():
	get_tree().quit()


func _on_music_finished():
	$music.play()
