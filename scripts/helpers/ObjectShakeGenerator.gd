extends Node2D

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

onready var host = get_parent()
onready var tween = $Tween
onready var frequency = $FrequencyTimer
onready var duration = $DurationTimer

var amplitude = 0
var priority = 0
var orig_global_pos
 
func start(priority = 0, d = 0.2, f = 15.0, amplitude = 8):
	orig_global_pos = host.global_position
	if self.priority <= priority:
		self.priority = priority 
		self.amplitude = amplitude + priority * 3 
		frequency.set_wait_time(1.0/float(f * (1 + float(priority)/10.0)))
		duration.set_wait_time(d)
		
		duration.start()
		frequency.start()
		
		_new_shake()
	
func _new_shake():
	var rand = Vector2()
	randomize()
	rand.x =  rand_range(-amplitude, amplitude)
	rand.y =  rand_range(-amplitude, amplitude)
	var new_global_pos = Vector2(orig_global_pos.x + rand.x, orig_global_pos.y + rand.y) 
	change_offset(new_global_pos)

func reset():
	change_offset(orig_global_pos)
	priority = 0

func change_offset(val):
	tween.interpolate_property(host, "global_position", null, val, frequency.wait_time, TRANS, EASE)
	tween.start()
	
func _on_FrequencyTimer_timeout():
	_new_shake()
	frequency.start()

func _on_DurationTimer_timeout():
	reset()
	frequency.stop()
