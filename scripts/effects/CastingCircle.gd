extends Sprite

var current_scale
onready var tween = $Tween
var cm

func _ready():
	current_scale = scale
	cm = modulate
		
func _physics_process(delta):
	pass
#	tween.interpolate_property(self, "modulate", modulate, Color(cm.r, cm.g, cm.b, 1.0))
#	Tween.end
###	scale = Vector2(1,1)
#	rotation_degrees += 0.1
##	scale = Vector2(current_scale.x  * cos(-rotation_degrees), current_scale.y * sin(-rotation_degrees))
