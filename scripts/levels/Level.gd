extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Characters/Player.setup(self)
	pass # Replace with function body.


func _physics_process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("state_label_change"):
		for child in $Characters.get_children():
			child.get_node("StateLabel").visible = !child.get_node("StateLabel").visible

func _on_combo_extended(val):
	$LevelUI/ComboLabel.set_combo(val)
