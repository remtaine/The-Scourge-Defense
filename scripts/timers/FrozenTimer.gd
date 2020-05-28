extends Timer

var host
signal done_frozen

func _ready():
	pass

func setup(h):
	host = h
	connect("done_frozen", host, "_on_done_frozen")

func _on_FrozenTimer_timeout():
	emit_signal("done_frozen")
