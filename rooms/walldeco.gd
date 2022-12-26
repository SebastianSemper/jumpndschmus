extends Object
class_name WallDeco

var ressource
var extent: Vector2

func _ready():
	pass
	
func make_object() -> Sprite3D:
	var obj: Sprite3D = Sprite3D.new()
	obj.texture = ressource
	obj.shaded = true
	return obj
	
func init(_ressource: StreamTexture):
	ressource = _ressource
	extent = ressource.get_size() * 0.01
	return self
