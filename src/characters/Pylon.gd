extends Character

func _init():
	max_hp = 50
	Util.primary_target = self
	
func _ready():
	health.setup(self)

func _on_just_died():
	Util.current_level.show_lose_screen()
