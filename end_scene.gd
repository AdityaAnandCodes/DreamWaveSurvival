extends Node3D

@onready var ThunderPlayer = $ThunderPlayer
@onready var RainSound = $RainSounds
@onready var GameManager = $GameManager

var Sensitivity = 0.003
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var label = $CanvasLayer/Lights
@onready var detector = $Head/Camera3D/RayCast3D


var GameBegan = false
var lightsOff = false
var tween : Tween

func _ready() -> void:
	AudioManager.cutscene_music()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	tween = get_tree().create_tween()
	if not GlobalScript.LastWaveCompleted:
		GameManager.play("BeginGame")
	handleLastScene()

func _process(delta: float) -> void:
	if not GlobalScript.LastWaveCompleted:
		handleLightsOff()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and GameBegan:
		head.rotate_y(-event.relative.x * Sensitivity)
		camera.rotate_x(-event.relative.y * Sensitivity)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-40),deg_to_rad(60))
		
func _random_thunder() -> void:
	while true:
		var random_wait_time = randi_range(2, 8)
		await get_tree().create_timer(random_wait_time).timeout
		if not ThunderPlayer.is_playing():
			ThunderPlayer.play("Thunder")


func _on_game_manager_animation_finished(anim_name: StringName) -> void:
	if anim_name == "BeginGame":
		GameBegan = true
		camera.position = Vector3.ZERO
		camera.rotation = Vector3.ZERO
	if anim_name == "EndingCutscene":
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file("res://main_menu.tscn")

func handleLightsOff():
	if not lightsOff:
		if detector.is_colliding():
			label.visible = true
			if Input.is_action_pressed("interact"):
				handleTurnOff()
		else:
			label.visible = false


func handleTurnOff():
	lightsOff = true
	GameBegan = false
	label.visible = false
	GameManager.play("Sleep")
	await GameManager.animation_finished
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://node_3d.tscn")


func handleLastScene():
	if GlobalScript.LastWaveCompleted:
		GlobalScript.LastWaveCompleted = false
		await get_tree().physics_frame
		GameManager.play("EndingCutscene")
		tween.tween_property(RainSound,"volume_db",9.0,3.0)
		await get_tree().create_timer(10.0).timeout
		_random_thunder()
		
		
		
