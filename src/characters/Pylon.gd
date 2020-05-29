extends Character

var is_dead = false
func _init():
	max_hp = 100
	Util.primary_target = self
	
func _ready():
	health.setup(self)
	sprite.get_node("AnimationPlayer").play("float")

func _on_just_died():
	if not is_dead: 
		sprite.get_node("AnimationPlayer").play("disappear")
		is_dead = true
	Util.current_level.show_lose_screen()
