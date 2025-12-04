extends Node3D

# =========================================================
# 1. ゲームの状態を保持する変数
# =========================================================

var score = 0                       # ゴミを拾った数（スコア）
var game_time = 20.0                # 制限時間（20秒からスタート）
var is_game_over = false            # ゲーム終了フラグ

const TOTAL_TRASH_COUNT = 10         # オフィスに配置するゴミの総数
var trash_scene = preload("res://TrashItem.tscn") # TrashItemシーンを事前に読み込む

# =========================================================
# 2. UIノードへのアクセス
# =========================================================

@onready var score_label = $CanvasLayer/Control/ScoreLabel
@onready var timer_label = $CanvasLayer/Control/TimerLabel

@onready var result_ui = $CanvasLayer/ResultUI
@onready var result_label = $CanvasLayer/ResultUI/ResultLabel
@onready var retry_button = $CanvasLayer/ResultUI/VBoxContainer/RetryButton
@onready var title_button = $CanvasLayer/ResultUI/VBoxContainer/TitleButton

# =========================================================
# 3. ゲーム開始時の初期化
# =========================================================

func _ready():	
	update_ui()
	set_process(true)
	spawn_trash_items()

	# ボタンの動作を登録
	retry_button.pressed.connect(restart_game)
	title_button.pressed.connect(go_to_title)

# =========================================================
# 4. 毎フレーム実行されるタイマー処理（_process）
# =========================================================

func _process(delta):
	# ゲームオーバーでなければ、時間を減らします。
	if not is_game_over:
		game_time -= delta  # 経過時間(delta)分、残り時間を減らす
		
		# UIを更新します。
		update_ui()
		
		# ゴミの総数と現在のスコアが一致したらクリア
		if score >= TOTAL_TRASH_COUNT:
			game_clear()

		# 時間がゼロ以下になったらゲームオーバー
		if game_time <= 0.0:
			game_time = 0.0  # 時間を0に固定
			game_over()

# =========================================================
# 5. スコアを加算する関数（ゴミアイテムから呼ばれる）
# =========================================================

func add_score():
	if is_game_over:
		return
		
	score += 1
	
	# ゴミを拾うと時間を1秒回復させる（要件定義より）
	game_time += 1.0 
	
	update_ui()

# =========================================================
# 6. UI（画面の文字）を更新する関数
# =========================================================

func update_ui():
	score_label.text = "ゴミ：" + str(score)
	# 小数点以下1桁まで表示するようにフォーマットします
	timer_label.text = "定時まで：" + "%.1f" % game_time

# =========================================================
# 7. ゲームオーバー処理
# =========================================================

func game_over():
	is_game_over = true
	timer_label.text = "残業確定"
	show_result_ui("GAME OVER\n残業確定...")

# 上司に捕まったときのゲームオーバー処理
func game_over_by_boss():
	if is_game_over:
		return
		
	is_game_over = true
	print("--- GAME OVER! CAUGHT BY BOSS! ---")
	
	timer_label.text = "残業確定"
	show_result_ui("上司に捕まった！\n残業確定...")

# =========================================================
# 8. ゴミアイテムをランダムに配置する関数
# =========================================================

func spawn_trash_items():
	# 既存のゴミを削除
	for child in get_children():
		if child.name.begins_with("TrashItem"):
			child.queue_free()
	
	var spawned_count = 0
	var max_attempts = TOTAL_TRASH_COUNT * 10  # 無限ループ防止
	var attempt = 0
	
	while spawned_count < TOTAL_TRASH_COUNT and attempt < max_attempts:
		attempt += 1
		
		# ランダムな位置を決定
		var random_x = randf_range(-9.0, 9.0)
		var random_z = randf_range(-9.0, 9.0)
		var test_position = Vector3(random_x, 1.0, random_z)  # 高い位置から判定
		
		# その位置に障害物がないかチェック
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			test_position,  # 上から
			Vector3(random_x, 0.0, random_z)  # 下へ
		)
		query.collision_mask = 1  # レイヤー1（床や机）を検出
		
		var result = space_state.intersect_ray(query)
		
		# 床に当たった場合のみ配置（机の下には置かない）
		if result and result.collider.name.contains("Floor"):
			var trash_instance = trash_scene.instantiate()
			trash_instance.position = Vector3(random_x, 0.15, random_z)
			add_child(trash_instance)
			spawned_count += 1
	
	print("✅ ゴミを", spawned_count, "個配置しました")

# =========================================================
# 9. ゲームクリア処理
# =========================================================

func game_clear():
	is_game_over = true
	timer_label.text = "GAME CLEAR!"
	show_result_ui("定時に間に合った！\nおつかれさま！")






func show_result_ui(message: String):
	result_label.text = message
	result_ui.visible = true
	retry_button.grab_focus()  # 最初にフォーカスを当てておく（操作性向上）
	

func restart_game():
	get_tree().reload_current_scene()

func go_to_title():
	get_tree().change_scene_to_file("res://Title.tscn")
