extends Character

class_name Player

signal speed_changed(speed, max_speed)
signal combo_extended

var SPEED 
var MAX_SPEED

const JUMP_DURATION = 1.0
const MAX_JUMP_HEIGHT = -100
var is_flipped = false

var prev_jump_height = 100
var jump_vel = 0
var jump_pos = 0

var continue_combo = false
var current_sprite_scale
var current_shadow_scale
var _speed = 0 setget _set_speed
var _max_speed = 0
var _dir = Vector2(1,0)
var _velocity = Vector2.ZERO
#var _collision_normal = Vector2()
#var _last_input_direction = Vector2()

onready var sprite = $AnimatedSprite
onready var shadow_sprite = $Shadow
onready var anim_player = $AnimationPlayer
onready var tween = $Tween
onready var camera_shake = $Camera2D/ScreenShakeGenerator

func _init():
	
	SPEED = {
		STATES.IDLE: Vector3(0, 0, 0),
		STATES.RUN: Vector3(200, 100, 100),
		STATES.JUMP: Vector3(200, 100, 100),
		STATES.ROLL: Vector3(500, 250, 100),
	}

	MAX_SPEED = {
		STATES.RUN: Vector3(200, 100, 100),
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
		
		[STATES.IDLE, EVENTS.CASTING_TURNING_SPELL]: STATES.CASTING_TURNING_SPELL,
		[STATES.RUN, EVENTS.CASTING_TURNING_SPELL]: STATES.CASTING_TURNING_SPELL,	
		[STATES.CASTING_TURNING_SPELL, EVENTS.CASTING_SPELL_END]: STATES.IDLE,

		[STATES.IDLE, EVENTS.HURT]: STATES.HURT,
		[STATES.RUN, EVENTS.HURT]: STATES.HURT,	
		[STATES.CASTING_TURNING_SPELL, EVENTS.HURT]: STATES.HURT,
		[STATES.ATTACK_PUNCH, EVENTS.HURT]: STATES.HURT,	
		[STATES.JUMP, EVENTS.HURT]: STATES.HURT,	
		[STATES.ATTACK_AIR_KICK, EVENTS.HURT]: STATES.HURT,	
		[STATES.HURT, EVENTS.HURT_END]: STATES.IDLE,	
			
#		[STATES.FALL, EVENTS.LAND]: STATES.IDLE,			
	}

	instance_name = "player"
	
func _ready():
	current_scale = Vector2(scale.x, 0)
	current_sprite_scale = sprite.scale
	current_shadow_scale = shadow_sprite.scale
	_state = STATES.IDLE
	_speed = SPEED[_state]
#	connect("speed_changed", $DirectionVisualizer, "_on_Move_speed_changed")


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
				hurt_anim_player.play("hurt")
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
		STATES.IDLE, STATES.CASTING_TURNING_SPELL, STATES.ATTACK_PUNCH:
			_velocity = Vector2(0, 0)
			if Input.is_action_just_pressed("attack"):
				match (sprite.get_frame()):
					2,3,4,6,7,8:
						continue_combo = true
		STATES.JUMP:
			pass
			#TODO insert animate_jump code
			
			
	
#	match _state: #match for clamping speed
#		STATES.RUN, STATES.ROLL, STATES.JUMP:
#			_velocity.x = clamp(_velocity.x, -MAX_SPEED[_state].x, MAX_SPEED[_state].x)
#			_velocity.y = clamp(_velocity.y, -MAX_SPEED[_state].y, MAX_SPEED[_state].y)
			
	flip()

	move_and_slide(_velocity)

func flip():
	match _state: #match for flipping
		STATES.ATTACK_PUNCH, STATES.IDLE:
			return
		_:
			if _velocity.x < 0:
#				if scale.x != -current_scale.x:
#					scale.x = -current_scale.x
#					print("current scale is ", current_scale.x)
#					print("flipped scale is ", scale.x)
				is_flipped = true
				sprite.scale.x = -current_sprite_scale.x
			elif _velocity.x > 0:
#				scale.x = current_scale.x
				is_flipped = false
				sprite.scale.x = current_sprite_scale.x
#				sprite.flip_h = false

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
#			jump_vel = _speed[_state].z
		STATES.CASTING_TURNING_SPELL:
			sprite.play("cast_turning_spell")
			print("CASTING TURNING SPELL")
		STATES.HURT:
			hurt_anim_player.play("hurt")

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
		direction = get_input_direction(),
		is_attacking = Input.is_action_just_pressed("attack"),
		is_rolling = Input.is_action_just_pressed("special"),
		is_jumping = Input.is_action_just_pressed("jump"),
		is_casting_turn_spell = Input.is_action_just_pressed("cast_turning_spell"),
	}

static func get_input_direction(event = Input):
	return Vector2(
			float(event.is_action_pressed("move_right")) - float(event.is_action_pressed("move_left")),
			float(event.is_action_pressed("move_down")) - float(event.is_action_pressed("move_up")))


static func decode_raw_input(input):
	"""
	Converts the player's input to events. The state machine
	uses these events to trigger transitions from one state to another.
	"""
	var event = EVENTS.INVALID
	if input.is_casting_turn_spell:
		event = EVENTS.CASTING_TURNING_SPELL
	elif input.is_attacking:
		event = EVENTS.ATTACK
	elif input.is_rolling and input.direction != Vector2():# or _state == STATES.ROLL:
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
		"cast_turning_spell":
			var spellbox = hitboxes.get_node("SpellHitbox")
			spellbox.enable()
			tween.interpolate_callback(spellbox, 0.2, "disable")
			tween.start()
#			pass
			

func _on_Tween_tween_completed(object, key):
	if key == ":animate_jump":
		prev_jump_height = 100
		change_state(EVENTS.LAND)
	
	if key == ":disable":
		change_state(EVENTS.CASTING_SPELL_END)
		
func _on_turn_enemy():
	print("ENEMY TURNED")

func _on_AnimatedSprite_frame_changed():
	match sprite.animation:
		"attack_punch":
			var punchbox = hitboxes.get_node("PunchHitbox")
			match sprite.get_frame():
				6:
					if continue_combo:
						punchbox.enable()
						continue_combo = false
					else:
						punchbox.disable()
						change_state(EVENTS.ATTACK_END)
					continue
				10:
					if continue_combo:
						punchbox.enable()
						continue_combo = false
					else:
						punchbox.disable()
						change_state(EVENTS.ATTACK_END)
					continue
					
				2:
					punchbox.enable()
					continue
				3, 7, 11:
					punchbox.disable()
					continue
		"roll":
			match sprite.get_frame():
				1:
					sprite.position.y = 17

func _on_hit_enemy(multiplier = 1):
	emit_signal("combo_extended", 1)

func setup(s):
	connect("combo_extended", s, "_on_combo_extended")
