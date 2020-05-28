extends TextureProgress

var host

signal just_died
signal got_hurt

var health = 0
var max_health = 0

func update_health(val):
	health -= val
	set_value(health)
	
	if health <= 0:
		emit_signal("just_died")
	else:
		emit_signal("got_hurt")
		print("just hurt")

func setup(h):
	host = h
	set_max(h.max_hp)
	set_value(h.max_hp)

	health = h.max_hp
	max_health = health
	
	connect("just_died", h, "_on_just_died")
	connect("got_hurt", h, "_on_got_hurt")

func _ready():
	pass
