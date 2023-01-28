extends Node
class_name SkinManager

var livingroom: RoomSkin = RoomSkin.new()
var kitchen: RoomSkin = RoomSkin.new()
var entrance: RoomSkin = RoomSkin.new()
var all_skins = [
	livingroom,
	kitchen,
	entrance
]
var obstacle_factory = ObstacleFactory.new()

func get_random_skin():
	return all_skins[randi() % (all_skins.size())]

func _ready():
	livingroom.init(
		load("res://gfx/livingroom/wallpaper.png"),
		load("res://gfx/livingroom/floor.png"),
		[
			WallDeco.new().init(load("res://gfx/livingroom/flat_1.png")),
			WallDeco.new().init(load("res://gfx/livingroom/flat_2.png")),
			WallDeco.new().init(load("res://gfx/livingroom/flat_3.png")),
			WallDeco.new().init(load("res://gfx/livingroom/flat_4.png")),
		],
		[
			Deco.new().init(load("res://gfx/livingroom/deco_1.png"), Vector3(1,1,0.2)),
			Deco.new().init(load("res://gfx/livingroom/obstacle_1.png"), Vector3(1,1,0.2)),
			Deco.new().init(load("res://gfx/livingroom/obstacle_2.png"), Vector3(1,1,0.6))
		],
		[
			obstacle_factory.make_obstacle(
				load("res://gfx/livingroom/obstacle_2.png")
			),
			obstacle_factory.make_obstacle(
				load("res://gfx/livingroom/obstacle_3.png")
			),
			obstacle_factory.make_obstacle(
				load("res://gfx/livingroom/deco_1.png")
			)
		]
	)
	kitchen.init(
		load("res://gfx/livingroom/wallpaper.png"),
		load("res://gfx/livingroom/floor.png"),
		[
			WallDeco.new().init(load("res://gfx/kitchen/flat_1.png")),
			WallDeco.new().init(load("res://gfx/kitchen/flat_2.png")),
		],
		[
			Deco.new().init(load("res://gfx/kitchen/obstacle_1.png"), Vector3(1,1,0.2)),
			Deco.new().init(load("res://gfx/kitchen/obstacle_1.png"), Vector3(1,1,0.2)),
			Deco.new().init(load("res://gfx/kitchen/obstacle_1.png"), Vector3(1,1,0.2)),
			Deco.new().init(load("res://gfx/kitchen/obstacle_1.png"), Vector3(1,1,0.2)),
			Deco.new().init(load("res://gfx/kitchen/deco_1.png"), Vector3(1,1,0.2)),
		],
		[
			obstacle_factory.make_obstacle(
				load("res://gfx/kitchen/obstacle_1.png")
			)
		]
	)
	entrance.init(
		load("res://gfx/livingroom/wallpaper.png"),
		load("res://gfx/livingroom/floor.png"),
		[
			WallDeco.new().init(load("res://gfx/entrance/flat_1.png")),
		],
		[
			Deco.new().init(load("res://gfx/entrance/deco_1.png"), Vector3(1,1,0.2)),
		],
		[
			obstacle_factory.make_obstacle(
				load("res://gfx/entrance/deco_1.png")
			)
		]
	)
