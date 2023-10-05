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
const FRUIT_DELAY_SECOND = 1.0


# 現在/次のフルーツ
var _current_fruit = null
var _next_fruit = null
var _current_fruit_id = 0

# UI
var _text_score = null
var _text_next = null

# ボタンの状態
var _is_button_left_down = false
var _is_button_right_down = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Signals
	Global.score_changed.connect(_on_score_changed)
	
	# UI
	_text_score = $"../UI/CanvasLayer/VBoxContainer/Header/MarginContainer/Scores/TextScore"
	_text_next = $"../UI/CanvasLayer/VBoxContainer/Header/MarginContainer/Scores/TextNext"
	_text_score.text = "SCORE: {0}".format([0])
	
	_create_new_fruit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move_fruit()


func _on_button_left_button_down():
	_is_button_left_down = true


func _on_button_left_button_up():
	_is_button_left_down = false


func _on_button_right_button_down():
	_is_button_right_down = true


func _on_button_right_button_up():
	_is_button_right_down = false


func _on_button_drop_button_up():
	if _current_fruit == null:
		return
	
	# 現在のフルーツを落とす
	_drop_fruit()
	
	# フルーツが落ちるまで少し待つ
	# TODO: フルーツが落ちたタイミングを判定する
	await get_tree().create_timer(FRUIT_DELAY_SECOND).timeout
	
	# 次のフルーツを作成する
	_create_new_fruit()


# スコア変更時の処理
func _on_score_changed(score):
	_text_score.text = "SCORE: {0}".format([score])


# 新しいフルーツを生成する
# TODO: 引数でフルーツの種類を指定できるようにする
func _create_new_fruit():
	_current_fruit = FRUIT_SCENE.instantiate()

	var _new_type = FRUIT_DEFAULT_TYPES[randi() % FRUIT_DEFAULT_TYPES.size()]
	#_text_next.text = "NEXT: {0}.format(_new_type)"
	
	_current_fruit.setup(_current_fruit_id, _new_type)
	_current_fruit_id += 1
	_current_fruit.global_position = FRUIT_DEFAULT_POSITION
	_current_fruit.get_node("RigidBody2D").freeze = true
	get_tree().root.get_node("Main/Fruits").add_child(_current_fruit)


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
