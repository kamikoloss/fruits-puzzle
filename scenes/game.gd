extends Node2D


const FRUIT_SCENE = preload("res://scenes/fruit.tscn")
const FRUIT_DEFAULT_POSITION = Vector2i(180, 160)
const FRUIT_DEFAULT_TYPES = [
	Global.FruitType.CHERRY,
	Global.FruitType.STRAWBERRY,
	Global.FruitType.GRAPE,
	Global.FruitType.DEKOPON,
	Global.FruitType.PERSIMMON,
]
const FRUIT_MOVE_SPEED = 1.0 # px/frame


var _current_fruit = null
var _current_fruit_id = 0
var _next_fruit_type = Global.FruitType.NONE

# ボタンの状態
var _is_button_left_down = false
var _is_button_right_down = false

# Node
var _score_text = null
var _next_text = null
var _next_fruit_sprite = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Node 取得
	_score_text = $"../UI/CanvasLayer/VBoxContainer/Header/MarginContainer/Texts/Score"
	_next_text = $"../UI/CanvasLayer/VBoxContainer/Header/MarginContainer/Texts/Next"
	_next_fruit_sprite = $"../UI/CanvasLayer/VBoxContainer/Header/NextFruit"
	
	# Signal 設定
	Global.score_changed.connect(_on_score_changed)

	_start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move_fruit()


# スコア変更時の処理
func _on_score_changed(score):
	_score_text.text = "SCORE: {0}".format([score])


# DeadLine/Area2D 衝突時の処理
func _on_area_2d_body_entered(body):
	if (_is_fell_fruit(body)):
		_end_game()


func _on_left_button_down():
	_is_button_left_down = true


func _on_left_button_up():
	_is_button_left_down = false


func _on_right_button_down():
	_is_button_right_down = true


func _on_right_button_up():
	_is_button_right_down = false


func _on_drop_button_up():
	if _current_fruit == null:
		return
	
	# 現在のフルーツを落とす
	_drop_fruit()
	# フルーツが落下するまで待つ
	await Global.fruit_fell
	# 次のフルーツを作成する
	_create_new_fruit()


# ゲームを開始する (リセット処理も含む)
func _start_game():
	# リセット処理
	_current_fruit = null
	_current_fruit_id = 0
	_next_fruit_type = Global.FruitType.NONE
	Global.score = 0
	_score_text.text = "SCORE: {0}".format([0])
	
	_choose_next_fruit()
	_create_new_fruit()
	print("Game is started!")


# ゲームを終了する
func _end_game():
	print("Game is ended!")


# 衝突相手が落下したフルーツかどうかを取得する
func _is_fell_fruit(body):
	var _fruit = body.get_node("../")
	
	# 衝突相手がフルーツではない場合
	if (!_fruit.is_in_group("Fruit")):
		return false
	# 衝突相手がまだ落下していない場合
	if (!_fruit.is_fell):
		return false
	
	return true


# 新しいフルーツを作成する
func _create_new_fruit():
	_current_fruit = FRUIT_SCENE.instantiate()
	_current_fruit.setup(_current_fruit_id, _next_fruit_type)
	_current_fruit_id += 1
	_current_fruit.global_position = FRUIT_DEFAULT_POSITION
	_current_fruit.get_node("RigidBody2D").freeze = true
	get_tree().root.get_node("Main/Fruits").add_child(_current_fruit)
	
	_choose_next_fruit()


# 次のフルーツを選択する
func _choose_next_fruit():
	# 次のフルーツの種類を抽選する
	_next_fruit_type = FRUIT_DEFAULT_TYPES[randi() % FRUIT_DEFAULT_TYPES.size()]
	var _next_fruit_data = Global.FRUIT_DATA[_next_fruit_type]
	
	# 次のフルーツの文字を更新する
	var _next_fruit_name = _next_fruit_data["name"]
	_next_text.text = "NEXT: {0}".format([_next_fruit_name])
	
	# 次のフルーツの画像を更新する
	var _next_scale = float(_next_fruit_data["scale"]) / 256
	_next_fruit_sprite.scale = Vector2(_next_scale, _next_scale)
	_next_fruit_sprite.modulate = Color(_next_fruit_data["color"])


# フルーツを左右に動かす
func _move_fruit():
	if _current_fruit == null:
		return
	
	var _offset = Vector2(FRUIT_MOVE_SPEED, 0)
	if _is_button_left_down:
		_current_fruit.global_translate(_offset * -1)
	if _is_button_right_down:
		_current_fruit.global_translate(_offset)


# フルーツを落とす
func _drop_fruit():
	_current_fruit.get_node("RigidBody2D").freeze = false
	_current_fruit = null

