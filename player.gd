extends CharacterBody3D

@onready var camera_node = $Camera3D
@onready var main = get_tree().get_root().get_node("Main")

const MOUSE_SENSITIVITY = 0.002
const SPEED = 5.5
const JUMP_VELOCITY = 5.7

var gravity: float = 100

var want_jump = false


func _ready():
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if main.is_game_over:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	# --------------------------------------------
	# 重力
	# --------------------------------------------
	# ジャンプ処理
	if is_on_floor():
		if want_jump:
			velocity.y = JUMP_VELOCITY
			$JumpSE.play()
			want_jump = false
	else:
		velocity.y -= gravity * delta

	# --------------------------------------------
	# WASD 移動
	# --------------------------------------------
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# CharacterBody3D の move_and_slide() は引数なし！
	# 戻り値も velocity ではなく bool なので代入してはダメ！
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_dx = event.relative.x
		var mouse_dy = event.relative.y

		rotate_y(-mouse_dx * MOUSE_SENSITIVITY)

		var rot_amount = -mouse_dy * MOUSE_SENSITIVITY
		camera_node.rotation_degrees.x = clamp(
			camera_node.rotation_degrees.x + rot_amount,
			-80.0,
			60.0
		)

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			want_jump = true
