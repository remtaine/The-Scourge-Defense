extends KinematicBody2D

var _spd = 300
var _dir = Vector2.ZERO
var _velocity = Vector2.ZERO

func _ready():
	pass

func setup_values(pos, dir):
	global_position = pos
	_dir = dir
	_velocity = _spd * _dir
	
func _physics_process(delta):
	move_and_collide(_velocity * delta)
