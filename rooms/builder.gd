extends Spatial
class_name RoomBuilder

const HouseRoom = preload("res://rooms/houseroom.gd")
var door_scene = preload("res://rooms/door_wall.tscn")
var rope_scene = preload("res://clutter/rope.tscn")

var skins: SkinManager

var room_depth = 20.0
var room_height = 15.0
var deco_buffer: float = .25 
var wall_deco_buffer = 0.5
var player

var obstacle_buffer = 1.5
var obstacle_distance = 10
var obstacle_min_distance = 5

var hang_ropes = false
var rope_buffer = 1.5
var rope_distance = 15.0
var rope_min_distance = 8.0

func _ready():
	skins = SkinManager.new()
	add_child(skins)

func build_room(is_first_room=false):
	randomize()
	var room = HouseRoom.new()
	room.skin = skins.get_random_skin()
	
	var width = rand_range(30, 60)
	room.width = width
	
	var floor_obj = MeshInstance.new()
	room.add_child(floor_obj)
	var floor_mesh = QuadMesh.new()
	floor_mesh.size = Vector2(width, room_depth)
	floor_obj.mesh = floor_mesh
	floor_obj.set_rotation_degrees(Vector3(-90,0,0))
	floor_obj.set_translation(Vector3(0,0, room_depth/2))
	_scale_plane_uv(floor_obj, 0.25, 0.25)
	
	var floor_collision = StaticBody.new()
	var floor_shape = BoxShape.new()
	floor_shape.extents = Vector3(width/2, 0, room_depth)
	var floor_collision_shape = CollisionShape.new()
	floor_collision_shape.shape = floor_shape
	floor_collision.add_child(floor_collision_shape)
	room.add_child(floor_collision)
	
	var wall_obj = MeshInstance.new()
	room.add_child(wall_obj)
	var wall_mesh = QuadMesh.new()
	wall_mesh.size = Vector2(width, room_height)
	wall_obj.set_translation(Vector3(0, room_height/2.0, 0))
	wall_obj.mesh = wall_mesh
	_scale_plane_uv(wall_obj, 0.5, 0.5)
	
	var ceil_obj = MeshInstance.new()
	room.add_child(ceil_obj)
	var ceil_mesh = QuadMesh.new()
	ceil_mesh.size = Vector2(width, room_depth)
	ceil_obj.set_rotation_degrees(Vector3(90,0,0))
	ceil_obj.set_translation(Vector3(0, room_height, 0))
	ceil_obj.mesh = ceil_mesh
	_scale_plane_uv(ceil_obj, 0.5, 0.5)
	
	_add_door_to(room, width/2)
	
	if is_first_room:
		_add_door_to(room, -width/2, true)
	
	wall_obj.set_surface_material(0, room.skin.wall_material)
	wall_obj.material_override = room.skin.wall_material
	floor_obj.set_surface_material(0, room.skin.floor_material)
	ceil_obj.set_surface_material(0, room.skin.wall_material)
	
	add_deco_to(room)
	_add_wall_sprites_to(room)
	
	if !is_first_room:
		add_obstacles_to(room)
		
	if !is_first_room and hang_ropes:
		_add_ropes_to(room, player)
	
	return room

func _add_door_to(room, pos_x, block=false):
	var door = door_scene.instance()
	door.translation = Vector3(pos_x, 0, 0)
	room.add_child(door)
	if block:
		door.block_path_back(Vector3(pos_x+10, 0, 0))

func _add_wall_sprites_to(room):
	var decorated_length = 0
	while decorated_length < room.width - wall_deco_buffer:
		var flat_res: WallDeco = room.skin.get_random_wall_deco()
		var flat_obj: Sprite3D = flat_res.make_object()
		
		if decorated_length == 0:
			decorated_length += wall_deco_buffer
		
		var shift_x = rand_range(4,12)
		decorated_length += shift_x + flat_res.extent.x / 2
		
		var hanging_height = rand_range(
			max(
				room.floor_deco_height(decorated_length - room.width/2 - flat_res.extent.x/2),
				room.floor_deco_height(decorated_length - room.width/2 + flat_res.extent.x/2)
			) + flat_res.extent.y + rand_range(0.2,1),
			room_height - flat_res.extent.y
		)
		flat_obj.set_translation(
			Vector3(
				decorated_length - room.width/2,
				hanging_height,
				0.01 
			)
		)
		decorated_length += flat_res.extent.x / 2
		if decorated_length > room.width - wall_deco_buffer:
			return
		else:
			room.add_child(flat_obj)

		
func add_deco_to(room: HouseRoom):
	var decorated_length = 0
	while decorated_length < room.width - deco_buffer:
		var deco_res = room.skin.get_random_deco()
		var deco = deco_res.make_object()
		if decorated_length == 0:
			decorated_length += deco_buffer + deco_res.extent.x
			
		decorated_length += deco_res.extent.x
		
		deco.translation.x = decorated_length - room.width/2
		
		var shift_x = rand_range(
			3,
			8
		)
		
		deco.translation.x += shift_x
		
		decorated_length += shift_x + deco_res.extent.x
		if decorated_length < room.width - deco_buffer:
			room.add_child(deco)
			room.add_floor_deco(
				deco.translation.x - deco_res.extent.x,
				deco.translation.x + deco_res.extent.x, 
				deco_res.extent.y
			)
		else: 
			return

func add_obstacles_to(room: HouseRoom):
	var obstacled_range: float = obstacle_buffer 
	while obstacled_range < room.width:
		var obst: Obstacle = room.skin.get_random_obstacle()
		
		var shift_x = -log(1 - rand_range(0,1)) * obstacle_distance + obstacle_min_distance
		print(shift_x)
		var pos_x: float = -room.width/2 + obstacled_range + shift_x
		
		if pos_x + obst.extent.x > room.width/2 - obstacle_buffer:
			return
		
		var obj: StaticBody = obst.make_object()
		obj.translation.x = pos_x
		obj.translation.z = 5
		room.add_child(obj)
		room.add_obstacle(
			obj.translation.x - obst.extent.x - 5,
			obj.translation.x + obst.extent.x + 5, 
			2 * obst.extent.y
		)
		
		obstacled_range += shift_x + obst.extent.x + obstacle_min_distance
	
func _add_ropes_to(room: HouseRoom, _player):
	
	var roped_range: float = rope_buffer
	while roped_range < room.width:
		var shift_x: float = max(
			rope_min_distance,
			-log(1 - rand_range(0,1)) * rope_distance
		)
		var pos_x: float = -room.width/2 + roped_range + shift_x
		if pos_x > room.width/2 - rope_buffer:
			return
		
		var length: float = room_height - room.obstacles_height(pos_x) - 3
		var rope: Rope = rope_scene.instance().init(
			_player,
			length,
			ceil(1.5 * length)
		)
		
		rope.translation += Vector3(
			pos_x,
			room_height,
			5.0
		)
		print("ROPE", pos_x)
		room.add_child(rope)
		roped_range += shift_x
	
func _scale_plane_uv(input_obj, scale_u, scale_v):
	var mdt = MeshDataTool.new()
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES, input_obj.mesh.get_mesh_arrays()
	)
	mdt.create_from_surface(mesh, 0)
	for ii in range(mdt.get_vertex_count()):
		var vtx = mdt.get_vertex(ii)
		mdt.set_vertex_uv(ii, Vector2(scale_u * vtx.x, scale_v * vtx.y))
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	input_obj.mesh = mesh
