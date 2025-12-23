extends CharacterBody3D

var speed := 4.5

@onready var main_node = get_tree().root.get_node("Main")
var player_node: CharacterBody3D = null

# 重力を追加
var gravity = 15.0

func _ready():
	# プロジェクトの重力設定を取得
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	
	player_node = get_tree().root.find_child("Player", true, false)
	if not player_node:
		print("ERROR: Player node not found!")
		set_process(false)
	else:
		print("Boss ready! Player found at:", player_node.global_position)
	
	speed = Global.boss_speed

func _physics_process(delta):
	if not player_node or main_node.is_game_over:
		return
	
	# === 重力を適用 ===
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0  # 地面にいるときはy速度をリセット
	
	# プレイヤーの方向を計算
	var direction_vector = player_node.global_position - global_position
	direction_vector.y = 0
	var direction = direction_vector.normalized()
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	move_and_slide()
	
	# 衝突判定
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider == player_node:
			print("CAUGHT THE PLAYER!")
			main_node.game_over_by_boss()
			player_node = null
			break
