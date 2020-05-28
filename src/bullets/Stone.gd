extends KinematicBody2D

var _spd = 300
var _dir = Vector2.ZERO
var _velocity = Vector2.ZERO
var initial_pos = Vector2.ZERO
onready var hitbox = $Hitboxes/Hitbox
var base_damage = 0
var instance_name = "enemy"
var is_flipped = false

const MAX_THROW_DIST = 400

func _ready():
	hitbox.setup(self)
	hitbox.enable()	

func setup_values(pos, dir, dmg = 1):
	global_position = pos
	initial_pos = global_position
	_dir = dir
	_velocity = _spd * _dir
	base_damage = dmg
	
func _physics_process(delta):
	move_and_collide(_velocity * delta)
	if initial_pos.distance_to(global_position) > MAX_THROW_DIST:
		queue_free()
