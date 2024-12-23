extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var thunder_player: AnimationPlayer = $ThunderPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	AudioManager.cutscene_music()
	animation_player.play("LoopingAnimation")
	_random_thunder()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _random_thunder() -> void:
	while true:
		var random_wait_time = randi_range(2, 8)
		await get_tree().create_timer(random_wait_time).timeout
		if not thunder_player.is_playing():
			thunder_player.play("Thunder")


func _on_restart_button_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://node_3d.tscn")
	


func _on_main_menu_button_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://main_menu.tscn")
