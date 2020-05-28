extends Sprite

var current_scale
onready var tween = $Tween
var cm

func _ready():
	current_scale = scale
	cm = modulate
	$AnimationPlayer.play("appear")
#	self_modulate = Color(cm.r, cm.g, cm.b, 0)
#	tween.interpolate_property(self, "self_modulate", self_modulate, Color(cm.r, cm.g, cm.b, 1), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
#	tween.start()
	
func _physics_process(delta):
	pass
###	scale = Vector2(1,1)
#	rotation_degrees += 0.1
##	scale = Vector2(current_scale.x  * cos(-rotation_degrees), current_scale.y * sin(-rotation_degrees))
