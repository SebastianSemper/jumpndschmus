extends Object
class_name ObstacleFactory

func make_obstacle(ressource):
	var obstacle: Obstacle
	if ressource is StreamTexture:
		obstacle = BoxObstacle.new().init(ressource)
		
	return obstacle
		

func _ready():
	pass
