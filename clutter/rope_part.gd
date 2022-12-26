extends KinematicBody
class_name RopePart

var rope
var parent: RopePart
var child: RopePart = null

var _should_init: bool = true
var _init_pos: Vector3
var distance: float
var velocity: Vector3 = Vector3(0,0,0)
var past: Array
var time_index = 0
var diff = Vector3(0,0,0)

var face: MeshInstance

func _ready():
	move_lock_z = true
	
	
func init(_rope, _parent: RopePart, _initial_pos: Vector3, _diameter: float, _distance: float) -> RopePart:
	rope = _rope
	parent = _parent
	
	if parent:
		parent.set_child(self)
		
	distance = _distance
	
	translation = _initial_pos
	past.append(_initial_pos)
	past.append(_initial_pos)
	
	var area = Area.new()
	var shape = BoxShape.new()
	shape.extents = Vector3(_diameter/2, _diameter/2, _diameter/2)
	
	var coll:CollisionShape = CollisionShape.new()
	coll.shape = shape
	area.add_child(coll)
	self.add_child(area)
	
	area.connect("body_shape_entered", self, "_ping")
	
	return self
	

func _ping(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int):
	if body == rope.player:
		diff += 0.02 * body.velocity - (translation - past[time_index])

func relax(passes):
	if not parent:
		return
	var to_parent: Vector3 = parent.translation - translation
	var current_distance = to_parent.length()
	var correction_length = (current_distance - distance) / passes
	var correction_direction = to_parent.normalized()
	translation += correction_length * correction_direction
	if parent.parent:
		parent.translation -= correction_length * correction_direction

func _process(_delta):
	_update_face()

func _update_face():
	pass
	
func _physics_process(delta):
	if not parent:
		return 
	
	past[time_index % 2] = translation
	
	diff += (
		2 * translation 
		- past[(time_index + 1) % 2]
		+ delta * delta * rope.gravity
	) - translation
	if (translation + diff).y > 0:
		diff.y *= -1 
		
	translation += diff
	
	diff = Vector3(0,0,0)
	
	time_index = (time_index + 1) % 2

func set_child(_child: RopePart):
	child = _child
