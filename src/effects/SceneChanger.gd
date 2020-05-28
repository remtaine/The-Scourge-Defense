extends ColorRect

var dest = null

func _ready():
	pass

func change_scene(d):
	dest = d
	get_tree().change_scene(dest)
#	$AnimationPlayer.play("close")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"close":
				get_tree().change_scene(dest)
