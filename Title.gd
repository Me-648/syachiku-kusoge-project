extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var howto_button = $VBoxContainer/HowToButton

@onready var credits_button = $VBoxContainer/CreditButton 

@onready var howto_panel = $HowToPanel
@onready var close_howto_button = $HowToPanel/CloseButton 

@onready var credits_panel = $Credit 
@onready var close_credits_button = $Credit/CloseButton 

@onready var difficulty_panel = $Panel

@onready var easy_button = $Panel/VBoxContainer/Button
@onready var normal_button = $Panel/VBoxContainer/Button2
@onready var hard_button = $Panel/VBoxContainer/Button3
@onready var very_hard_button = $Panel/VBoxContainer/Button4
@onready var back_button = $Panel/VBoxContainer/Button5



func _ready():
	start_button.pressed.connect(_on_start_pressed)
	howto_button.pressed.connect(_on_howto_pressed)
	credits_button.pressed.connect(_on_credits_pressed)

	close_howto_button.pressed.connect(_on_close_howto_pressed)
	close_credits_button.pressed.connect(_on_close_credits_pressed)

	easy_button.pressed.connect(_on_easy_pressed)
	normal_button.pressed.connect(_on_normal_pressed)
	hard_button.pressed.connect(_on_hard_pressed)
	very_hard_button.pressed.connect(_on_very_hard_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	difficulty_panel.visible = false

	

func _on_start_pressed():
	$UISound.play()
	difficulty_panel.visible = true

# 遊び方パネルを開く
func _on_howto_pressed():
	$UISound.play()
	howto_panel.visible = true

# 遊び方パネルを閉じる (関数名を変更)
func _on_close_howto_pressed():
	$UISound.play()
	howto_panel.visible = false

# クレジットパネルを開く
func _on_credits_pressed():
	$UISound.play()
	credits_panel.visible = true

# クレジットパネルを閉じる
func _on_close_credits_pressed():
	$UISound.play()
	credits_panel.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_easy_pressed():
	$UISound.play()
	Global.difficulty = Global.Difficulty.EASY
	Global.apply_difficulty()
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_normal_pressed():
	$UISound.play()
	Global.difficulty = Global.Difficulty.NORMAL
	Global.apply_difficulty()
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_hard_pressed():
	$UISound.play()
	Global.difficulty = Global.Difficulty.HARD
	Global.apply_difficulty()
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_very_hard_pressed():
	$UISound.play()
	Global.difficulty = Global.Difficulty.VERY_HARD
	Global.apply_difficulty()
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_back_pressed():
	$UISound.play()
	difficulty_panel.visible = false
