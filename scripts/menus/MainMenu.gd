extends CanvasModulate

onready var start_button = $VBox/StartButton
onready var player_sprite = $CharacterSprites/PlayerSprite
onready var spirit_circle = $CharacterSprites/PlayerSprite/SpiritCircle

var sprites = []

func _ready():
	for i in $CharacterSprites.get_children():
		sprites.append(i)
	sprites.erase(player_sprite)
	
func _on_StartButton_pressed():
	print("PRESSEDD")
	$SpellSound1.play()
	player_sprite.play("cast_turning_spell")
	spirit_circle.visible = true

func _on_PlayerSprite_animation_finished():
	if player_sprite.animation == "cast_turning_spell":
		$SpellSound2.play()
		spirit_circle.visible = false
		for i in range (0, sprites.size()):
			sprites[i].play("transform")
			sprites[i].scale.x *= -1
		player_sprite.play("idle")
		yield(get_tree().create_timer(1.0), "timeout")
		get_tree().change_scene(start_button.dest)
#		start_button.get_node("SceneChanger").change_scene(start_button.dest)
