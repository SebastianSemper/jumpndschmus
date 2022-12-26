extends Object
class_name Deco

var texture_res: StreamTexture
var size: Vector3
var position: Vector3
var material: SpatialMaterial
var extent: Vector3

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

func make_object():
	var deco = MeshInstance.new()
		
	deco.mesh = CubeMesh.new()
	_put_texture_on_front(deco)
	deco.scale = Vector3(extent.x, extent.y, 1)
	deco.set_surface_material(0, material)
	
	deco.translation = Vector3(0, extent.y, extent.z + 0.1)
	
	return deco
	
func init(_texture_res, _size=Vector3(1,1,1), _position=Vector3(0,0,0)):
	texture_res = _texture_res
	size = _size
	position = _position
	
	material = SpatialMaterial.new()
	material.albedo_texture = texture_res
	
	extent = Vector3(
		2.5 * texture_res.get_width()/256 * size.x,
		2.5 * texture_res.get_height()/256 * size.y,
		size.z
	)
	
	return self
	
