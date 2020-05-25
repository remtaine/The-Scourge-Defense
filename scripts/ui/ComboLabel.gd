extends Label

var combo = 0 setget set_combo, get_combo
onready var combo_timer = $ComboTimer

func _ready():
	visible = false

func set_combo(val):
	if val == 0:
		combo = 0
	else:
		combo += val
	
	if combo >= 2:
		visible = true
		text = "Combo x" + String(combo)
		combo_timer.start()
	else:
		visible = false
				
func get_combo():
	return combo

func _on_ComboTimer_timeout():
	set_combo(0)
