extends Control

var jump: TextureButton
var left: TextureButton
var right: TextureButton
var pause: TextureButton

onready var viewport_size: Vector2 = get_viewport().size

func _ready():
	jump = $jump
	left = $left
	right = $right
	pause = $pause
	
func _process(_delta):
	if not visible: 
		return
	viewport_size = get_viewport().size
	jump.rect_position.y = viewport_size.y - 100
	left.rect_position = viewport_size + Vector2(-200,-100)
	right.rect_position = viewport_size + Vector2(-100,-100)
	pause.rect_position.x = viewport_size.x - 80
	
	
	if not jump.pressed:
		Input.action_release("jump")
	if not left.pressed:
		Input.action_release("move_left")
	if not right.pressed:
		Input.action_release("move_right")
	

func _on_jump_gui_input(event: InputEvent):
	if not visible: 
		return
	
	if (event is InputEventScreenTouch):
		if event.pressed:
			Input.action_press("jump")
		else:
			Input.action_release("jump")
	elif event is InputEventScreenDrag:
		Input.action_press("jump")

func _on_left_gui_input(event: InputEvent):
	if not visible: 
		return
		
	if (event is InputEventScreenTouch):
		if event.pressed:
			Input.action_press("move_left")
		else:
			Input.action_release("move_left")
	elif event is InputEventScreenDrag:
		Input.action_press("move_left")

func _on_right_gui_input(event: InputEvent):
	if not visible: 
		return
		
	if event is InputEventScreenTouch:
		if event.pressed:
			Input.action_press("move_right")
		else:
			Input.action_release("move_right")


func _on_pause_gui_input(event: InputEvent):
	if not visible: 
		return
		
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		Input.action_press("key_pause")
