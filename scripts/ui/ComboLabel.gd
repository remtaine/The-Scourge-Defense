extends Label

const FADE_DURATION = 0.5

var combo = 0 setget set_combo, get_combo
onready var combo_timer = $ComboTimer
onready var tween = $Tween
onready var shaker = get_parent().get_node("ObjectShakeGenerator")

var cm
func _ready():
	cm = modulate
	visible = false

func set_combo(val):
	if val == 0:
		combo = 0
	else:
		shaker.start()
		$AnimationPlayer.play("emphasize")
		modulate = cm #resets modulate
		combo += val
	
	if combo >= 2:
		visible = true
		text = "x" + String(combo)
		combo_timer.start()
	else:
		visible = false
				
func get_combo():
	return combo

func reset_combo():
	set_combo(0)
	
func _on_ComboTimer_timeout():
	tween.interpolate_property(self,"modulate",modulate, Color(cm.r, cm.g, cm.b, 0.0), FADE_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func _on_Tween_tween_completed(object, key):
	if key == ":modulate":
		reset_combo()
