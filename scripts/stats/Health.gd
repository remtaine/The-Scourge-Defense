extends Node2D

export var is_side = false
export var is_overhead = false

onready var left_side_health_bar = $CanvasModulate/LeftSideHealthBar
onready var right_side_health_bar = $CanvasModulate/RightSideHealthBar
onready var overhead_health_bar = $OverheadHealthBar

func update_health():
	pass	
	
func _ready():
	if is_side:
		$CanvasModulate/SideHealthBar.visible = true
	else:
		$CanvasModulate/SideHealthBar.visible = false

	if is_overhead:
		$OverheadHealthBar.visible = true
	else:
		$OverheadHealthBar.visible = false
