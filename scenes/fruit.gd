extends Node2D


const FRUIT_SCENE = preload("res://scenes/fruit.tscn")

# フルーツのサイズ (分母)
const FRUIT_SIZE_BASE = 256


var id = 0
var type = Global.FruitType.NONE
# フルーツが落下したか
var is_fell = false
var _data = null # FRUIT_DATA


# 初期化
# add_child() より前に呼ぶこと
func setup(_id, _type):
	id = _id
	type = _type
	_data = Global.FRUIT_DATA[type]
	add_to_group("Fruit")


# Called when the node enters the scene tree for the first time.
func _ready():
	_apply_scale()
	_apply_color()
	
	print("Fruit is created. (id: {id}, type: {type})".format({"id": id, "type": _data["name"]}))


func _on_body_entered(body):
	# 初めて何かに衝突した = 落下した
	if (!is_fell):
		is_fell = true
		Global.fruit_fell.emit(id)
	
	_conbine_fruits(body)


# 種類を元に自身の大きさを適用する
func _apply_scale():
	var _new_scale = float(_data["scale"]) / FRUIT_SIZE_BASE
	scale = Vector2(_new_scale, _new_scale)
	
	# 自身のスケールを子ノードに適用したあと自身のスケールをデフォルトに戻す
	# ref. https://github.com/godotengine/godot/issues/5734
	get_node("Circle").scale *= scale
	get_node("CollisionShape2D").scale *= scale
	scale = Vector2.ONE


# 種類を元に自身の色を適用する
func _apply_color():
	get_node("Circle").modulate = Color(_data["color"])


# 同じ種類のフルーツを合体させる
func _conbine_fruits(body):
	# 衝突相手がフルーツではない場合: 何もしない
	if (!body.is_in_group("Fruit")):
		return
	# 衝突相手が違う種類の場合: 何もしない
	if (body.type != type):
		return
	# 衝突相手が自分より古い場合: 何もしない
	# 自分自身と無限に合体するバグがあるため ">" ではなく ">=" とする
	if (body.id >= id):
		return
	# 衝突相手が同じ種類のフルーツで自分が古い場合: 合体処理を行う
	
	# スコアを加算する
	Global.score += _data["score"]
	
	# 衝突相手と自分を破棄する
	body.queue_free()
	queue_free()
	
	# 自分が最大のフルーツの場合: ここで終了する (新しいフルーツを生成しない)
	if (type == Global.FruitType.WATERMELON):
		return
	
	# 自分の一段階上のフルーツを新しく生成する
	var _conbined_fruit = FRUIT_SCENE.instantiate()
	_conbined_fruit.setup(id, type + 1)
	_conbined_fruit.position = position.lerp(body.position, 0.5)
	get_tree().root.get_node("Main/Fruits").add_child(_conbined_fruit)
	
	print("Fruits are conbined. (id: {id1}, {id2})".format({"id1": body.id, "id2": id}))
