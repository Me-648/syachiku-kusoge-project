extends Node3D

# =========================================================
# 1. ゲーム状態
# =========================================================
var score: int = 0
var game_time: float = 20.0
var is_game_over: bool = false

const TOTAL_TRASH_COUNT := 10
var trash_scene := preload("res://TrashItem.tscn")


# =========================================================
# 2. ボス長話
# =========================================================
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

# タイプライター
var talk_text := ""
var talk_index := 0
var talk_speed := 0.12
var is_talking := false
var current_boss_talk_index := -1


# =========================================================
# 3. UIノード
# =========================================================
@onready var score_label = $CanvasLayer/Control/ScoreLabel
@onready var timer_label = $CanvasLayer/Control/TimerLabel

@onready var result_ui = $CanvasLayer/ResultUI
@onready var result_label = $CanvasLayer/ResultUI/ResultLabel
@onready var retry_button = $CanvasLayer/ResultUI/VBoxContainer/RetryButton
@onready var title_button = $CanvasLayer/ResultUI/VBoxContainer/TitleButton

@onready var boss_ui = $CanvasLayer/BossTalkUI
@onready var boss_text_label: Label = boss_ui.get_node("TextLabel")
@onready var boss_voice_player: AudioStreamPlayer = boss_ui.get_node("BossVoicePlayer")


@onready var type_timer: Timer = $TypeTimer


# =========================================================
# 4. 初期化
# =========================================================
func _ready():
	randomize()
	update_ui()
	spawn_trash_items()

	retry_button.pressed.connect(_on_retry_pressed)
	title_button.pressed.connect(_on_title_pressed)

	if not type_timer.timeout.is_connected(_on_type_timer_timeout):
		type_timer.timeout.connect(_on_type_timer_timeout)

	boss_ui.visible = false
	result_ui.visible = false


# =========================================================
# 5. メインループ
# =========================================================
func _process(delta: float):
	if is_game_over:
		return

	game_time -= delta
	update_ui()

	if score >= TOTAL_TRASH_COUNT:
		_game_clear()
	elif game_time <= 0.0:
		game_time = 0.0
		_game_over()


# =========================================================
# 6. スコア
# =========================================================
func add_score():
	if is_game_over:
		return
	score += 1
	game_time += 1.0
	$PickupSE.play()
	update_ui()


# =========================================================
# 7. UI更新
# =========================================================
func update_ui():
	score_label.text = "ゴミ：" + str(score)
	timer_label.text = "定時まで：" + "%.1f" % game_time


# =========================================================
# 8. ゲームオーバー
# =========================================================
func _game_over():
	if is_game_over:
		return

	is_game_over = true
	timer_label.text = "残業確定"
	_show_result("GAME OVER\n残業確定…")
	$GameOverSE.play()


func game_over_by_boss():
	if is_game_over:
		return

	is_game_over = true
	timer_label.text = "残業確定"
	_show_result("上司に捕まった！\n残業確定…")

	$GameOverSE.play()
	_start_boss_talk()


# =========================================================
# 9. ゴミ配置
# =========================================================
func spawn_trash_items():
	for child in get_children():
		if child.name.begins_with("TrashItem"):
			child.queue_free()

	var spawned := 0
	var attempts := 0
	var max_attempts := TOTAL_TRASH_COUNT * 10

	while spawned < TOTAL_TRASH_COUNT and attempts < max_attempts:
		attempts += 1
		var x = randf_range(-9.0, 9.0)
		var z = randf_range(-9.0, 9.0)

		var from = Vector3(x, 1.0, z)
		var to = Vector3(x, 0.0, z)

		var ray = PhysicsRayQueryParameters3D.create(from, to)
		ray.collision_mask = 1

		var hit = get_world_3d().direct_space_state.intersect_ray(ray)

		if hit and hit.collider.name.contains("Floor"):
			var t = trash_scene.instantiate()
			t.position = Vector3(x, 0.15, z)
			add_child(t)
			spawned += 1

	print("ゴミ配置：%d" % spawned)


# =========================================================
# 10. ゲームクリア
# =========================================================
func _game_clear():
	is_game_over = true
	timer_label.text = "GAME CLEAR!"
	_show_result("定時に間に合った！\nおつかれさま！")


# =========================================================
# 11. リザルト
# =========================================================
func _show_result(msg: String):
	result_label.text = msg
	result_ui.visible = true
	retry_button.grab_focus()


# =========================================================
# 12. シーン遷移
# =========================================================
var next_scene := ""

func _on_retry_pressed():
	next_scene = get_tree().current_scene.scene_file_path
	$ClickSE.play()

func _on_title_pressed():
	next_scene = "res://Title.tscn"
	$ClickSE.play()

func _on_click_se_finished():
	if next_scene != "":
		var path = next_scene
		next_scene = ""
		get_tree().change_scene_to_file(path)


# =========================================================
# 13. ボス長話開始
# =========================================================
func _start_boss_talk():
	current_boss_talk_index = randi() % boss_talk_list.size()
	talk_text = boss_talk_list[current_boss_talk_index]
	talk_index = 0
	is_talking = true

	boss_ui.visible = true
	boss_text_label.text = ""

	_play_boss_voice(current_boss_talk_index)

	type_timer.wait_time = talk_speed
	type_timer.start()


# =========================================================
# 14. タイプライター
# =========================================================
func _on_type_timer_timeout():
	if not is_talking:
		type_timer.stop()
		return

	if talk_index >= talk_text.length():
		is_talking = false
		type_timer.stop()
		return

	boss_text_label.text += talk_text.substr(talk_index, 1)
	talk_index += 1


# =========================================================
# 15. ボイス
# =========================================================
func _play_boss_voice(index: int):
	var path = "res://voice/yukumo_%04d.mp3" % (index + 1)
	print("VOICE TRY:", path)
	print("EXISTS:", ResourceLoader.exists(path))

	if not ResourceLoader.exists(path):
		return

	boss_voice_player.stream = load(path)
	print("STREAM:", boss_voice_player.stream)

	boss_voice_player.play()
	print("PLAY CALLED")
