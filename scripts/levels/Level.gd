extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var can_reset = true

var showing_label = false
var enemies = []
var zombies = []
var allies = []
# Called when the node enters the scene tree for the first time.
func _init():
	Util.current_level = self	

func _ready():
	$Characters/Player.setup(self)
	pass # Replace with function body.
	for child in $Characters.get_children():
		if child.is_in_group("allies"):
			if child.is_in_group("zombies"):
				child.setup(self)
			allies.append(child)
		if child.is_in_group("enemies"):
			enemies.append(child)

func _physics_process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("main_menu"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("state_label_change"):
		for child in $Characters.get_children():
#			showing_label = !howing_label
			if child.has_node("StateLabel"):
				child.get_node("StateLabel").visible = !child.get_node("StateLabel").visible

func _on_combo_extended(val):
	$LevelUI/ComboText/ComboLabel.set_combo(val)
	print("COMBO ACTIVATED")

func _on_zombie_spawned(zombie):
	zombies.append(zombie)
	print("GOT A NEW ZOMBIE~")
