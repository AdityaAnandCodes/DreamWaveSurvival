extends CharacterBody3D

var player = null
@export var player_path := "/root/World/CharacterBody3D"
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var zombie_sound: AudioStreamPlayer3D = $ZombieSound



var state_machine 

const walk_speed = 0.85
var speed = 5.5
const attack_range = 2.0
var health = 6
var ran_once = false


func _ready() -> void:
	GlobalScript.ZombiesAlive += 1
	player = get_node(player_path)
	RandomWalker()
	state_machine = anim_tree.get("parameters/playback")
	await get_tree().physics_frame
	zombie_sound.play()
	
func _process(delta: float) -> void:
	if player:
		velocity = Vector3.ZERO
		anim_tree.set("parameters/conditions/attack",_target_in_range())
		match state_machine.get_current_node():
			"Walk":
				nav_agent.set_target_position(player.global_transform.origin)
				var next_nav_point =  nav_agent.get_next_path_position()
				var new_velocity = (next_nav_point - global_transform.origin).normalized() * walk_speed
				velocity = new_velocity
				rotation.y = lerp_angle(rotation.y,atan2(-velocity.x,-velocity.z),delta * 10.0)
				
			"Running":
				nav_agent.set_target_position(player.global_transform.origin)
				var next_nav_point =  nav_agent.get_next_path_position()
				var new_velocity = (next_nav_point - global_transform.origin).normalized() * speed
				velocity = new_velocity
				rotation.y = lerp_angle(rotation.y,atan2(-velocity.x,-velocity.z),delta * 10.0)
			"Attack":
				look_at(Vector3(player.global_position.x,player.global_position.y,player.global_position.z),Vector3.UP)
			"LoopAttack":
				look_at(Vector3(player.global_position.x,player.global_position.y,player.global_position.z),Vector3.UP)
		anim_tree.set("parameters/conditions/attack",_target_in_range())
		if not anim_tree.get("parameters/conditions/walk"):
			anim_tree.set("parameters/conditions/run",!_target_in_range())
		else:
			anim_tree.set("parameters/conditions/walk",!_target_in_range())
			
	move_and_slide()


func _target_in_range():
	if player:
		return global_position.distance_to(player.global_position) < attack_range


func _hit_finished():
	if global_position.distance_to(player.global_position) < attack_range + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)


func _on_area_3d_body_part_hit(dam: Variant) -> void:
	health-= dam
	if health <= 0:
		zombie_sound.stop()
		if ran_once == false:
			ran_once = true
			GlobalScript.ZombiesAlive -= 1
			GlobalScript.ZombiesKilled +=1
			
		anim_tree.set("parameters/conditions/die",true)
		$CollisionShape3D.disabled = true
		await get_tree().create_timer(4.0).timeout
		queue_free()


func RandomWalker():
	var random = randi_range(1,10)
	if random % 7 == 0:
		anim_tree.set("parameters/conditions/walk",!_target_in_range())
	else:
		if random % 9 == 0:
			speed+=1
		
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity,0.25)
	
	
	
