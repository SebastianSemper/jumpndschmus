extends KinematicBody

var velocity = Vector3()

const gravity: float = 60.0

var jump_speed: float = 25.0

var move_speed: float = 10.0

var felix: AnimatedSprite3D
var rest_timer: Timer
var can_move = false

onready var sfx: AudioStreamPlayer = $sfx
var jump_sound: AudioStream = load("res://sfx/felix/jump.wav")
var rest_sounds: Array = [
	load("res://sfx/felix/rest_1.wav"),
	load("res://sfx/felix/rest_2.wav"),
]

enum flx_key {
	none,
	should_run_right,
	should_run_left,
	should_jump
}
var flx_curr_key = []

enum flx_phy {
	in_air,
	on_flr
}
var flx_curr_phy = flx_phy.in_air

enum flx_state {
	rst_left,
	rst_right,
	run_left,
	run_right,
	jmp_left,
	jmp_right,
	fll_left,
	fll_right,
}
var flx_curr_state = flx_state.rst_right

func _start_rest():
	var lambda = 1.0/5.0
	rest_timer.wait_time = -log(1 - rand_range(0,1))/lambda
	rest_timer.start()
	
func _on_rest_timer_timeout():
	if flx_curr_state == flx_state.rst_right or flx_curr_state == flx_state.rst_left:
		sfx.stream = rest_sounds[randi() % rest_sounds.size()]
		sfx.play()

func _start_rest_right():
	_start_rest()
	felix.play("rest_right")
var _start_rest_right_ref = funcref(self, "_start_rest_right")
func _start_rest_left():
	_start_rest()
	felix.play("rest_left")
var _start_rest_left_ref = funcref(self, "_start_rest_left")

func _start_jump():
	velocity.y += jump_speed
	sfx.stream = jump_sound
	sfx.play()

func _start_jump_left():
	_start_jump()
	felix.play("jump_left")
var _start_jump_left_ref = funcref(self, "_start_jump_left")

func _start_jump_right():
	_start_jump()
	felix.play("jump_right")
var _start_jump_right_ref = funcref(self, "_start_jump_right")

func _start_fall():
	pass
	
func _start_fall_right():
	_start_fall()
	felix.play("jump_right")
	felix.frame = 5
var _start_fall_right_ref = funcref(self, "_start_fall_right")

func _start_fall_left():
	_start_fall()
	felix.play("jump_left")
	felix.frame = 5
var _start_fall_left_ref = funcref(self, "_start_fall_left")

func _start_run_right():
	felix.play("run_right")
var _start_run_right_ref = funcref(self, "_start_run_right")

func _start_run_left():
	felix.play("run_left")
var _start_run_left_ref = funcref(self, "_start_run_left")

func _turn_air_left_right():
	var current_frame = felix.frame
	felix.play("jump_right")
	felix.frame = current_frame
var _turn_air_left_right_ref = funcref(self, "_turn_air_left_right")

func _turn_air_right_left():
	var current_frame = felix.frame
	felix.play("jump_left")
	felix.frame = current_frame
var _turn_air_right_left_ref = funcref(self, "_turn_air_right_left")

onready var transition_dict = {
	flx_state.rst_left: {
		flx_key.none: {
			flx_phy.on_flr: [flx_state.rst_left, null],
			flx_phy.in_air: [flx_state.rst_left, null],
		},
		flx_key.should_run_right: {
			flx_phy.on_flr: [flx_state.run_right, _start_run_right_ref],
			flx_phy.in_air: [flx_state.jmp_right, null],
		},
		flx_key.should_run_left: {
			flx_phy.on_flr: [flx_state.run_left, _start_run_left_ref],
			flx_phy.in_air: [flx_state.jmp_left, null],
		},
		flx_key.should_jump: {
			flx_phy.on_flr: [flx_state.jmp_left, _start_jump_left_ref],
			flx_phy.in_air: [flx_state.jmp_left, null],
		},
	},
	flx_state.rst_right: {
		flx_key.none: {
			flx_phy.on_flr: [flx_state.rst_right, null],
			flx_phy.in_air: [flx_state.rst_right, null],
		},
		flx_key.should_run_right: {
			flx_phy.on_flr: [flx_state.run_right, _start_run_right_ref],
			flx_phy.in_air: [flx_state.jmp_right, null],
		},
		flx_key.should_run_left: {
			flx_phy.on_flr: [flx_state.run_left, _start_run_left_ref],
			flx_phy.in_air: [flx_state.jmp_left, null],
		},
		flx_key.should_jump: {
			flx_phy.on_flr: [flx_state.jmp_right, _start_jump_right_ref],
			flx_phy.in_air: [flx_state.jmp_right, null],
		},
	},
	flx_state.run_left: {
		flx_key.none: {
			flx_phy.on_flr: [flx_state.rst_left, _start_rest_left_ref],
			flx_phy.in_air: [flx_state.rst_left, null],
		},
		flx_key.should_run_right: {
			flx_phy.on_flr: [flx_state.run_right, _start_run_right_ref],
			flx_phy.in_air: [flx_state.jmp_right, null],
		},
		flx_key.should_run_left: {
			flx_phy.on_flr: [flx_state.run_left, null],
			flx_phy.in_air: [flx_state.fll_left, _start_fall_left_ref],
		},
		flx_key.should_jump: {
			flx_phy.on_flr: [flx_state.jmp_left, _start_jump_left_ref],
			flx_phy.in_air: [flx_state.jmp_left, null],
		},
	},
	flx_state.run_right: {
		flx_key.none: {
			flx_phy.on_flr: [flx_state.rst_right, _start_rest_right_ref],
			flx_phy.in_air: [flx_state.rst_right, null],
		},
		flx_key.should_run_right: {
			flx_phy.on_flr: [flx_state.run_right, null],
			flx_phy.in_air: [flx_state.fll_right, _start_fall_right_ref],
		},
		flx_key.should_run_left: {
			flx_phy.on_flr: [flx_state.run_left, _start_run_left_ref],
			flx_phy.in_air: [flx_state.jmp_left, null],
		},
		flx_key.should_jump: {
			flx_phy.on_flr: [flx_state.jmp_right, _start_jump_right_ref],
			flx_phy.in_air: [flx_state.jmp_right, null],
		},
	},
	flx_state.jmp_left: {
		flx_key.none: {
			flx_phy.on_flr: [flx_state.rst_left, _start_rest_left_ref],
			flx_phy.in_air: [flx_state.jmp_left, null],
		},
		flx_key.should_run_right: {
			flx_phy.on_flr: [flx_state.run_right, _start_run_right_ref],
			flx_phy.in_air: [flx_state.jmp_right, _turn_air_left_right_ref],
		},
		flx_key.should_run_left: {
			flx_phy.on_flr: [flx_state.run_left, _start_run_left_ref],
			flx_phy.in_air: [flx_state.jmp_left, null],
		},
		flx_key.should_jump: {
			flx_phy.on_flr: [flx_state.jmp_left, _start_jump_left_ref],
			flx_phy.in_air: [flx_state.jmp_left, null],
		},
	},
	flx_state.jmp_right: {
		flx_key.none: {
			flx_phy.on_flr: [flx_state.rst_right, _start_rest_right_ref],
			flx_phy.in_air: [flx_state.jmp_right, null],
		},
		flx_key.should_run_right: {
			flx_phy.on_flr: [flx_state.run_right, _start_run_right_ref],
			flx_phy.in_air: [flx_state.jmp_right, null],
		},
		flx_key.should_run_left: {
			flx_phy.on_flr: [flx_state.run_left, _start_run_left_ref],
			flx_phy.in_air: [flx_state.jmp_left, _turn_air_right_left_ref],
		},
		flx_key.should_jump: {
			flx_phy.on_flr: [flx_state.jmp_right, _start_jump_right_ref],
			flx_phy.in_air: [flx_state.jmp_right, null],
		},
	},
	flx_state.fll_left: {
		flx_key.none: {
			flx_phy.on_flr: [flx_state.rst_left, _start_rest_left_ref],
			flx_phy.in_air: [flx_state.fll_left, null],
		},
		flx_key.should_run_right: {
			flx_phy.on_flr: [flx_state.run_right, _start_run_right_ref],
			flx_phy.in_air: [flx_state.fll_right, null],
		},
		flx_key.should_run_left: {
			flx_phy.on_flr: [flx_state.run_left, _start_run_left_ref],
			flx_phy.in_air: [flx_state.fll_left, _turn_air_right_left_ref],
		},
		flx_key.should_jump: {
			flx_phy.on_flr: [flx_state.jmp_right, _start_jump_right_ref],
			flx_phy.in_air: [flx_state.fll_right, null],
		},
	},
	flx_state.fll_right: {
		flx_key.none: {
			flx_phy.on_flr: [flx_state.rst_right, _start_rest_right_ref],
			flx_phy.in_air: [flx_state.fll_right, null],
		},
		flx_key.should_run_right: {
			flx_phy.on_flr: [flx_state.run_right, _start_run_right_ref],
			flx_phy.in_air: [flx_state.fll_right, null],
		},
		flx_key.should_run_left: {
			flx_phy.on_flr: [flx_state.run_left, _start_run_left_ref],
			flx_phy.in_air: [flx_state.fll_left, _turn_air_left_right_ref],
		},
		flx_key.should_jump: {
			flx_phy.on_flr: [flx_state.jmp_right, _start_jump_right_ref],
			flx_phy.in_air: [flx_state.fll_right, null],
		},
	},
}

# Called when the node enters the scene tree for the first time.
func _ready():
	felix = $sprite
	rest_timer = $rest_timer

func _collect_input():
	flx_curr_key = [flx_key.none]
	if Input.is_action_pressed("move_right"):
		flx_curr_key.append(flx_key.should_run_right)
	if Input.is_action_pressed("move_left"):
		flx_curr_key.append(flx_key.should_run_left)
	if Input.is_action_just_pressed("jump"):
		flx_curr_key.append(flx_key.should_jump)

func _process(delta):
	if can_move:
		_collect_input()
		_collect_phy()
		_felix_change_state()

func _collect_phy():
	if is_on_floor():
		flx_curr_phy = flx_phy.on_flr 
	else:
		flx_curr_phy = flx_phy.in_air

func _felix_change_state():
	var last_key = flx_curr_key.back()
	if transition_dict[flx_curr_state][last_key][flx_curr_phy][1] != null:
		transition_dict[flx_curr_state][last_key][flx_curr_phy][1].call_func()
	flx_curr_state = transition_dict[flx_curr_state][last_key][flx_curr_phy][0]
	
func _felix_animate():
	pass

func _physics_process(delta):
	velocity.x = 0
	if flx_curr_key.has(flx_key.should_run_right):
		velocity.x += move_speed

	if flx_curr_key.has(flx_key.should_run_left):
		velocity.x -= move_speed
		
	if flx_curr_phy == flx_phy.in_air:
		velocity.y -= gravity * delta
	else:
		if not flx_curr_key.back() == flx_key.should_jump:
			velocity.y = -0.1
	
	move_and_slide(velocity, Vector3(0,1,0))
	
