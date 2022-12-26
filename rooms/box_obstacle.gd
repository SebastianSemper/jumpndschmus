extends Obstacle
class_name BoxObstacle

var texture_res: StreamTexture
var extent: Vector3
var material: SpatialMaterial

func _ready():
	pass

func _put_texture_on_front(input_obj):
	var mdt = MeshDataTool.new()
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES, input_obj.mesh.get_mesh_arrays()
	)
	mdt.create_from_surface(mesh, 0)
	for ii in range(mdt.get_vertex_count()):
		var vtx = mdt.get_vertex(ii)
		mdt.set_vertex_uv(ii, Vector2(vtx.x/2+0.5, (-vtx.y/2+0.5)))
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	input_obj.mesh = mesh

func make_object() -> StaticBody:
	var obst_collision = StaticBody.new()
	var obst_shape = BoxShape.new()
	obst_shape.extents = Vector3(extent.x, extent.y, 1)
	var obst_collision_shape = CollisionShape.new()
	obst_collision_shape.shape = obst_shape
	obst_collision.add_child(obst_collision_shape)
	
	var obst = MeshInstance.new()
	obst_collision.add_child(obst)
	
	obst.mesh = CubeMesh.new()
	_put_texture_on_front(obst)
	obst.scale = Vector3(extent.x, extent.y, 1)
	obst.set_surface_material(0, material)
	
	obst_collision.translation = Vector3(0, extent.y, extent.z + 0.1)
	
	return obst_collision

func init(ressource: StreamTexture):
	._init()
	texture_res = ressource
	
	material = SpatialMaterial.new()
	material.albedo_texture = texture_res
	
	extent = Vector3(
		2.5 * texture_res.get_width()/256,
		2.5 * texture_res.get_height()/256,
		1
	)
	
	return self
