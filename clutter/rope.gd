extends Spatial
class_name Rope

var _min_length:float = 1.0
var _min_num_parts:int = 3

var _has_init: bool = false

var length: float
var num_parts: int
var parts: Array
var faces: MeshInstance
var faces_subdiv = 5
var diameter = 0.15
var face_texture = load("res://clutter/rope_texture.png")

var mesh_update_step: int = 0
var mesh_update_max: int = 1

var player

var passes = 10
var gravity: Vector3 = Vector3(0, -8, 0) 

func _ready():
	pass
	
func _process(_delta):
	if not _has_init:
		return
	
	for ii in passes:
		for pp in parts:
			pp.relax(passes)
			
	if _is_in_view():
		mesh_update_step = (mesh_update_step + 1) % mesh_update_max
		_update_face_mesh(mesh_update_step)

func _is_in_view():
	var camera:Camera = get_viewport().get_camera()
	var camera_pos: Vector3 = camera.global_transform.origin
	var own_pos: Vector3 = self.global_transform.origin
	var z_dist = camera_pos.z - own_pos.z
	var viewport_size: Vector2 = get_viewport().size
	var aspect = viewport_size.x / viewport_size.y
	var horizontal_angle = atan(aspect * tan(deg2rad(camera.fov / 2)))
	
	return 0.8 * abs(camera_pos.x - own_pos.x) < z_dist * tan(horizontal_angle)

func _update_face_mesh(step):
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(faces.mesh, 0)
	var direction: Vector3
	var shift_a: Vector3
	var shift_b: Vector3
	var angle: float
	var cos_angle: float
	var cos_angle_next: float
	var sin_angle_next: float
	var sin_angle: float
	var ind_face: int
	var start = step * int(float(parts.size()) / mesh_update_max)
	var end = min(
		(step + 1) * int(float(parts.size()) / mesh_update_max),
		parts.size()-1
	)
	for pp in range(start, end):
		var this = parts[pp]
		var next = parts[pp].child
		if not next:
			return
		direction =  (next.translation - this.translation).normalized()
		shift_b = Vector3(0,0,-1).normalized()
		shift_a = direction.cross(shift_b).normalized()
		
		for rr in range(faces_subdiv):
			angle = rr * (2 * PI) / faces_subdiv
			
			cos_angle = 0.5 * diameter * cos(angle)
			sin_angle = 0.5 * diameter * sin(angle)
			
			cos_angle_next = 0.5 * diameter * cos(angle + (2 * PI) / faces_subdiv)
			sin_angle_next = 0.5 * diameter * sin(angle + (2 * PI) / faces_subdiv)
			
			ind_face = 6 * faces_subdiv * pp + 6 * rr
			
			mdt.set_vertex(
				ind_face,
				this.translation + cos_angle * shift_a + sin_angle * shift_b
			)
			mdt.set_vertex(
				ind_face + 1,
				this.translation + cos_angle_next * shift_a + sin_angle_next * shift_b
			)
			mdt.set_vertex(
				ind_face + 2,
				next.translation + cos_angle_next * shift_a + sin_angle_next * shift_b
			)
			mdt.set_vertex(
				ind_face + 3,
				this.translation + cos_angle * shift_a + sin_angle * shift_b
			)
			mdt.set_vertex(
				ind_face + 4,
				next.translation + cos_angle_next * shift_a + sin_angle_next * shift_b
			)
			mdt.set_vertex(
				ind_face + 5,
				next.translation + cos_angle * shift_a + sin_angle * shift_b
			)
#		
	faces.mesh.surface_remove(0)
	mdt.commit_to_surface(faces.mesh)
	
func _make_face_mesh() -> MeshInstance:
	var result = MeshInstance.new()
	var result_mesh = Mesh.new()
	var mat = SpatialMaterial.new()
	mat.albedo_texture = face_texture
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	for pp in range(parts.size()-1):
		for rr in range(faces_subdiv):
			st.add_uv(Vector2(float(rr)/faces_subdiv, 0))
			st.add_vertex(parts[pp].translation + Vector3(-0.05, 0, 0))
			st.add_uv(Vector2(float(rr+1)/faces_subdiv, 0))
			st.add_vertex(parts[pp].translation + Vector3(+0.05, 0, 0))
			st.add_uv(Vector2(float(rr+1)/faces_subdiv, 1.0))
			st.add_vertex(parts[pp+1].translation + Vector3(+0.05, 0, 0))
			
			st.add_uv(Vector2(float(rr)/faces_subdiv, 0))
			st.add_vertex(parts[pp].translation + Vector3(-0.05, 0, 0))
			st.add_uv(Vector2(float(rr+1)/faces_subdiv, 1))
			st.add_vertex(parts[pp+1].translation + Vector3(+0.05, 0, 0))
			st.add_uv(Vector2(float(rr)/faces_subdiv, 1))
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
			diameter,
			distance
		)
		
		parts.append(new_part)
		
		self.add_child(new_part)
	
	faces = _make_face_mesh()
	add_child(faces)
	return self

	

	
