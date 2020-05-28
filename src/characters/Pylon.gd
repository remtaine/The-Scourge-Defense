extends Character

func _init():
	max_hp = 100
	Util.primary_target = self
	
func _ready():
	health.setup(self)
