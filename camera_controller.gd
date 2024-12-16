extends Node3D

@onready var main_cam: Camera3D = $MainCam
@onready var reflection_cam: Camera3D = $SubViewport/ReflectionCam
@onready var sub_viewport: SubViewport = $SubViewport

var startPos: Vector3 = Vector3(0,4,0)
var camPos: Vector3
var camRot: Vector2
# Called when the node enters the scene tree for the first time.
@export var rotation_speed: float = 1
@export var speed: float = 1
var use_mouse = true;

func set_use_mouse(val: bool):
	use_mouse = val
	if val:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Called when the node enters the scene tree for the first time.
func _ready():
	camPos = startPos
	set_use_mouse(true)

func _input(event):
	if event is InputEventMouseMotion and use_mouse:
		camRot.x -= event.relative.y * rotation_speed
		camRot.y -= event.relative.x * rotation_speed
		camRot.x = clamp(camRot.x, -PI/2, PI/2)
	if event.is_action_pressed("ui_cancel"):
		set_use_mouse(!use_mouse)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: 
	# update position stuff
	var theta = camRot.y
	var vert = Vector3.UP * Input.get_axis("move_down","move_up")
	var forward = Vector3(-sin(theta),0,-cos(theta)) * Input.get_axis("move_backward","move_forward")
	var side = Vector3(cos(theta),0,-sin(theta)) * Input.get_axis("move_left","move_right")
	var velocity = vert + forward + side
	velocity = velocity.normalized() * delta * speed
	camPos += velocity
	if (camPos.y < 0.01):
		camPos.y = 0.01
	# set data for each camera to match
	sub_viewport.size = Vector2i(main_cam.get_viewport().size * 1.1)
	main_cam.position = camPos
	
	reflection_cam.position = Vector3(camPos.x,-camPos.y,camPos.z)
	main_cam.rotation_degrees = Vector3(rad_to_deg(camRot.x),rad_to_deg(camRot.y),0)
	reflection_cam.rotation_degrees = Vector3(-rad_to_deg(camRot.x),rad_to_deg(camRot.y),180)
