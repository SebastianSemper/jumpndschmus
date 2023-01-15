extends MarginContainer

signal start_game

func _ready():
	pass


func _on_Label_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		self.visible = false
		emit_signal("start_game")


func _on_Main_pause_game():
	self.visible = true
