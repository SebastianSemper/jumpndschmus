extends Spatial

var backward_collide: CollisionShape 
var backward_area: CollisionShape

func _ready():
	backward_collide = .get_node("StaticBody/CollisionShape2")
	backward_area = .get_node("Area/CollisionShape")

func block_path_back(position: Vector3):
	if backward_collide:
		if position.x - 1.2 > backward_area.global_transform.origin.x:
			backward_collide.disabled = false
	

func _on_Area_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	block_path_back(body.global_transform.origin)
