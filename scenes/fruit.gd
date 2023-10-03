extends Node2D


const FRUIT_SCENE = preload("res://scenes/Fruit.tscn")

var id = 0
var type = Global.FruitType.NONE
var _data = null # FRUIT_DATA


# 初期化
# add_child() より前に呼ぶこと
func initialize(id, type):
	self.id = id
	self.type = type
	_data = Global.FRUIT_DATA[type]
	add_to_group("Fruit")


# Called when the node enters the scene tree for the first time.
func _ready():
	_apply_scale()
	_apply_color()
	print("Fruit is created. (id: {id}, type: {type})".format({"id": id, "type": _data["name"]}))


func _on_rigid_body_2d_body_entered(body):
	_convine_fruit(body)


# 種類を元に自身の大きさを適用する
func _apply_scale():
	var _new_scale = float(_data["scale"]) / 256
	scale = Vector2(_new_scale, _new_scale)
	
	# 自身のスケールを子ノードに適用する (最後に戻す)
	# ref. https://github.com/godotengine/godot/issues/5734
	get_node("RigidBody2D/Circle").scale *= scale
	get_node("RigidBody2D/CollisionShape2D").scale *= scale
	scale = Vector2.ONE


# 種類を元に自身の色を適用する
func _apply_color():
	get_node("RigidBody2D/Circle").modulate = Color(_data["color"])


# 同じ種類のフルーツを合体させる
func _convine_fruit(body):
	var _other_fruit = body.get_node("../")
	
	# 衝突相手がフルーツではない場合: 何もしない
	if (!_other_fruit.is_in_group("Fruit")):
		return
	# 衝突相手が違う種類の場合: 何もしない
	if (_other_fruit.type != type):
		return
	# 衝突相手が自分より古い場合: 何もしない
	if (_other_fruit.id > id):
		return
	# 衝突相手が同じ種類のフルーツで自分が古い場合: 合体処理を行う
	
	# スコアを加算する
	#Global.score += _data["score"]
	# 衝突相手と自分合体したフルーツを新しく生成する
	var _convined_fruit = FRUIT_SCENE.instantiate()
	_convined_fruit.initialize(id, type + 1)
	_convined_fruit.global_position = global_position.lerp(_other_fruit.global_position, 0.5)
	get_tree().root.get_node("Main/Fruits").add_child(_convined_fruit)
	print("Fruit is conviened. (id: {id1}, {id2})".format({"id1": _other_fruit.id, "id2": id}))
	# 衝突相手と自分を破棄する
	_other_fruit.queue_free()
	queue_free()
