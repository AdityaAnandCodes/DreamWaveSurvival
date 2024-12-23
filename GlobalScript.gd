extends Node

var PlayerHealth
var ZombiesAlive
var ZombiesKilled
var LastWaveCompleted

var noWaves
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if noWaves == null:
		noWaves = 6
	Restart()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	AudioManager.HeartBeat()


func Restart():
	PlayerHealth = 100
	ZombiesAlive = 0
	ZombiesKilled = 0
	LastWaveCompleted = false
