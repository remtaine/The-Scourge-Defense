extends Enemy


func _ready():
	max_hp = 12
	base_damage = 1
#	ATTACK_DIST = 150

func _on_TargetResetTimer_timeout():
	change_target(Util.primary_target)
	has_been_attacked = false

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
