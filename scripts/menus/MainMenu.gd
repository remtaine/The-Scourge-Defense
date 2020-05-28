extends CanvasModulate

onready var start_button = $VBox/StartButton

func _ready():
	pass

func _on_StartButton_pressed():
	SceneChanger.change_scene(start_button.dest)
