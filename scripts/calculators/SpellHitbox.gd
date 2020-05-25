extends CalculatorBox

func _ready():
	box_type = "spell hitbox"
	disable()
#	pass

func _on_Hitbox_area_entered(area):
	if (area.host.is_in_group("enemies") and host.is_in_group("allies")):
		emit_signal("turned_enemy")
		area.emit_signal("has_turned")
