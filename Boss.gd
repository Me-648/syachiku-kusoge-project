extends CharacterBody3D

# =========================================================
# 1. 移動パラメータ
# =========================================================
var speed := 4.5
var black_accel := 0.15   # ブラック企業用 加速量

# =========================================================
# 2. 参照ノード
# =========================================================
@onready var main_node = get_tree().root.get_node("Main")
var player_node: CharacterBody3D = null

# =========================================================
# 3. 重力
# =========================================================
var gravity := 15.0


# =========================================================
# 4. 初期化
# =========================================================
func _ready():
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	player_node = get_tree().root.find_child("Player", true, false)
	if not player_node:
		print("ERROR: Player node not found!")
		set_physics_process(false)
		return

	speed = Global.boss_speed
	print("Boss ready. Speed:", speed)


# =========================================================
# 5. 物理処理（追跡）
# =========================================================
func _physics_process(delta):
	if not player_node or main_node.is_game_over:
		return

	# ブラック企業：時間経過で加速
	if Global.difficulty == Global.Difficulty.BLACK:
		speed += black_accel * delta

	# 重力
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# プレイヤー方向
	var dir = player_node.global_position - global_position
	dir.y = 0
	dir = dir.normalized()

	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	move_and_slide()

	# 捕獲判定
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() == player_node:
			print("CAUGHT THE PLAYER!")
			main_node.game_over_by_boss()
			player_node = null
			break
