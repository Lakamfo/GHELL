extends KinematicBody

enum states {IDLE,MOVE,DASH,HOOK,FALL}
var _name = ["IDLE","MOVE","DASH","HOOK","FALL"]
var state : int = states.IDLE

export var gravity : float = 10 #Units per second
export var movement_speed : float = 5 #Units per second
export var jump_power : float = 5

export var dash_reload : float = 2
export var dash_duration : float = 0.2
export var dash_speed_mult : float = 3

export var hook_distance : float = 10
export var hook_speed : float = 7
export var hook_shot_reach : float = 1
export var hook_momentum_time : float = 1

onready var head : Spatial = $head
onready var camera : Camera = $head/camera
onready var dash_timer : Timer = $dash_timer
onready var momentum_timer : Timer = $momentum_timer
onready var dash_particle : CPUParticles = $head/dash_particles
onready var ray_cast : RayCast = $head/camera/hook_ray
onready var hook_joint = $hook
onready var hook_csg = $hook/hook


var can_dash : bool = true
var dash_rtimer : float = 0
var hook_point : Vector3
var hook_reached : bool = false
var apply_momentum : bool = false
var hook_shot_dir : Vector3
var direction : Vector3 = Vector3.ZERO

func _ready() -> void:
	objects_global.player = self

func _physics_process(delta: float) -> void:
	if not can_dash:
		dash_rtimer += delta
		if dash_rtimer >= dash_reload:
			can_dash = true
			dash_rtimer = 0
	else:
		if Input.is_action_just_pressed("shift") and direction.length() >= 0.2:
			state = states.DASH
	
	match state:
		states.IDLE:
			get_axis(delta)
			apply_gravity(delta)
			apply_jump()
			hook_shot_handler()
		states.MOVE:
			get_axis(delta)
			apply_gravity(delta)
			apply_jump()
			hook_shot_handler()
		states.HOOK:
			hook_shot_movement(delta)
			hook_shot_handler()
			apply_jump()
		states.DASH:
			dash()
			apply_jump()
		states.FALL:
			get_axis(delta)
			apply_gravity(delta)
			hook_shot_handler()
	
	if ray_cast.is_colliding():
		var object = ray_cast.get_collider()
		if object.is_in_group("interact"):
			object.object_handler.call(object.method_name)
	
	$Control/state_label.text = "states: " + str(states)
	$Control/state_label2.text = "state: " + str(_name[state])
	
	if apply_momentum:
		direction.x += (hook_shot_dir.x * (momentum_timer.time_left / hook_momentum_time))
		direction.z += (hook_shot_dir.z * (momentum_timer.time_left/ hook_momentum_time))
	
	direction = move_and_slide(direction,Vector3.UP)

func get_axis(_delta: float):
	direction = Vector3(0,direction.y,0)
	
	direction += (transform.basis.z * Input.get_axis("w","s")) * movement_speed
	direction += (transform.basis.x * Input.get_axis("a","d")) * movement_speed
	
	if direction.length() != 0:
		state = states.MOVE
	else:
		state = states.IDLE

func apply_gravity(delta : float):
	if not is_on_floor():
		direction -= (transform.basis.y * gravity) * delta
		direction.y = clamp(direction.y,-gravity,20)
		state = states.FALL
	else:
		direction.y = 0
		

func apply_jump():
	if Input.is_action_just_pressed("space"):
			direction += transform.basis.y * jump_power
			if state == states.HOOK:
				state = states.MOVE
				dash_particle.emitting = false
				momentum_timer.start(hook_momentum_time)
				apply_momentum = true
				hook_csg.get_back()

func hook_shot_handler():
	ray_cast.cast_to.x = hook_distance
	if ray_cast.is_colliding() and Input.is_action_just_pressed("f"):
		hook_point = ray_cast.get_collision_point()
		dash_particle.emitting = true
		state = states.HOOK
		apply_momentum = false
		hook_shot_dir = hook_point - global_transform.origin

func hook_shot_movement(delta):
	hook_joint.look_at(hook_point,Vector3.UP)
	hook_csg.height = lerp(hook_csg.height,translation.distance_to(hook_point),1 / hook_speed)
	hook_csg.show()
	
	if hook_reached or (hook_csg.height >= translation.distance_to(hook_point) - hook_shot_reach):
		hook_reached = true
		hook_shot_dir = hook_point - global_transform.origin
		direction += (hook_shot_dir * translation.distance_to(hook_point)) * delta
		dash_particle.look_at_from_position(dash_particle.global_transform.origin,global_transform.origin + direction,Vector3.UP)
		
		if global_transform.origin.distance_to(hook_point) < hook_shot_reach:
			state = states.IDLE
			hook_csg.get_back()
			dash_particle.emitting = false

func dash():
	if can_dash:
		dash_particle.emitting = true
		dash_particle.look_at_from_position(dash_particle.global_transform.origin,global_transform.origin + direction,Vector3.UP)
		can_dash = false
		apply_momentum = false
		dash_timer.start(dash_duration)
		direction.x *= dash_speed_mult
		direction.z *= dash_speed_mult
		hook_csg.get_back()
		direction.y *= dash_speed_mult / 2

func dash_ended() -> void:
	state = states.MOVE
	dash_particle.emitting = false

func near_obj_detected(_body: Node) -> void:
	if not dash_timer.is_stopped() or state == states.HOOK:
		dash_ended()
		dash_timer.stop()
		dash_particle.emitting = false
		apply_momentum = false

func momentum_timeout() -> void:
	apply_momentum = false
