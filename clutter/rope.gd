extends Spatial
class_name Rope

var _min_length:float = 1.0
var _min_num_parts:int = 3

var _has_init: bool = false

var length: float
var num_parts: int
var parts: Array
var faces: MeshInstance

var player

var passes = 8
var gravity: Vector3 = Vector3(0, -8, 0) 

func _ready():
	pass
	
func _process(_delta):
	if not _has_init:
		return
	
	for ii in passes:
		for pp in parts:
			pp.relax(passes)
	
	_update_face_mesh()
	
func _update_face_mesh():
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(faces.mesh, 0)
	for pp in range(parts.size()-1):
		var direction = parts[pp+1].translation - parts[pp].translation
		var shift = direction.cross(Vector3(0,0,-1)).normalized()
		mdt.set_vertex(
			6 * pp,
			parts[pp].translation - 0.05 * shift
		)
		mdt.set_vertex(
			6 * pp + 1,
			parts[pp].translation + 0.05 * shift
		)
		mdt.set_vertex(
			6 * pp + 2,
			parts[pp + 1].translation - 0.05 * shift
		)
		mdt.set_vertex(
			6 * pp + 3,
			parts[pp].translation + 0.05 * shift
		)
		mdt.set_vertex(
			6 * pp + 4,
			parts[pp+1].translation + 0.05 * shift
		)
		mdt.set_vertex(
			6 * pp + 5,
			parts[pp + 1].translation - 0.05 * shift
		)
	faces.mesh.surface_remove(0)
	mdt.commit_to_surface(faces.mesh)
	
func _make_face_mesh() -> MeshInstance:
	var result = MeshInstance.new()
	var result_mesh = Mesh.new()
	var mat = SpatialMaterial.new()
	mat.albedo_color = Color(0.8, 0.6, 0.5)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	for pp in range(parts.size()-1):
		st.add_vertex(parts[pp].translation + Vector3(-0.05, 0, 0))
		st.add_vertex(parts[pp].translation + Vector3(+0.05, 0, 0))
		st.add_vertex(parts[pp+1].translation + Vector3(+0.05, 0, 0))
		
		st.add_vertex(parts[pp].translation + Vector3(-0.05, 0, 0))
		st.add_vertex(parts[pp+1].translation + Vector3(+0.05, 0, 0))
		st.add_vertex(parts[pp+1].translation + Vector3(-0.05, 0, 0))
	st.commit(result_mesh)
	result.mesh = result_mesh
	
	return result
	
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
	
	faces = _make_face_mesh()
	add_child(faces)
	return self

	

	
