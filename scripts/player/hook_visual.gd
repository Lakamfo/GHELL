extends CSGCylinder

onready var tween : Tween = Tween.new()
onready var grapplin : Spatial = $grapplin
onready var joint

func _ready() -> void:
	add_child(tween)
	joint = get_parent()

func _process(_delta: float) -> void:
	grapplin.translation.y = (height / 2) - 0.10
	translation.z = -(height / 2)
	

func get_back():
	tween.interpolate_property(self,"height",height,0,0.5,Tween.TRANS_BACK)
	tween.interpolate_property(joint,"rotation_degrees",joint.rotation_degrees,Vector3.ZERO,0.5,Tween.TRANS_BACK)
	if tween.start():pass
	yield(tween,"tween_all_completed")
	hide()
