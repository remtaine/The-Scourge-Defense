extends Sprite

var current_scale
onready var tween = $Tween
var cm

func _ready():
	current_scale = scale
	cm = modulate
		
func _physics_process(delta):
	tween.interpolate_property(self, "modulate", modulate, Color.white, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
###	scale = Vector2(1,1)
#	rotation_degrees += 0.1
##	scale = Vector2(current_scale.x  * cos(-rotation_degrees), current_scale.y * sin(-rotation_degrees))
