extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var howto_button = $VBoxContainer/HowToButton
@onready var howto_panel = $HowToPanel
@onready var close_button = $HowToPanel/CloseButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	howto_button.pressed.connect(_on_howto_pressed)
	close_button.pressed.connect(_on_close_pressed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_howto_pressed():
	howto_panel.visible = true

func _on_close_pressed():
	howto_panel.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
