extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_body_entered(body: Node3D) -> void:
	# ノードが「CharacterBody3D」（つまりプレイヤー）かどうかをチェックします。
	if body is CharacterBody3D:
		
		# 1. Mainノード（ゲーム全体を管理しているノード）を取得します。
		#    get_parent()でTrashItemの親（この場合Main）を取得します。
		var main_node = get_parent()
		
		# 2. 取得したノードが Mainノードであり、add_score関数を持っているか確認します。
		if main_node and main_node.has_method("add_score"):
			# スコア加算とタイマー回復の命令を Mainノードに送ります。
			main_node.add_score()
		
		# 3. ゴミアイテム自身をシーンから削除します。
		queue_free()
