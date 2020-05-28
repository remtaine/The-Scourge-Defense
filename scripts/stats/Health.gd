extends Node2D

export var is_left_side = false
export var is_right_side = false
export var is_overhead = false

onready var left_side_health_bar = $Node/CanvasModulate/LeftSideHealthBar
onready var right_side_health_bar = $Node/CanvasModulate/RightSideHealthBar
onready var overhead_health_bar = $OverheadHealthBar
var health_bars = []
var host

signal just_died
signal got_hurt

var health = 0
var max_health = 0

func update_health(val):
	health -= val
	for i in range (health_bars.size()):
		health_bars[i].set_value(health)
	if health < max_health:
		overhead_health_bar.visible = true
	if health <= 0:
		emit_signal("just_died")
	else:
		emit_signal("got_hurt")
		print("just hurt")

func setup(h):
	host = h
	for i in range (health_bars.size()):
		health_bars[i].set_max(h.max_hp)
		health_bars[i].set_value(h.max_hp)

	health = h.max_hp
	max_health = health
	
	connect("just_died", h, "_on_just_died")
	connect("got_hurt", h, "_on_got_hurt")

func _ready():
	health_bars.append(left_side_health_bar)
	health_bars.append(right_side_health_bar)
	health_bars.append(overhead_health_bar)
	
	if is_left_side:
		left_side_health_bar.visible = true
	else:
		left_side_health_bar.visible = false		

	if is_right_side:
		right_side_health_bar.visible = true			
	else:
		right_side_health_bar.visible = false		

	if is_overhead:
		overhead_health_bar.visible = true		
	else:
		overhead_health_bar.visible = false
