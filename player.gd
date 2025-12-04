extends CharacterBody3D 

# Camera3Dノード（プレイヤーの子）に簡単にアクセスできるようにします
@onready var camera_node = $Camera3D 

@onready var main = get_tree().get_root().get_node("Main")

#カメラの回転速度を調整(小さいとゆっくり)
const MOUSE_SENSITIVITY = 0.002

# プレイヤーが動くスピードを設定します（歩く速さ）
const SPEED = 5.5 
const JUMP_VELOCITY = 5.7

# 重力の設定（Godotのプロジェクト設定から自動で取得します）
@export var gravity = 15.0 

# ゲームが始まる前に一度だけ実行される関数
func _ready():
	# ゲームの物理設定（重力）を、このスクリプトの「gravity」変数にコピーします。
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	
	#マウスカーソルを非表示にして画面中央に固定
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# 物理演算のタイミング（一瞬）ごとに何度も実行される関数
func _physics_process(delta):
	if main.is_game_over:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	
	# =========================================================
	# 1. 重力（下に落ちる力）とジャンプの処理
	# =========================================================
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY 

	# =========================================================
	# 2. キーボード入力の取得と移動
	# =========================================================
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


# =========================================================
# 3. マウス入力と終了処理 (ここですべての入力イベントを処理します)
# =========================================================
func _input(event):
	# 左右と上下の視点回転
	if event is InputEventMouseMotion:
		var mouse_dx = event.relative.x
		var mouse_dy = event.relative.y
		
		# 左右の回転 (Playerノード自体を回転)
		rotate_y( -mouse_dx * MOUSE_SENSITIVITY) 
		
		# 上下の回転 (Camera3Dノードを回転)
		var rotation_amount = -mouse_dy * MOUSE_SENSITIVITY
		
		# 角度を制限
		camera_node.rotation_degrees.x = clamp(
			camera_node.rotation_degrees.x + rotation_amount, 
			-80.0, 
			60.0   
		)
		
	# Escキー（終了処理）
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
		get_tree().quit()
		
		# イベントが処理されたことを示します (これを使用することで _unhandled_input は不要になります)
		# event.set_accepted() # Godot 4ではこの一行です。
