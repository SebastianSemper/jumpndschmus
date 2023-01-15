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
	obj.pixel_size *= 4
	return obj
	
func init(_ressource: StreamTexture):
	ressource = _ressource
	return self
