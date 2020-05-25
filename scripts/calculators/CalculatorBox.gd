extends Area2D

class_name CalculatorBox

var host
onready var col_shape = $CollisionShape2D
var box_type = "box"

signal hit_enemy
signal took_damage
signal has_turned
signal turned_enemy

func _ready():
	pass

func enable():
	$CollisionShape2D.disabled = false

func disable():
	$CollisionShape2D.disabled = true

func setup(current_owner):
	host = current_owner
	connect("hit_enemy", host, "_on_hit_enemy")
	connect("took_damage", host, "_on_take_damage")
	connect("has_turned", host, "_on_has_turned")
	connect("turned_enemy", host, "_on_turn_enemy")
	print("setup for ", box_type, " done, owned by ", host.instance_name)
