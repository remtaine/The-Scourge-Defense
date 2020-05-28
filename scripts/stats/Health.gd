extends Node2D

export var is_left_side = false
export var is_right_side = false
export var is_overhead = false

onready var left_side_health_bar = $Node/CanvasModulate/LeftSideHealthBar
onready var right_side_health_bar = $Node/CanvasModulate/RightSideHealthBar
onready var overhead_health_bar = $OverheadHealthBar
var host

func update_health(val):
	pass	

func setup(h):
	host = h
	set_
func _ready():
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
