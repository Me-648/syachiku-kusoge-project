extends Node3D

# =========================================================
# 1. ゲームの状態を保持する変数
# =========================================================

var score = 0                       # ゴミを拾った数（スコア）
var game_time = 20.0                # 制限時間（20秒からスタート）
var is_game_over = false            # ゲーム終了フラグ

const TOTAL_TRASH_COUNT = 10         # オフィスに配置するゴミの総数
var trash_scene = preload("res://TrashItem.tscn") # TrashItemシーンを事前に読み込む

var boss_voice_player : AudioStreamPlayer


# ボス長話関連
var boss_talk_list : Array = [
	"ちょっと話がある。今日の動き、正直言って見ていられなかった。どこをどう判断したらあんな流れになるのか理解できない。忙しいのは誰だって同じだが、あれほど段取りが乱れると全体が止まる。君の一手遅れが全部に響くんだよ。言い訳する前に、自分が引き起こした混乱を自覚してくれ。今日の結果が、今の君の実力だ。",
	"この前の書類の件、まだ片付いたと思うなよ。あれが引き金になって、今日も同じような遅れが起きた。確認不足で突っ走る癖、いつになったら直るんだ？慌てて手を動かして失敗して、また周囲がフォローする。その繰り返しだ。自分の未熟さを棚に上げるのはもうやめてくれ。丁寧にやる以前の問題だ。",
	"君の仕事に安定感がなさすぎる。判断がぶれるし、先回りもできていない。今日なんて、見ているこっちが冷や汗をかいたぞ。細かいポイントを放置して、後で慌てて拾いに戻る。そんな動きじゃ時間が足りなくて当然だ。優先順位も見えていないだろう。迷い続けるくらいなら、最初から手をつけないほうがマシだ。",
	"聞いておけ。業務の流れを理解しているなら、なぜそれが形にならない？日によって出来が違うのは致命的だ。能力以前に、気持ちの問題じゃないのか。今日の押し込みなんて、完全に崩れていたぞ。丁寧さが裏目に出ているどころか、ただの空回りだ。もう少し現実を見てペースを整えたらどうだ。",
	"前から気づいていたが、考え込みすぎなんだよ。そんなに迷って止まっていたら、そりゃ全体が遅れるに決まってる。今日もどうでもいい部分に延々こだわって、本当に大事な点を後回しにしただろう。決断力がないなら、せめて邪魔にならないように動くことを覚えてくれ。周りの足を引っ張っている自覚はあるのか？",
	"今日の遅れ方、見てて呆れたよ。手順が毎回違うし、その場しのぎで動くから余計に混乱するんだ。何度言えばわかる？手順は固定しろと。急いでるときほど基本に立ち返れと。君のやり方じゃ、どれだけ時間があっても足りない。自分で自分の足を引っ張るの、そろそろやめたらどうだ。",
	"慣れてきたつもりなんだろうが、それが完全に油断になっている。簡単な確認すら怠った結果が今日のあのザマだ。基本もできないのに応用ができるわけがない。大きなトラブルを防ぐのは、小さなチェックの積み重ねだと何度言った？ 君が省いたひと言が、後でどれだけの損失を生んでいるか理解してくれ。",
	"最近、周囲との連携が崩れてきているのが目に見えてわかる。声かけが遅い、確認がない、勝手な判断が増えている。今日みたいに時間が足りなくなるのも当然だ。ひとりで抱えて空回りするくらいなら、最初から相談しろ。周りの動きを見ないで仕事が回ると思うな。チームの足を引っ張っている自覚を持て。",
	"今日の遅れは、完全に君の視野の狭さが原因だ。目の前だけを見て突っ走って、全体の動きが止まったことに気づいていなかっただろ。集中してるつもりだろうが、それはただ周りを無視しているだけだ。自分の作業だけ完了して満足しているようじゃ話にならない。もっと状況を見て動け。できないなら仕事を減らすしかない。",
	"ずっと思っていたが、切り替えの遅さが致命的だ。ひとつ終わるたびに止まる、その無駄な間が積み重なって今日の遅れになった。流れを断ち切る動きしかしていない。時間が詰まる場面では、その弱点がはっきり露呈する。テンポよく次へ移れないなら、仕事が回るわけないだろう。君のペースに全体を合わせる余裕はないんだ。"
]

# タイプライター制御
var talk_text : String = ""
var talk_index : int = 0
var talk_speed : float = 0.06  # 1文字あたりの秒（初期値。声がある場合は調整可）
var is_talking : bool = false

# 実行中の会話に使うインデックス
var current_boss_talk_index : int = -1


# =========================================================
# 2. UIノードへのアクセス
# =========================================================

@onready var score_label = $CanvasLayer/Control/ScoreLabel
@onready var timer_label = $CanvasLayer/Control/TimerLabel

@onready var result_ui = $CanvasLayer/ResultUI
@onready var result_label = $CanvasLayer/ResultUI/ResultLabel
@onready var retry_button = $CanvasLayer/ResultUI/VBoxContainer/RetryButton
@onready var title_button = $CanvasLayer/ResultUI/VBoxContainer/TitleButton

# BossTalk 用ノード参照（CanvasLayer 内にある想定）
@onready var boss_ui = $CanvasLayer.get_node("BossTalkUI")         # Control ノード
@onready var boss_text_label = boss_ui.get_node("TextLabel")      # BossTalkUI の子 Label
@onready var boss_voice = $BossVoice                               # AudioStreamPlayer（Main直下に置く）
@onready var type_timer = $TypeTimer                               # Timer（Main直下に置く）


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

	# TypeTimer の timeout を接続（エディタで接続済みなら二重接続に注意）
	var callback = Callable(self, "_on_type_timer_timeout")
	if not type_timer.timeout.is_connected(callback):
		type_timer.timeout.connect(callback)


	# 乱数シード初期化（毎回違う会話を出すため）
	randomize()
	
	boss_voice_player = $CanvasLayer/BossTalkUI/AudioStreamPlayer


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
	$PickupSE.play()
	
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
	if is_game_over:
		return
	is_game_over = true
	game_time = 0.0
	timer_label.text = "残業確定"
	show_result_ui("GAME OVER\n残業確定...")
	# 効果音（通常）を鳴らす
	$GameOverSE.play()
	# 上司トークは開始しない

func game_over_by_boss():
	if is_game_over:
		return
	is_game_over = true
	timer_label.text = "残業確定"
	show_result_ui("上司に捕まった！\n残業確定...")
	# ゲームオーバー音（短い）を鳴らす
	$GameOverSE.play()
	# 同時にボスの長話を開始（音声があればそれも同時再生）
	_start_boss_talk()


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
	next_scene_path = get_tree().current_scene.scene_file_path
	$ClickSE.play()

func go_to_title():
	next_scene_path = "res://Title.tscn"
	$ClickSE.play()


var next_scene_path = ""

func _on_click_se_finished():
	if next_scene_path == "":
		return

	var path = next_scene_path
	next_scene_path = ""
	get_tree().change_scene_to_file(path)


# リザルトを即出す（既存の show_result_ui を使っている前提）
func _start_boss_talk():
	# boss_ui が取れているか確認（安全策）
	if boss_ui == null:
		print("ERROR: BossTalkUI not found at CanvasLayer/BossTalkUI")
		return

	# ランダムに選ぶ
	current_boss_talk_index = randi() % boss_talk_list.size()
	talk_text = boss_talk_list[current_boss_talk_index]
	talk_index = 0

	# 表示と初期化（キャッシュ変数を使う）
	boss_ui.visible = true
	boss_text_label.text = ""
	is_talking = true

	# ボイスファイルが用意してあるなら再生
	var voice_path = "res://sounds/boss_talk%d.ogg" % (current_boss_talk_index + 1)
	if ResourceLoader.exists(voice_path):
		boss_voice.stream = load(voice_path)
		boss_voice.play()
		# （必要なら talk_speed を voice length に合わせて調整する）
	else:
		# 声がない場合はデフォルトの速度
		pass

	# タイマー開始（type_timer を使う）
	type_timer.stop()
	type_timer.wait_time = talk_speed
	type_timer.start()

# TypeTimer の timeout に接続するハンドラ
func _on_type_timer_timeout() -> void:
	# safety
	if not is_talking:
		type_timer.stop()
		return

	if talk_index >= talk_text.length():
		is_talking = false
		type_timer.stop()
		return

	# 1文字追加して表示
	var ch = talk_text.substr(talk_index, 1)
	boss_text_label.text += ch
	talk_index += 1



func get_voice_path(index: int) -> String:
	var num = index + 1
	var padded = str(num).pad_zeros(4)  # → 1 → "0001"
	return "res://voice/yukumo_%s.mp3" % padded

func play_random_boss_talk():
	var index = randi() % boss_talk_list.size()
	var text = boss_talk_list[index]
	var voice = get_voice_path(index)

	start_boss_talk(text, voice)

func start_boss_talk(text: String, voice_path: String):
	var ui = $CanvasLayer/BossTalkUI

	# テキスト設定
	talk_text = text
	ui.get_node("TextLabel").text = ""
	talk_index = 0
	is_talking = true
	is_game_over = true

	# 音声読み込み
	var player = ui.get_node("VoicePlayer")
	var stream = load(voice_path)
	player.stream = stream
	player.play()

	# UI表示
	ui.visible = true
