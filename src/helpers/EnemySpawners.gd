extends Node2D

var current_wave = 0
var enemy_spawn_list = []
var current_enemies = []
onready var wave_label = $CanvasLayer/WaveLabel
onready var wave_anim = $CanvasLayer/WaveLabel/AnimationPlayer

func _ready():
	pass

func go_to_next_wave():
	current_enemies = []
	current_wave += 1
#	for i in range:
