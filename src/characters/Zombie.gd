extends Character

class_name Zombie

signal speed_changed(speed, max_speed)

var SPEED
var MAX_SPEED

const JUMP_DURATION = 1.0
const MAX_JUMP_HEIGHT = -100

var prev_jump_height = 100
var jump_vel = 0
var jump_pos = 0

onready var anim_player = $AnimationPlayer
onready var tween = $Tween

func _init():
	SPEED = {
		STATES.IDLE: Vector3(0, 0, 0),
		STATES.RUN: Vector3(50, 100, 100),
		STATES.JUMP: Vector3(200, 100, 100),
		STATES.ROLL: Vector3(500, 250, 100),
	}
	
	MAX_SPEED = {
		STATES.RUN: Vector3(50, 100, 100),
		STATES.JUMP: Vector3(200, 100, 100),
		STATES.ROLL: Vector3(500, 250, 100),
	}
	
	_transitions = {
		[STATES.IDLE, EVENTS.RUN]: STATES.RUN,
		[STATES.RUN, EVENTS.IDLE]: STATES.IDLE,
		
		[STATES.IDLE, EVENTS.ROLL]: STATES.ROLL,
		[STATES.RUN, EVENTS.ROLL]: STATES.ROLL,
		[STATES.ROLL, EVENTS.ROLL_END]: STATES.IDLE,	
		
		[STATES.IDLE, EVENTS.ATTACK]: STATES.ATTACK_PUNCH,
		[STATES.RUN, EVENTS.ATTACK]: STATES.ATTACK_PUNCH,	
		[STATES.ATTACK_PUNCH, EVENTS.ATTACK_END]: STATES.IDLE,	
		
		[STATES.IDLE, EVENTS.JUMP]: STATES.JUMP,
		[STATES.RUN, EVENTS.JUMP]: STATES.JUMP,	
		
		[STATES.JUMP, EVENTS.LAND]: STATES.IDLE,	
		[STATES.JUMP, EVENTS.ATTACK]: STATES.ATTACK_AIR_KICK,	
		[STATES.ATTACK_AIR_KICK, EVENTS.LAND]: STATES.IDLE,	
#		[STATES.FALL, EVENTS.LAND]: STATES.IDLE,			
	}

	_state = STATES.IDLE
	_speed = SPEED[_state]

func _ready():
	$Sounds/SummonedSound.play()
#	connect("speed_changed", $DirectionVisualizer, "_on_Move_speed_changed")

func setup(g_pos):
	global_position = g_pos
#	pass

func _physics_process(delta):
#	var slide_count = get_slide_count()
#	_collision_normal = get_slide_collision(slide_count - 1).normal if slide_count > 0 else _collision_normal

	if frozen_duration > 0.0:
		sprite._set_playing(false)
		yield(get_tree().create_timer(frozen_duration), "timeout")
		sprite._set_playing(true)
		frozen_duration = 0.0

		match _state:
			STATES.HURT:
				sprite.play("hurt")
#				$Anim.play("hurt")
			STATES.ATTACK, STATES.ATTACK_PUNCH, STATES.ATTACK_AIR_KICK:
				pass

	var input = get_raw_input(_state)
	var event = decode_raw_input(input)
	change_state(event)
	match _state: #match for velocity
		STATES.RUN:
			_dir = input.direction
			continue
		STATES.JUMP, STATES.RUN, STATES.ROLL:
			_velocity.x = _speed.x * _dir.x
			_velocity.y = _speed.y * _dir.y
			continue
		STATES.JUMP:
			pass
	
	match _state: #match for flipping
		STATES.ATTACK_PUNCH, STATES.IDLE:
			pass
		STATES.HURT, STATES.DIE:
			flip(_velocity.x > 0)
		_:
			flip(_velocity.x < 0)

	move_and_slide(_velocity)



func _set_speed(value):
	if _speed == value:
		return
	_speed = value
	emit_signal("speed_changed", _speed, SPEED[STATES.RUN])

func enter_state():
	$StateLabel.text = _state
	
	match _state:
		STATES.IDLE:
			sprite.play("idle")
			continue
		STATES.ROLL, STATES.RUN:
			_speed = SPEED[_state]
			continue
		STATES.ROLL:
			sprite.position.y = 18
			sprite.play("roll")
		STATES.RUN:
			sprite.play("run")
		STATES.ATTACK_PUNCH:
			sprite.play("attack_punch")
		STATES.ATTACK_AIR_KICK:
			sprite.play("attack_air_kick")
		STATES.JUMP:
			sprite.play("jump")
			tween.interpolate_method(self, "animate_jump", 0, 1, JUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.start()
		STATES.HURT:
			pass
#			hurt_anim_player.play("hurt")

func animate_jump(progress):
	var jump_height = MAX_JUMP_HEIGHT * pow(sin(progress * PI), 0.7)
	var shadow_scale = 1.0 - (jump_height/MAX_JUMP_HEIGHT * 0.5)
	
	sprite.position.y = jump_height
	shadow_sprite.scale = Vector2(shadow_scale, shadow_scale) * current_shadow_scale
	if prev_jump_height < jump_height and sprite.animation == "jump": #meaning he's already going dowwnnn
		sprite.play("fall")
	prev_jump_height = jump_height
		
static func get_raw_input(state):
	return {
		direction = Vector2(1,0),
		is_attacking = false,
		is_rolling = false,
		is_jumping = false,
	}

static func get_input_direction(event = Input):
	return Vector2(
			float(event.is_action_pressed("move_right")) - float(event.is_action_pressed("move_left")),
			float(event.is_action_pressed("move_down")) - float(event.is_action_pressed("move_up")))


func decode_raw_input(input):
	"""
	Converts the player's input to events. The state machine
	uses these events to trigger transitions from one state to another.
	"""
	var event = EVENTS.INVALID
	if input.is_attacking:
		event = EVENTS.ATTACK
	elif input.is_rolling:# or _state == STATES.ROLL:
		event = EVENTS.ROLL
	elif input.is_jumping:
		event = EVENTS.JUMP
	elif input.direction == Vector2():
		event = EVENTS.IDLE
	else:
		event = EVENTS.RUN

	return event

func _on_AnimatedSprite_animation_finished():
	match sprite.animation:
		"attack_punch":
			change_state(EVENTS.ATTACK_END)
		"roll":
			sprite.position.y = 0		
			change_state(EVENTS.ROLL_END)	

func _on_Tween_tween_completed(object, key):
	if key == ":animate_jump":
		prev_jump_height = 100
		change_state(EVENTS.LAND)
		
func _on_turn_enemy():
	print("ENEMY TURNED")
