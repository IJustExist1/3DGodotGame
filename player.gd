
extends CharacterBody3D

@export var speed = 10
@export var accel = 10
@export var gravity = 50
@export var jump = 15
@export var sensitivity = 0.8
@export var max_angle = 90
@export var min_angle = -80

@onready var head = $Head
@onready var animplayer = $Head/Cam/AnimationPlayer
@onready var croucherthingy = $Collider/AnimationPlayer

var look_rot = Vector3.ZERO
var move_dir = Vector3.ZERO

var debug = false
var crouching = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	
	if Input.is_action_just_pressed("crouch") and crouching == false:
		croucherthingy.play("crouch_on")
		crouching = true
	elif Input.is_action_just_pressed("crouch") and crouching == true:
		croucherthingy.play("crouch_off")
		crouching = false
	
	if Input.get_action_strength("forward") >= 0.1 || Input.get_action_strength("backward") >= 0.1 || Input.get_action_strength("left") >= 0.1 || Input.get_action_strength("right") >= 0.1:
		animplayer.play("CameraBob")
	elif Input.get_action_strength("forward") < 0.09 || Input.get_action_strength("backward") > 0.09 || Input.get_action_strength("left") > 0.09 || Input.get_action_strength("right") > 0.09:
		animplayer.play("idle")
	
	if Input.is_action_just_pressed("debug") and debug == false:
		animplayer.play("spooky_on")
		debug = true
	elif Input.is_action_just_pressed("debug") and debug == true:
		animplayer.play("spooky_off")
		debug = false
		
	
	#set rotation
	head.rotation_degrees.x = look_rot.x
	rotation_degrees.y = look_rot.y

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_pressed("jump"):
		velocity.y = jump

	move_dir = Vector3(
		Input.get_action_strength("right") - Input.get_action_strength("left"), #X Axis
		0,#Y Axis
		Input.get_action_strength("backward") - Input.get_action_strength("forward")#Z Axis
	).normalized().rotated(Vector3.UP, rotation.y)

	velocity.x = lerp(velocity.x, move_dir.x * speed, accel * delta)
	velocity.z = lerp(velocity.z, move_dir.z * speed, accel * delta)

	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	velocity = velocity

func _input(event):
	if event is InputEventMouseMotion:
		look_rot.y -= (event.relative.x * sensitivity)
		look_rot.x -= (event.relative.y * sensitivity)
		look_rot.x = clamp(look_rot.x, min_angle, max_angle)
