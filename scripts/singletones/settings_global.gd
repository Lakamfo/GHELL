extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_F11:
			OS.window_fullscreen = !OS.window_fullscreen
