extends Node2D

export var default_fade_time: float = 1000.0
var fade_time: float
onready var viewport_size: Vector2 = get_viewport().size
onready var rect: Polygon2D
var _fade_in_start: float
var _fading_in: bool = false

var _fade_out_start: float
var _fading_out: bool = false

signal fade_in_done

# Called when the node enters the scene tree for the first time.
func _ready():
	rect = $rect
	rect.color.a = 1
	
func _start_fade_out(_fade_time=null):
	if _fading_out:
		return
	if not _fade_time:
		fade_time = default_fade_time
	else:
		fade_time = _fade_time
	
	rect.color.a = 0
	_fade_out_start = OS.get_ticks_msec()
	_fading_out = true

func _start_fade_in(_fade_time=null):
	if _fading_in:
		return
		
	if not _fade_time:
		fade_time = default_fade_time
	else:
		fade_time = _fade_time
	
	rect.color.a = 1
	_fade_in_start = OS.get_ticks_msec()
	_fading_in = true

func _process(_delta):
	viewport_size = get_viewport().size
	rect.polygon[0] = Vector2(0,0)
	rect.polygon[1] = Vector2(viewport_size.x, 0)
	rect.polygon[2] = viewport_size
	rect.polygon[3] = Vector2(0, viewport_size.y)
	
	if _fading_in:
		var _fade_in_time = (OS.get_ticks_msec() - _fade_in_start)
		if _fade_in_time >= fade_time:
			_fading_in = false
			emit_signal("fade_in_done")
			_start_fade_out()
		else:
			rect.color.a = _fade_in_time/fade_time
	
	if _fading_out:
		var _fade_out_time = (OS.get_ticks_msec() - _fade_out_start)
		if _fade_out_time >= fade_time:
			_fading_out = false
		else:
			rect.color.a = 1 - _fade_out_time/fade_time
	
