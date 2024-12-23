extends CharacterBody3D


var speed 
var Walk_speed = 3.0
var Sprint_speed = 6.5
const JUMP_VELOCITY = 4.5
const hit_stagger = 8.0

var gravity = 9.8
var Sensitivity = 0.003

const BobFreq = 2.0
const Bob_Amp = 0.08
var t_bob = 0.0

const base_fov = 75.0
const fov_change = 1.5

signal player_hit

var bullet = load("res://bullet.tscn")
var bulletInstance

@onready var head = $Head
@onready var camera = $Head/Camera3D

var gun_anim 
var gun_barrel
var gun_using = "revolver"

@onready var SwitchingAnimation = $AnimationPlayer

@onready var mg = $Head/Camera3D/GunModel
@onready var mg_anim = $Head/Camera3D/GunModel/AnimationPlayer
@onready var mg_barrel = $Head/Camera3D/GunModel/RayCast3D

@onready var rev = $Head/Camera3D/Revolver
@onready var rev_anim = $Head/Camera3D/Revolver/AnimationPlayer
@onready var rev_barrel = $Head/Camera3D/Revolver/RayCast3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * Sensitivity)
		camera.rotate_x(-event.relative.y * Sensitivity)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-40),deg_to_rad(60))
		

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		handleGunAnimation()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	if Input.is_action_pressed("sprint") and not Input.is_action_pressed("down"):
		speed = Sprint_speed
	else:
		speed = Walk_speed
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x,direction.x * speed,delta*7.0)
			velocity.z = lerp(velocity.z,direction.z * speed,delta*7.0)
	else:
		velocity.x = lerp(velocity.x,direction.x * speed,delta*2.0)
		velocity.z = lerp(velocity.z,direction.z * speed,delta*2.0)
	
		
	t_bob+= delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(),0.5,Sprint_speed * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov,target_fov,delta * 8.0)

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y  = sin(time * BobFreq) * Bob_Amp
	pos.x = cos(time  * BobFreq/2) * Bob_Amp
	return pos

func hit(dir):
	emit_signal("player_hit")
	velocity += dir * hit_stagger
	GlobalScript.PlayerHealth -= 10
	
	
func handleGunAnimation():
	if gun_using == "revolver":
		Walk_speed = 5.0
		Sprint_speed = 7.0
		mg.visible = false
		rev.visible = true
		gun_anim = rev_anim
		gun_barrel = rev_barrel
	elif gun_using == "mg":
		Walk_speed = 3.0
		Sprint_speed = 6.0
		if not gun_anim == mg_anim:
			$AnimationPlayer.play("switch_to_mg")
		gun_anim = mg_anim
		gun_barrel = mg_barrel
	if !gun_anim.is_playing() and not SwitchingAnimation.is_playing():
			gun_anim.play("shoot")
			bulletInstance = bullet.instantiate()
			bulletInstance.position = gun_barrel.global_position
			bulletInstance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(bulletInstance)
