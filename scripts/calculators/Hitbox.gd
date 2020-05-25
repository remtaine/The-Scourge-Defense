extends CalculatorBox

func _ready():
	box_type = "hitbox"
	disable()
#	pass
	
func _on_Hitbox_area_entered(area):
	if (area.host.is_in_group("enemies") and host.is_in_group("allies")) or (area.host.is_in_group("allies") and host.is_in_group("enemies")):
		if area.host._state != "HURT":
			emit_signal("hit_enemy")
			area.emit_signal("took_damage", host)
