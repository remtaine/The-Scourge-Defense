extends Character

class_name Player

signal speed_changed(speed, max_speed)
signal combo_extended

var SPEED 
var MAX_SPEED

const JUMP_DURATION = 0.7
const MAX_JUMP_HEIGHT = -60
const JUMP_FALL_DISCREPANCY = 0.05

var prev_jump_height = 100
var jump_vel = 0
var jump_pos = 0

var continue_combo = 0
var is_falling = false

onready var anim_player = $AnimationPlayer
onready var tween = $Tween
onready var camera_shake = $Camera2D/ScreenShakeGenerator

onready var fist_sound1 = preload("res://sfx/characters/player/FIST 1.wav")
onready var fist_sound2 = preload("res://sfx/characters/player/FIST 2.wav")
onready var fist_sound3 = preload("res://sfx/characters/player/FIST 3.wav")
onready var fist_sound_combo = preload("res://sfx/characters/player/FIST COMBO FINISHER.wav")

onready var roll_sound = preload("res://sfx/characters/player/movement/ROLL.wav")
onready var jump_sound = preload("res://sfx/characters/player/movement/JUMP 1 (for SMALL SIZE or PLAYER).wav")
onready var land_sound = preload("res://sfx/characters/player/movement/JUMP LANDING.wav")

onready var punchbox = $Body/AnimatedSprite/Hitboxes/PunchHitbox
onready var airkickbox = $Body/AnimatedSprite/Hitboxes/AirKickHitbox
onready var runpunchbox = $Body/AnimatedSprite/Hitboxes/RunPunchHitbox

onready var spellbox = hitboxes.get_node("SpellHitbox")
func _init():
	max_hp = 10000000
	SPEED = {
		STATES.IDLE: Vector3(0, 0, 0),
		STATES.RUN: Vector3(300, 150, 100),
		STATES.JUMP: Vector3(200, 100, 100),
		STATES.ROLL: Vector3(300, 150, 100),
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
		[STATES.RUN, EVENTS.ATTACK]: STATES.ATTACK_RUN_PUNCH,	
		[STATES.ATTACK_PUNCH, EVENTS.ATTACK_END]: STATES.IDLE,	
		[STATES.ATTACK_RUN_PUNCH, EVENTS.ATTACK_END]: STATES.IDLE,	
		
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
		[STATES.ATTACK_RUN_PUNCH, EVENTS.HURT]: STATES.HURT,	
		[STATES.JUMP, EVENTS.HURT]: STATES.HURT,	
		[STATES.ATTACK_AIR_KICK, EVENTS.HURT]: STATES.HURT,	
		[STATES.HURT, EVENTS.HURT_END]: STATES.IDLE,	
			
#		[STATES.FALL, EVENTS.LAND]: STATES.IDLE,			
	}
	base_damage = 1
	instance_name = "player"
	Util.current_player = self

func _ready():
	_state = STATES.IDLE
	_speed = SPEED[_state]
#	connect("speed_changed", $DirectionVisualizer, "_on_Move_speed_changed")


func _physics_process(delta):
#	var slide_count = get_slide_count()
#	_collision_normal = get_slide_collision(slide_count - 1).normal if slide_count > 0 else _collision_normal

	if frozen_duration > 0.0:
		sprite._set_playing(false)
		if _state != STATES.HURT:
			yield(get_tree().create_timer(frozen_duration), "timeout")
		sprite._set_playing(true)
		frozen_duration = 0.0
		print("STATE AFTER BEING FROZEN IS ", _state)

		match _state: # after being frozen
			STATES.HURT:
				if _state == STATES.DIE:
					sprite.play("die")
					$Sounds/DeathSound.play()
				else:
					sprite.play("hurt")
				if not $Sounds/HurtSound.is_playing():
					$Sounds/HurtSound.play()
				$HurtAnimationPlayer.play("hurt")
				if last_damaged_by.instance_name == "enemy":
#					print("hit by enemy!")
					#TODO change to is_facing
					if not last_damaged_by.is_flipped:#ie player is at left
						_velocity.x = KNOCKBACK_LENGTH
					else:
						_velocity.x = -KNOCKBACK_LENGTH
					camera_shake.start()
#				if not tween.is_active():
#					tween.interpolate_method(self, "animate_knockback", 0, 1, hurt_anim_player.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
#					tween.start()
			STATES.ATTACK_PUNCH, STATES.ATTACK_AIR_KICK, STATES.ATTACK_RUN_PUNCH:
				pass
#				$Sounds/AttackSound.stop()
#				match continue_combo:
#					1:
#						play_sound(fist_sound1)
#					2:
#						play_sound(fist_sound3)
#					3:
#						play_sound(fist_sound_combo)

	var input = get_raw_input(_state)
	var event = decode_raw_input(input)
	change_state(event)
	
	match _state: #match for velocity
		STATES.RUN, STATES.JUMP, STATES.ATTACK_RUN_PUNCH:
			_dir = input.direction
			continue
		STATES.JUMP, STATES.RUN, STATES.ROLL, STATES.ATTACK_RUN_PUNCH:
			_velocity.x = _speed.x * _dir.x
			_velocity.y = _speed.y * _dir.y
			continue
		STATES.ATTACK_RUN_PUNCH:
			_velocity *= 0.8
		STATES.IDLE, STATES.CASTING_TURNING_SPELL, STATES.ATTACK_PUNCH:
			_velocity = Vector2(0, 0)
			if Input.is_action_pressed("attack"):
				match (sprite.get_frame()):
					2,3,4:
						continue_combo = 2
					5,6,7:
						continue_combo = 3
		STATES.JUMP:
			pass
#			if body.is_on_floor():
				
			#TODO insert animate_jump code
			
			
	
#	match _state: #match for clamping speed
#		STATES.RUN, STATES.ROLL, STATES.JUMP:
#			_velocity.x = clamp(_velocity.x, -MAX_SPEED[_state].x, MAX_SPEED[_state].x)
#			_velocity.y = clamp(_velocity.y, -MAX_SPEED[_state].y, MAX_SPEED[_state].y)
			
	match _state: #match for flipping
		STATES.ATTACK_PUNCH, STATES.IDLE, STATES.HURT, STATES.DIE, STATES.CASTING_TURNING_SPELL:
			pass
#		STATES.HURT, STATES.DIE:
#			flip(_velocity.x > 0)
		_:
			flip(_velocity.x < 0)

	move_and_slide(_velocity)
#	if collision:
#		# To make the other kinematicbody2d move as well
##		collision.collider.velocity = velocity.length() * -collision.normal
##		velocity = velocity.bounce(collision.normal) * 0.5
#		collision.collider.global_position.y += -_velocity.y * delta
#	body.move_and_slide(_velocity)
	
#	_air_velocity.y += 10
#	air_move(delta, _air_velocity)

func _set_speed(value):
	if _speed == value:
		return
	_speed = value
	emit_signal("speed_changed", _speed, SPEED[STATES.RUN])

func enter_state():
	$StateLabel.text = _state
	
	match prev_state:
		STATES.CASTING_TURNING_SPELL, STATES.ATTACK_AIR_KICK, STATES.ATTACK_PUNCH, STATES.ATTACK_RUN_PUNCH:
			$Body/AnimatedSprite/Hitboxes.disable_all()
			continue
		STATES.CASTING_TURNING_SPELL:
			$Sounds/SpellSound.stop()
			spellbox.hide_sprite()

	match _state:
		STATES.IDLE:
			sprite.play("idle")
			continue
		STATES.ROLL, STATES.RUN:
			_speed = SPEED[_state]
			continue
		STATES.ROLL:
			play_sound(roll_sound)
			sprite.play("roll")
			$Timers/RollCDTimer.start()
		STATES.RUN:
			sprite.play("run")
		STATES.ATTACK_PUNCH, STATES.ATTACK_AIR_KICK:
			continue_combo = 1
			continue
		STATES.ATTACK_PUNCH:	
			sprite.play("attack_punch")
		STATES.ATTACK_RUN_PUNCH:	
			sprite.play("attack_run_punch")
		STATES.ATTACK_AIR_KICK:
			sprite.play("attack_air_kick")
#			_speed *= 1.5
		STATES.JUMP:
			play_sound(jump_sound)
			sprite.play("jump")
			tween.interpolate_method(self, "animate_jump", 0, 1, JUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.start()
#			jump_vel = _speed[_state].z
		STATES.CASTING_TURNING_SPELL:
			spellbox.show_sprite()
			$Sounds/SpellSound.play()
			sprite.play("cast_turning_spell")
#			print("CASTING TURNING SPELL")
		STATES.HURT:
			if frozen_duration == 0.0:
				frozen_duration = BASE_FREEZE_DURATION

func animate_jump(progress):
	pass
	var jump_height
#	if is_falling:
#		var limit = clamp(progress + JUMP_FALL_DISCREPANCY, 0, 1)
#		jump_height = MAX_JUMP_HEIGHT * pow(sin((limit) * PI), 0.7)
#	else:	
	jump_height = MAX_JUMP_HEIGHT * pow(sin(progress * PI), 0.7)
	var shadow_scale = 1.0 - (jump_height/MAX_JUMP_HEIGHT * 0.5)

	sprite.position.y = jump_height
	shadow_sprite.scale = Vector2(shadow_scale, shadow_scale) * current_shadow_scale
	if prev_jump_height < jump_height: #meaning he's already going dowwnnn
		if sprite.animation == "jump":
			sprite.play("fall")
		is_falling = true
	prev_jump_height = jump_height
		
static func get_raw_input(state):
	return {
		direction = get_input_direction(),
		is_attacking = Input.is_action_pressed("attack"),
		is_rolling = Input.is_action_pressed("special"),
		is_jumping = Input.is_action_pressed("jump"),
		is_casting_turn_spell = Input.is_action_just_pressed("cast_turning_spell"),
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
	if input.is_casting_turn_spell:
		event = EVENTS.CASTING_TURNING_SPELL
	elif input.is_attacking:
		event = EVENTS.ATTACK
	elif input.is_rolling and $Timers/RollCDTimer.is_stopped() and input.direction != Vector2():# or _state == STATES.ROLL:
		event = EVENTS.ROLL
	elif input.is_jumping:# and input.direction != Vector2():
		event = EVENTS.JUMP
	elif input.direction == Vector2():
		event = EVENTS.IDLE
	else:
		event = EVENTS.RUN

	return event

func _on_AnimatedSprite_animation_finished():
	match sprite.animation:
		"attack_punch", "attack_run_punch":
			change_state(EVENTS.ATTACK_END)
		"roll":
			sprite.position.y = 0		
			change_state(EVENTS.ROLL_END)	
		"cast_turning_spell":
			spellbox.enable()
			tween.interpolate_callback(spellbox, 0.2, "disable")
			tween.start()
#			pass
			

func _on_Tween_tween_completed(object, key):
	if key == ":animate_jump":
		play_sound(land_sound)
		prev_jump_height = 100
		change_state(EVENTS.LAND)
		is_falling = false
	
	if key == ":disable":
		change_state(EVENTS.CASTING_SPELL_END)

func _on_AnimatedSprite_frame_changed():
	match sprite.animation:
		"attack_punch":
			match sprite.get_frame():
				5:
					if continue_combo == 2:
						play_sound(fist_sound2)	
						punchbox.enable()
					else:
						punchbox.disable()
						change_state(EVENTS.ATTACK_END)
						continue_combo = 0						
					continue
				8:
					if continue_combo == 3:
						play_sound(fist_sound3) #TODO change to combo once knocked down in effect
						punchbox.enable()
					else:
						punchbox.disable()
						change_state(EVENTS.ATTACK_END)
						continue_combo = 0
					continue
					
				2:
					play_sound(fist_sound1)
					punchbox.enable()
					continue
				3, 7, 11:
					punchbox.disable()
					continue
		"roll":
			match sprite.get_frame():
				1:
					pass
#					sprite.position.y = 17
		"attack_air_kick":
			match sprite.get_frame(): #TODO CREATE custom hitbox for kick
				2:
					airkickbox.enable()
				2:
					airkickbox.disable()
		"attack_run_punch":
			match sprite.get_frame(): #TODO CREATE custom hitbox for kick
				3:
					play_sound(fist_sound1)
					runpunchbox.enable()
				4: 
					runpunchbox.disable()

func play_sound(sound):
	match sound:
		jump_sound, roll_sound, land_sound:
			$Sounds/MovementSound.stream = sound
			$Sounds/MovementSound.play()
		fist_sound1, fist_sound2, fist_sound3, fist_sound_combo:
#			print(sound)
			$Sounds/AttackSound.stream = sound
			$Sounds/AttackSound.play()
			
func setup(s):
	connect("combo_extended", s, "_on_combo_extended")

func _on_HurtAnimationPlayer_animation_finished(anim_name):
	change_state(EVENTS.HURT_END)
