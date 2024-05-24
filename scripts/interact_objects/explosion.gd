extends Spatial

export var start_radius : float = 5
export var final_radius : float = 0
export var show_explosion_duration : float = 0.5
export var start_anim_offset : float = 5
export var anim_duration : float = 0.2

onready var tween : Tween = $tween
onready var sphere : CSGSphere = $sphere
onready var collision : CollisionShape = $area/collision

func _ready() -> void:
	if start_anim_offset > 0:
		yield(get_tree().create_timer(start_anim_offset,false),"timeout")
	
	tween.interpolate_property(sphere,"radius",sphere.radius,start_radius,anim_duration,Tween.TRANS_ELASTIC)
	tween.interpolate_property(collision.shape,"radius",collision.shape,start_radius,anim_duration,Tween.TRANS_ELASTIC)
	tween.start()
	
	
	if show_explosion_duration > 0:
		yield(get_tree().create_timer(show_explosion_duration,false),"timeout")
	else:
		yield(tween,"tween_completed")
	
	tween.interpolate_property(sphere.material,"albedo_color",sphere.material.albedo_color,Color(1,1,1,0),anim_duration,Tween.TRANS_ELASTIC)
	tween.interpolate_property(sphere,"radius",start_radius,final_radius,anim_duration / 2,Tween.TRANS_ELASTIC)
	tween.start()
	
	yield(tween,"tween_completed")
	queue_free()

func body_entered(body: Node) -> void:
	pass # Replace with function body.
