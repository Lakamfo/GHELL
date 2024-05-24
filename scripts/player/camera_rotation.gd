extends Spatial

export var mouse_sensitivity = 0.01
export var smoothness = 30

var camera_input : Vector2 
var rotation_velocity : Vector2

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		camera_input = event.relative

func _process(delta: float) -> void:
	rotation_velocity = rotation_velocity.linear_interpolate(camera_input * mouse_sensitivity,delta * smoothness)
	
	objects_global.player.rotate_y(-rotation_velocity.x)
	rotate_x(-rotation_velocity.y)
	rotation.x = clamp(rotation.x,deg2rad(-81),deg2rad(81))
	
	camera_input = Vector2.ZERO
