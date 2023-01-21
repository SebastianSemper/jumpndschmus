extends Control

var jump: TextureButton
var left: TextureButton
var right: TextureButton

onready var viewport_size: Vector2 = get_viewport().size

func _ready():
	jump = $jump
	left = $left
	right = $right
	
func _process(delta):
	viewport_size = get_viewport().size
	jump.rect_position.y = viewport_size.y - 100
	left.rect_position = viewport_size + Vector2(-200,-100)
	right.rect_position = viewport_size + Vector2(-100,-100)

func _on_jump_gui_input(event):
	if event is InputEventScreenTouch:			
		if event.pressed:
			Input.action_press("jump")
		else:
			Input.action_release("jump")

func _on_left_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			Input.action_press("move_left")
		else:
			Input.action_release("move_left")

func _on_right_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			Input.action_press("move_right")
		else:
			Input.action_release("move_right")
