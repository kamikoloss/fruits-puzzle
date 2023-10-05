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
var _current_fruit_id = 0
var _next_fruit_type = Global.FruitType.NONE
var _next_fruit_sprite = null

# UI
var _score_text = null
var _next_text = null

# ボタンの状態
var _is_button_left_down = false
var _is_button_right_down = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Signals
	Global.score_changed.connect(_on_score_changed)
	
	# UI
	_score_text = $"../UI/CanvasLayer/VBoxContainer/Header/MarginContainer/Texts/Score"
	_next_text = $"../UI/CanvasLayer/VBoxContainer/Header/MarginContainer/Texts/Next"
	_next_fruit_sprite = $"../UI/CanvasLayer/VBoxContainer/Header/NextFruit"
	_score_text.text = "SCORE: {0}".format([0])
	
	_choose_next_fruit()
	_create_new_fruit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move_fruit()


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
	
	# フルーツが落ちるまで少し待つ
	# TODO: フルーツが落ちたタイミングを判定する
	await get_tree().create_timer(FRUIT_DELAY_SECOND).timeout
	
	# 次のフルーツを作成する
	_create_new_fruit()


# スコア変更時の処理
func _on_score_changed(score):
	_score_text.text = "SCORE: {0}".format([score])


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
