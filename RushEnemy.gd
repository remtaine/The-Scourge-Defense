extends Enemy

func _init():
	max_hp = 5
	base_damage = 2

func _ready():
	SPEED = {
		STATES.IDLE: Vector3(0, 0, 0),
		STATES.RUN: Vector3(110, 60, 100),
		STATES.JUMP: Vector3(200, 100, 100),
		STATES.ROLL: Vector3(500, 250, 100),
		STATES.CHASE: Vector3(200, 120, 100),
	}
	
func _on_take_damage(damager, dmg = base_damage):
	last_damaged_by = damager
	last_damaged_by_wr = weakref(damager)
	 #TODO add damage
	health.update_health(dmg)


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
