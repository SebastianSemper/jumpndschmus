extends Spatial
class_name HouseRoom 

var width: float
var skin: RoomSkin

var _floor_deco_params: Array

func add_floor_deco(start: float, end: float, height: float):
	_floor_deco_params.append(Vector3(start, end, height))

func floor_deco_height(x: float):
	for pp in _floor_deco_params:
		if x > pp.x:
			if x < pp.y:
				return pp.z
	return 0
	
func _ready():
	pass

