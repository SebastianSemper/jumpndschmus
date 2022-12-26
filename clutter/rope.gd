extends Spatial
class_name Rope

var _min_length:float = 1.0
var _min_num_parts:int = 3

var _has_init: bool = false

var length: float
var num_parts: int
var parts: Array

var player

var passes = 5
var gravity: Vector3 = Vector3(0, -5, 0) 

func _ready():
	pass
	
func _process(delta):
	if not _has_init:
		return
	
	for ii in passes:
		for pp in parts:
			pp.relax(passes)
	
func init(_player, _length: float, _num_parts: int) -> Rope:
	player = _player
	length = max(_min_length, _length)
	num_parts = int(max(_min_num_parts, _num_parts))
	_has_init = true
	
	var distance = length / num_parts
	var angle = rand_range(-30.0 / 180 * PI, +30.0 / 180 * PI)
	var diff_x = sin(angle) * distance
	var diff_y = -cos(angle) * distance
	
	for pp in num_parts:
		var new_part = RopePart.new()
		var parent: RopePart
		if pp > 0:
			parent = parts.back()
		else:
			parent = null
			
		new_part = new_part.init(
			self, 
			parent, 
			Vector3(float(pp) * diff_x, float(pp) * diff_y, 0),
			0.1,
			distance
		)
		
		parts.append(new_part)
		
		self.add_child(new_part)
	

	return self

	

	
