extends Node2D

func _ready():
	modulate = Color(modulate.r, modulate.g, modulate.b, 0.0)
	
func appear():
	if not Util.can_change_menu:
		$AnimationPlayer.play("appear")
		Util.can_change_menu = true
