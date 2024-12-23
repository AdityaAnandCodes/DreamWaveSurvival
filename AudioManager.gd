extends AudioStreamPlayer

const Main_menu = preload("res://sounds/Myuu-Lunatic-Visual-Novel-Music.ogg")
const LevelMusic1 = preload("res://sounds/Level Music Track.ogg")
const LevelMusic2 = preload("res://sounds/(No Copyright) Intense Action Background Music Cinematic Music by Argsound [TubeRipper.com].ogg")
var playingBeat = false
const heartBeat = preload("res://sounds/HeartBeat.mp3")

func _play_music(music: AudioStream, volume=0.0):
	if stream == music:
		volume_db = volume
		return
		
	stream=music
	volume_db=volume
	play()
	
func play_music_level():
	_play_music(LevelMusic1)
	await self.finished 
	if self.stream == LevelMusic1:
		_play_music(LevelMusic2)
	
	
	
func play_mainmenu_music():
	_play_music(Main_menu,4.0)
	
func cutscene_music():
	_play_music(Main_menu,-4.0)
	
func play_FX(stream: AudioStream, volume=0.0):
	var fx_player=AudioStreamPlayer.new()
	fx_player.stream=stream
	fx_player.name="FX_PLAYER"
	fx_player.volume_db=volume
	add_child(fx_player)
	fx_player.play()
	await fx_player.finished
	fx_player.queue_free()

func HeartBeat():
	if GlobalScript.PlayerHealth <= 50 and GlobalScript.PlayerHealth >=0 and not playingBeat:
		playingBeat = true
		AudioManager.play_FX(heartBeat,-5)
	if GlobalScript.PlayerHealth <= 40  and GlobalScript.PlayerHealth >=0  and playingBeat:
		$FX_PLAYER.pitch_scale = 1.2
		$FX_PLAYER.volume_db = -3
	if GlobalScript.PlayerHealth <= 20  and GlobalScript.PlayerHealth >=0  and playingBeat:
		$FX_PLAYER.pitch_scale = 1.3
		$FX_PLAYER.volume_db = 0
	if GlobalScript.PlayerHealth <= 0 and playingBeat:
		playingBeat = false
		remove_child($FX_PLAYER)
