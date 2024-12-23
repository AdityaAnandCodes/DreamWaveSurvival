extends Node3D

@onready var hit_rect = $UI/ColorRect
@onready var spawns = $Spawn
@onready var NavigationRegion = $NavigationRegion3D

@onready var ZombieSpawnTimer = $ZombieSpawnTime
@onready var WaveTimer = $WaveTimer
@onready var WaveLabel = $CanvasLayer/WaveLabel
@onready var cross_hair: TextureRect = $CanvasLayer/CrossHair
@onready var alive_zombies: Label = $UI/AliveZombies
@onready var dead_zombies: Label = $UI/DeadZombies
@onready var health_bar: ProgressBar = $UI/HealthBar



@onready var player = $CharacterBody3D
@onready var UI =  $UI
var zombie = load("res://zombie_v1.tscn")
var zombieInstance

var lock = false
var StartingWaveSpawnTime = 5
var SpawnTime
var WaveCount = 0
var WaveDuration = 30
var mg_given
func _ready() -> void:
	UI.visible = true
	GlobalScript.Restart()
	AudioManager.play_music_level()
	if GlobalScript.noWaves == 4:
		mg_given = 1
	elif GlobalScript.noWaves == 8:
		mg_given = 3
	elif GlobalScript.noWaves == 10:
		mg_given = 5
	else:
		mg_given = 3
	print(GlobalScript.noWaves)
	print(mg_given)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handleHealth()
	UpdateUI()


func _on_character_body_3d_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.25).timeout
	hit_rect.visible = false


func _get_random_child(parent_node):
	var rand_id =  randi() % parent_node.get_child_count()
	return parent_node.get_child(rand_id)

func _on_zombie_spawn_time_timeout() -> void:
	var spawn_point = _get_random_child(spawns).global_position
	zombieInstance = zombie.instantiate()
	zombieInstance.position = spawn_point
	NavigationRegion.add_child(zombieInstance)


func _on_wave_timer_timeout() -> void:
	WaveTimer.stop()
	if WaveCount == 0:
		cross_hair.visible = true
		SpawnTime = StartingWaveSpawnTime
	else:
		if WaveCount == mg_given:
			player.gun_using = "mg"
		if WaveCount < 8:
			SpawnTime-= 0.5
		else:
			WaveDuration = WaveDuration/2
			SpawnTime-=0.1
	WaveCount += 1
	if WaveCount == GlobalScript.noWaves:
		cross_hair.visible = false
		UI.visible = false
		GlobalScript.LastWaveCompleted = true
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file("res://end_scene.tscn")
		return
	WaveTimer.wait_time = WaveDuration
	var tween = get_tree().create_tween()
	WaveLabel.text = "Wave " + str(WaveCount)
	tween.tween_property(WaveLabel,"visible",true, 4.0)
	await tween.finished
	tween.tween_property(WaveLabel,"visible",false, 10.0)
	WaveLabel.visible = false
	ZombieSpawnTimer.wait_time = SpawnTime
	ZombieSpawnTimer.start()
	WaveTimer.start()


func UpdateUI():
	#UI.text = "Player Health : " + str(GlobalScript.PlayerHealth) 
	health_bar.value = GlobalScript.PlayerHealth
	alive_zombies.text = "Alive : " + str(GlobalScript.ZombiesAlive)
	dead_zombies.text = "Killed : " + str(GlobalScript.ZombiesKilled)


func handleHealth():
	if GlobalScript.PlayerHealth <= 0 and not lock:
		cross_hair.visible = false
		lock = true
		UI.visible = false
		TransitionScreen.death_transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file("res://restart_screen.tscn")
