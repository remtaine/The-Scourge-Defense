extends Position2D


func _ready():
	pass

func disable_all():
	for child in get_children():
		child.disable()
