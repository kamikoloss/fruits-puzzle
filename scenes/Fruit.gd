extends Node2D


# Member
var _id = 0
var _type = Global.FruitType.NONE


# 初期化
# add_child() より前に呼ぶこと
func initialize(id, type):
	_id = id
	_type = type


# Called when the node enters the scene tree for the first time.
func _ready():
	_apply_scale()
	_apply_color()
	print("Fruit is created. (id: {id}, type: {type})".format({"id": _id, "type": Global.FRUIT_DATA[_type]["name"]}))


# 種類を元に自身のスケールを決定する
func _apply_scale():
	var _new_scale = float(Global.FRUIT_DATA[_type]["scale"]) / 256
	scale = Vector2(_new_scale, _new_scale)
	
	# 自身のスケールを子ノードに適用する (最後に戻す)
	# ref. https://github.com/godotengine/godot/issues/5734
	get_node("RigidBody2D/Circle").scale *= scale
	get_node("RigidBody2D/CollisionShape2D").scale *= scale
	scale = Vector2.ONE


# 種類を元に自身の色を決定する
func _apply_color():
	pass
