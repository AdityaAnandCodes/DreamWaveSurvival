extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

signal on_transition_finished

func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	
func transition():
	color_rect.visible = true
	animation_player.play("fade_to_black")
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		on_transition_finished.emit()
		animation_player.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		color_rect.visible = false
	elif anim_name == "fade_to_red":
		on_transition_finished.emit()
		animation_player.play("fade_to_clear")
	elif anim_name == "fade_to_clear":
		color_rect.visible = false

func death_transition():
	color_rect.visible = true
	animation_player.play("fade_to_red")
	
