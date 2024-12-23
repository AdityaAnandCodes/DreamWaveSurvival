extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var canvas = $CanvasLayer
@onready var lightning: AnimationPlayer = $DirectionalLight3D/lightning
@onready var easy: Button = $CanvasLayer/Easy
@onready var medium: Button = $CanvasLayer/Medium
@onready var hard: Button = $CanvasLayer/Hard
@onready var play: Button = $CanvasLayer/Play
@onready var quit: Button = $CanvasLayer/Quit
@onready var difficulty: Label = $CanvasLayer/Difficulty
@onready var label: Label = $CanvasLayer/Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	easy.visible = false
	medium.visible = false
	hard.visible = false
	difficulty.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	AudioManager.play_mainmenu_music()
	canvas.visible = true
	anim_player.play("LoopingAnimation")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if canvas.visible:
		Random_Lightning()
		


func _on_play_pressed() -> void:
	easy.visible = true
	medium.visible = true
	hard.visible = true
	difficulty.visible = true
	label.visible = false
	play.visible = false
	quit.visible = false
	
	
	
func Random_Lightning():
	var random = randi_range(0,10)
	if random % 7 == 0 and not lightning.is_playing():
		lightning.play("Lightning")
	else:
		pass


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_easy_pressed() -> void:
	GlobalScript.noWaves = 4
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	canvas.visible = false
	anim_player.play("MainMenuAnimation")
	await anim_player.animation_finished
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://end_scene.tscn")


func _on_hard_pressed() -> void:
	GlobalScript.noWaves = 10
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	canvas.visible = false
	anim_player.play("MainMenuAnimation")
	await anim_player.animation_finished
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://end_scene.tscn")


func _on_medium_pressed() -> void:
	GlobalScript.noWaves = 8
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	canvas.visible = false
	anim_player.play("MainMenuAnimation")
	await anim_player.animation_finished
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://end_scene.tscn")
