extends MarginContainer

signal start_game
signal end_game

func _ready():
	pass


func _on_Label_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		emit_signal("start_game")

func _on_Label3_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		emit_signal("end_game")
