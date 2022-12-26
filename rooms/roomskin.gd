extends Node
class_name RoomSkin

var wall_material: SpatialMaterial
var floor_material: SpatialMaterial

var wall_sprites: Array
var deco_fronts: Array
var obstacles: Array

func _ready():
	pass
	
func get_random_deco():
	return deco_fronts[randi() % deco_fronts.size()]

func get_random_wall_deco() -> WallDeco:
	return wall_sprites[randi() % wall_sprites.size()]
	
func get_random_obstacle():
	return obstacles[randi() % obstacles.size()]

func init(_wall_image, _floor_image, _wall_sprites, _deco_fronts, _obstacles):
	wall_material = SpatialMaterial.new()
	wall_material.albedo_texture = _wall_image
	wall_material.albedo_texture.flags = 10
	
	floor_material = SpatialMaterial.new()
	floor_material.albedo_texture = _floor_image
	floor_material.albedo_texture.flags = 10
	
	wall_sprites = _wall_sprites
	deco_fronts = _deco_fronts
	obstacles = _obstacles
	
	return self
