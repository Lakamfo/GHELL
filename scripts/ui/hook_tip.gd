extends Spatial

onready var camera : Camera
onready var marker : Control = $texture
onready var animation_player : AnimationPlayer = $texture/animation
onready var timer: Timer = $shows_timer

var is_shows : bool = false

func _ready() -> void:
	camera = get_viewport().get_camera()
	get_parent().object_handler = self

func _process(_delta: float) -> void:
	var pos = camera.unproject_position(self.global_transform.origin)
	marker.rect_position = pos

func _show():
	timer.start()
	if not is_shows:
		animation_player.play("animation")
		is_shows = true

func _hide():
	if is_shows:
		animation_player.play_backwards("animation")
		is_shows = false

func screen_entered() -> void:
	marker.show()

func screen_exited() -> void:
	marker.hide()

func show_timer() -> void:
	_hide()
