extends CalculatorBox

func _ready():
	box_type = "hitbox"
	disable()
#	pass
	
func _on_Hitbox_area_entered(area):
	if (area.host.is_in_group("enemies") and host.is_in_group("allies")) or (area.host.is_in_group("allies") and host.is_in_group("enemies")):
		if area.host._state != "HURT" and area.host._state != "ROLL" and area.host.is_alive:
			if area.host.is_in_group("pylon"):
				area.emit_signal("took_damage", host, host.base_damage)	
			elif abs(host.global_position.y - area.host.global_position.y) < 50:
				if host.is_in_group("player"):
					emit_signal("hit_enemy")
				area.emit_signal("took_damage", host, host.base_damage)

func enable():
	$AnimationPlayer.play("flash")

func disable():
	$AnimationPlayer.stop()
	$CollisionShape2D.disabled = true
