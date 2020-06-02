extends CalculatorBox

onready var sprite = $CastingCircle

func _ready():
	box_type = "spell hitbox"
	disable()
	sprite.visible = false
#	pass

func _on_Hitbox_area_entered(area):
	if (area.host.is_in_group("enemies") and host.is_in_group("allies"))  and abs(host.global_position.y - area.host.global_position.y) < 80:
		emit_signal("turned_enemy")
		area.emit_signal("has_turned")

func show_sprite():
	sprite.visible = true
	

func hide_sprite():
	sprite.visible = false
