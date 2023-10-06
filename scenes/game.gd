extends Node2D


const FRUIT_SCENE = preload("res://scenes/fruit.tscn")

const FRUIT_DEFAULT_TYPES = [
	Global.FruitType.CHERRY,
	Global.FruitType.STRAWBERRY,
	Global.FruitType.GRAPE,
	Global.FruitType.DEKOPON,
	Global.FruitType.PERSIMMON,
]

const DROPPER_MOVE_SPEED = 1.0 # px/frame
const DROPPER_POSITION_MIN = 60 # px
const DROPPER_POSITION_MAX = 300 # px
const DROPPER_FRUIT_MARGIN = 40 # px


var _current_fruit = null
var _current_fruit_id = 0
var _next_fruit_type = Global.FruitType.NONE

# ボタンの状態
var _is_button_left_down = false
var _is_button_right_down = false

# Node
var _dropper = null
var _score_text = null
var _next_text = null
var _next_fruit_sprite = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Node 取得
	_dropper = $Dropper
	_score_text = $"../UI/CanvasLayer/VBoxContainer/Header/MarginContainer/Texts/Score"
	_next_text = $"../UI/CanvasLayer/VBoxContainer/Header/MarginContainer/Texts/Next"
	_next_fruit_sprite = $"../UI/CanvasLayer/VBoxContainer/Header/NextFruit"
	
	# Signal 設定
	Global.score_changed.connect(_on_score_changed)
	
	# ゲームを開始する
	_start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move_dropper()


# スコア変更時の処理
func _on_score_changed(score):
	_score_text.text = "SCORE: {0}".format([score])


# DeadLine/Area2D 衝突時の処理
func _on_area_2d_body_entered(body):
	# 衝突相手が落下したフルーツの場合: ゲームを終了する
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
	
	_set_next_fruit()
	_create_new_fruit()
	
	print("Game is started!")


# ゲームを終了する
func _end_game():
	print("Game is ended!")


# 衝突相手が落下したフルーツかどうかを取得する
func _is_fell_fruit(body):
	# 衝突相手がフルーツではない場合
	if (!body.is_in_group("Fruit")):
		return false
	# 衝突相手がまだ落下していない場合
	if (!body.is_fell):
		return false
	# 衝突相手が落下したフルーツの場合
	return true


# 新しいフルーツを作成する
func _create_new_fruit():
	_current_fruit = FRUIT_SCENE.instantiate()
	_current_fruit.setup(_current_fruit_id, _next_fruit_type)
	_current_fruit_id += 1
	
	_current_fruit.position.x = _dropper.global_position.x
	_current_fruit.position.y = _dropper.global_position.y + DROPPER_FRUIT_MARGIN
	_current_fruit.freeze = true
	
	get_tree().root.get_node("Main/Fruits").add_child(_current_fruit)
	
	_set_next_fruit()


# 次のフルーツを選択する
func _set_next_fruit():
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


# クレーンおよびフルーツを左右に動かす
func _move_dropper():
	var _offset = Vector2(DROPPER_MOVE_SPEED, 0)
	if _is_button_left_down and _dropper.global_position.x > DROPPER_POSITION_MIN:
		_dropper.global_translate(_offset * -1)
	if _is_button_right_down and _dropper.global_position.x < DROPPER_POSITION_MAX:
		_dropper.global_translate(_offset)
	
	if _current_fruit == null:
		return
	
	# クレーンにフルーツがぶら下がっている場合は位置を同期させる
	_current_fruit.position.x = _dropper.global_position.x


# フルーツを落とす
func _drop_fruit():
	_current_fruit.freeze = false
	_current_fruit = null
