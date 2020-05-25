extends KinematicBody2D

class_name Character

signal state_changed(state)

var STATES = {
	IDLE = "IDLE",
	RUN = "RUN",
	HURT = "HURT",
	KNOCKED_DOWN = "KNOCKED DOWN",
	#player only
	ATTACK_PUNCH = "ATTACK PUNCH",
	ATTACK_AIR_KICK = "ATTACK AIR KICK",
	JUMP = "JUMP",
	ROLL = "ROLL",
	CASTING_TURNING_SPELL = "TURNING SPELL",

	#zombies only
	ATTACK = "ATTACK",
}

enum EVENTS {
	INVALID=-1,
	IDLE,
	RUN,
	ATTACK,
	ATTACK_END,
	HURT,
	HURT_END,
	KNOCKED_DOWN,
	GET_UP,
	#player only
	JUMP,
	ROLL,
	ROLL_END,
	LAND,
	CASTING_TURNING_SPELL,
	CASTING_SPELL_END,
}

export var instance_name = "sample"
onready var hurt_timer = $Timers/HurtTimer
onready var frozen_timer = $Timers/FrozenTimer
onready var timers = $Timers

var last_damaged_by
var KNOCKBACK_LENGTH = 100
const BASE_FREEZE_DURATION = 0.12
var frozen_duration = 0.0

var _state = "idle"

var _transitions = {}
var hp = 3
var max_hp = 3
var current_scale

onready var hitboxes = $AnimatedSprite/Hitboxes
onready var hurtboxes = $AnimatedSprite/Hurtboxes
onready var hurt_anim_player = $AnimationPlayer/HurtAnimationPlayer

func _ready():
	for hurtbox in hurtboxes.get_children():
		hurtbox.setup(self)
		
	for hitbox in hitboxes.get_children():
		hitbox.setup(self)
	
	for timer in timers.get_children():
		if timer.has_method("setup"):
			timer.setup(self)
			
	#connect("state_changed", $StateLabel, "_on_Character_state_changed")

func enter_state():
	pass

func change_state(event):
	var transition = [_state, event]
	if not transition in _transitions:
		return
	
	_state = _transitions[transition]
	enter_state()
	
	emit_signal("state_changed", _state)

func _on_hit_enemy(multiplier = 1):
	pass

func _on_take_damage(damager):
	last_damaged_by = damager
	print("LAST DAMAGED BY ", damager.instance_name)
	hp -= 0
#	print(instance_name, " has been hit with HP left of ", hp)	
	if hp <= 0:
		die()
	else:
		change_state(EVENTS.HURT)
#		frozen_duration = 1.0
#		frozen_timer.start()
		

func die():
	queue_free()
