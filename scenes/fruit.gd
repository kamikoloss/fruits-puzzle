extends Node2D


const FRUIT_SCENE = preload("res://scenes/fruit.tscn")


var id = 0
var type = Global.FruitType.NONE
# フルーツが空から振ってきたものか
# 合体してできたものは false となる 
var is_from_sky = true
# フルーツが落下したか
var is_fell = false

# Node
var rb = null # Rigidbody2D 露出用
var _score_label = null

var _data = null # FRUIT_DATA のショートカット用


# 初期化
# add_child() より前に呼ぶこと
func setup(_id, _type):
	# Node 取得
	rb = $RigidBody2D
	_score_label = $RigidBody2D/Label
	
	id = _id
	type = _type
	_data = Global.FRUIT_DATA[type]
	_score_label.text = str(_data["score"])
	
	add_to_group("Fruit")


# Called when the node enters the scene tree for the first time.
func _ready():
	_apply_scale()
	_apply_color()
	
	print("Fruit is created. (id: {id}, type: {type})".format({"id": id, "type": _data["name"]}))


func _on_rigid_body_2d_body_entered(body):
	# 触れた相手がまだ落下していないフルーツ (今から落とされるフルーツ) の場合: 何もしない
	var _fruit = body.get_node("../")	
	if (_fruit.is_in_group("Fruit") and !_fruit.is_fell):
		return
	
	# 触れた相手が自分と同じ種類の自分より若いフルーツの場合: 合体する
	if (_is_same_fresh_fruit(body)):
		_conbine_fruits(body)
		# 合体したときも空から落下した扱いとする
		if (!is_fell && is_from_sky):
			Global.fruit_fell_from_sky.emit(id)
		# fruit_fell 時にゲームオーバーの判定が行われる
		# 合体したフルーツでゲームオーバーにならないように呼ばないようにする
		return
	
	# 初めて何かに触れた = 落下した
	if (!is_fell):
		is_fell = true
		Global.fruit_fell.emit(id)
		# 空から振ってきた場合
		if (is_from_sky):
			Global.fruit_fell_from_sky.emit(id)


# 種類を元に自身の大きさを適用する
func _apply_scale():
	var _new_scale = float(_data["scale"]) / Global.FRUIT_SIZE_BASE
	scale = Vector2(_new_scale, _new_scale)
	
	# 自身のスケールを子ノードに適用したあと自身のスケールをデフォルトに戻す
	# ref. https://github.com/godotengine/godot/issues/5734
	get_node("RigidBody2D/Circle").scale *= scale
	get_node("RigidBody2D/CollisionShape2D").scale *= scale
	_score_label.scale *= scale
	scale = Vector2.ONE


# 種類を元に自身の色を適用する
func _apply_color():
	get_node("RigidBody2D/Circle").modulate = Color(_data["color"])


# フルーツを合体させる
func _conbine_fruits(body):
	var _other_fruit = body.get_node("../")
	
	# スコアを加算する
	Global.score += _data["score"]
	
	# 衝突相手と自分を破棄する
	_other_fruit.queue_free()
	queue_free()
	
	# 自分が最大のフルーツの場合: ここで終了する (新しいフルーツを生成しない)
	if (type == Global.FruitType.WATERMELON):
		return
	
	# 自分の一段階上のフルーツを新しく生成する
	var _conbined_fruit = FRUIT_SCENE.instantiate()
	_conbined_fruit.setup(id, type + 1)
	_conbined_fruit.is_from_sky = false
	_conbined_fruit.rb.position = rb.position.lerp(_other_fruit.rb.position, 0.5)
	get_tree().root.get_node("Main/Game/Fruits").add_child(_conbined_fruit)
	
	Global.fruit_conbined.emit(id)
	
	print("Fruits are conbined. (id: {id1}, {id2})".format({"id1": _other_fruit.id, "id2": id}))


# 触れた相手が自分と同じ種類の自分より若いフルーツかどうかを取得する
func _is_same_fresh_fruit(body):
	var _fruit = body.get_node("../")
	
	# 触れた相手がフルーツではない場合
	if (!_fruit.is_in_group("Fruit")):
		return false
	# 触れた相手が違う種類の場合
	if (_fruit.type != type):
		return false
	# 触れた相手が自分より古い場合
	# 自分自身と無限に合体するバグがあるため ">" ではなく ">=" とする
	if (_fruit.id >= id):
		return false
	# 触れた相手が自分と同じ種類の自分より若いフルーツの場合
	return true
