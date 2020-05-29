extends Node2D

const MAX_SPAWN_PER_STAGE = 1
const MAX_X_OFFSET = 50
const MAX_Y_OFFSET = 5

var current_wave = 0
var enemy_spawn_list = []
var current_enemies = []
onready var wave_label = $CanvasLayer/WaveLabel
onready var wave_side_label = $CanvasLayer/WaveSideLabel
onready var wave_anim = $CanvasLayer/WaveLabel/AnimationPlayer
onready var stage_timer = $StageTimer
onready var melee_enemy = preload("res://src/characters/MeleeEnemy.tscn")
onready var ranged_enemy = preload("res://src/characters/RangedEnemy.tscn")
onready var rush_enemy = preload("res://src/characters/RushEnemy.tscn")

var times_spawned = 0
var last_level = 10

var spawn_rows = []
var spawn_points = []

func _ready():
	current_wave = 0
	for row in get_children():
		if row.get_class() == "Node2D":
			spawn_rows.append(row)
	for i in range (0, spawn_rows.size()):
		var temp = []
		for point in spawn_rows[i].get_children():
			temp.append(point)
		spawn_points.append(temp)
	
	enemy_spawn_list.append([12,0,0]) #Wave 1
	enemy_spawn_list.append([18,2,0]) #Wave 2
	enemy_spawn_list.append([22,6,0]) #Wave 3
	enemy_spawn_list.append([23,10,3]) #Wave 4
	enemy_spawn_list.append([25,12,8]) #Wave 5
	enemy_spawn_list.append([25,15,10]) #Wave 6
	enemy_spawn_list.append([20,5,30]) #Wave 7
	enemy_spawn_list.append([20,20,20]) #Wave 8
	enemy_spawn_list.append([15,35,15]) #Wave 9
	enemy_spawn_list.append([25,25,25]) #Wave 10

	go_to_next_wave()

func _physics_process(delta):
	if current_enemies.size() == 0:
		if times_spawned >= MAX_SPAWN_PER_STAGE:
			print("NEXT WAVE")		
			go_to_next_wave()
		else:
			print("NEXT STAGE")		
			spawn_horde(enemy_spawn_list[current_wave - 1])

func go_to_next_wave():
	if Util.can_change_menu:
		return
	current_enemies = []
	current_wave += 1
	if current_wave > last_level:
		Util.current_level.show_win_screen()
	else:
		wave_side_label.text = "Wave " + String(current_wave)
		wave_label.text = "Wave " + String(current_wave)
		wave_anim.play("appear")
		var temp = 0
		for i in range (0,3):
			temp += enemy_spawn_list[current_wave - 1][i]
		stage_timer.wait_time = temp * 2
		spawn_horde(enemy_spawn_list[current_wave - 1])

func spawn_enemies(list):
	for i in range (0, list.size()):
		for j in range (0, list[i]):
			#choose random row
			randomize()
			var temp_row = randi() % spawn_rows.size()
			#choose random point
			randomize()
			var temp_point = randi() % spawn_points[temp_row].size()
			var temp_pos = spawn_points[temp_row][temp_point].global_position
			#spawn enemy at that point
			match i:
				0:
#					call_deferred("summon",melee_enemy, temp_pos)
					summon(melee_enemy, temp_pos)
				1:
#					call_deferred("summon",ranged_enemy, temp_pos)
					summon(ranged_enemy, temp_pos)
				2:
#					call_deferred("summon",rush_enemy, temp_pos)
					summon(rush_enemy, temp_pos)

func summon(resource, pos):
	var temp_offset = Vector2()
	randomize()
	temp_offset.x = (randi() % ((2 * MAX_X_OFFSET) + 1)) - MAX_X_OFFSET
	randomize()
	temp_offset.y = (randi() % ((2 * MAX_Y_OFFSET) + 1)) - MAX_Y_OFFSET
	var entity = resource.instance()
	
	var temp_pos = Vector2()
	temp_pos.x = pos.x + temp_offset.x
	temp_pos.y = pos.y + temp_offset.y
	
	entity.global_position = temp_pos
	current_enemies.append(entity)
	entity.connect("dead", self, "_on_enemy_dead")
	get_parent().get_node("Characters").call_deferred("add_child", entity)

func _on_enemy_dead(enemy):
	current_enemies.erase(enemy)

func spawn_horde(list):
	if Util.can_change_menu:
		return
	spawn_enemies(list)
	times_spawned += 1
	stage_timer.start()
	
func _on_StageTimer_timeout():
	if times_spawned < MAX_SPAWN_PER_STAGE:
		spawn_horde(enemy_spawn_list[current_wave - 1])
	else:
		pass
