extends Enemy

func _init():
	max_hp = 5
	base_damage = 2
	
func _ready():
	SPEED = {
		STATES.IDLE: Vector3(0, 0, 0),
		STATES.RUN: Vector3(120, 60, 100),
		STATES.JUMP: Vector3(200, 100, 100),
		STATES.ROLL: Vector3(500, 250, 100),
		STATES.CHASE: Vector3(240, 120, 100),
	}

func _physics_process(delta):
	change_target(Util.primary_target)

func _on_AnimatedSprite_frame_changed():
	match sprite.animation:
		"run":
			hitboxes.get_node("BasicAttackHitbox").disable()
		"attack":
			match sprite.get_frame():
				2, 5:
					hitboxes.get_node("BasicAttackHitbox").enable()
				3, 6:
					hitboxes.get_node("BasicAttackHitbox").disable()
