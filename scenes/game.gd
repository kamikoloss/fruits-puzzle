extends Node2D


const FRUIT_SCENE = preload("res://scenes/fruit.tscn")
const CONBINE_SOUND = preload("res://sounds/小鼓（こつづみ）.mp3")
const GAME_OVER_SOUND = preload("res://sounds/琴の滑奏.mp3")

const FRUIT_DEFAULT_TYPES = [
	Global.FruitType.CHERRY,
	Global.FruitType.STRAWBERRY,
	Global.FruitType.GRAPE,
	Global.FruitType.DEKOPON,
	Global.FruitType.PERSIMMON,
]

const DROPPER_MOVE_SPEED = 100 # px/s
const DROPPER_POSITION_MIN = 60 # px
const DROPPER_POSITION_MAX = 300 # px
const DROPPER_FRUIT_MARGIN = 40 # px


var _is_game_active = false # ゲームが進行中か
var _current_fruit = null
var _current_fruit_id = 0
var _next_fruit_type = Global.FruitType.NONE
var _dead_fruit_id_list = []

# ボタンの状態
var _is_button_left_down = false
var _is_button_right_down = false

# Node
var _audio_player = null
var _dropper = null
var _fruits = null

var _score_label = null
var _next_label = null
var _next_sprite = null

var _menu_container = null # 開始時/リトライ時 兼用のメニュー
var _title_label = null
var _start_button = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Node 取得
	_audio_player = $AudioStreamPlayer2D
	_dropper = $Dropper
	_fruits = $Fruits
	
	_score_label = $"../UI/CanvasLayer/VBoxContainer/Header/MarginContainer/VBoxContainer/ScoreLabel"
	_next_label = $"../UI/CanvasLayer/VBoxContainer/Header/MarginContainer/VBoxContainer/NextLabel"
	_next_sprite = $"../UI/CanvasLayer/VBoxContainer/Header/NextSprite"
	
	_menu_container = $"../UI/CanvasLayer/VBoxContainer/Body/VBoxContainer"
	_title_label = $"../UI/CanvasLayer/VBoxContainer/Body/VBoxContainer/TitleLabel"
	_start_button = $"../UI/CanvasLayer/VBoxContainer/Body/VBoxContainer/StartButton"
	
	# 開始時のメニューを設定する
	_title_label.text = "FOOLUITS"
	_start_button.text = "START"
	
	# Signal 接続
	Global.score_changed.connect(_on_score_changed)
	Global.fruit_fell.connect(_on_fruit_fell)
	Global.fruit_conbined.connect(_on_fruit_conbined)
	
	_is_game_active = false
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move_dropper(delta)


# スコア変更時の処理
func _on_score_changed(score):
	_score_label.text = "SCORE: {0}".format([score])


# フルーツ落下時の処理
func _on_fruit_fell(fruit_id):
	# 落下したフルーツが DeadLine に触れている場合: ゲームを終了する
	if (fruit_id in _dead_fruit_id_list):
		_end_game()


# フルーツ合体時の処理
func _on_fruit_conbined(fruit_id):
	# ゲーム進行中ではない場合: 何もしない
	# ゲーム終了時の音を優先するため
	if !_is_game_active:
		return
	
	# SE を鳴らす
	_audio_player.stop()
	_audio_player.stream = CONBINE_SOUND
	_audio_player.play()


# DeadLine/Area2D に触れたときの処理
func _on_area_2d_body_entered(body):
	var _fruit = body.get_node("../")
	
	# 触れた相手がフルーツの場合: ID をリストに追加する
	if (_fruit.is_in_group("Fruit")):
		_dead_fruit_id_list.append(_fruit.id)
		# 触れた相手が既に落下していた場合: ゲームを終了する
		# せりあがって触れたときや飛び上がって触れたときを考慮している
		if (_fruit.is_fell):
			_end_game()


# DeadLine/Area2D から離れたときの処理
func _on_area_2d_body_exited(body):
	var _fruit = body.get_node("../")
	
	# 触れた相手がフルーツの場合: ID をリストから削除する
	if (_fruit.is_in_group("Fruit")):
		_dead_fruit_id_list.erase(_fruit.id)


func _on_start_button_up():
	# ゲームを開始する
	_start_game()


func _on_left_button_down():
	_is_button_left_down = true


func _on_left_button_up():
	_is_button_left_down = false


func _on_right_button_down():
	_is_button_right_down = true


func _on_right_button_up():
	_is_button_right_down = false


func _on_drop_button_up():
	if !_is_game_active:
		return
	if _current_fruit == null:
		return
	
	# 現在のフルーツを落とす
	_drop_fruit()
	# 空から振ってきたフルーツが落下するまで待つ
	await Global.fruit_fell_from_sky
	
	if !_is_game_active:
		return
	
	# 次のフルーツを作成する
	_create_new_fruit()


# ゲームを開始する (リセット処理も含む)
func _start_game():
	_menu_container.hide()
	
	_reset_game()
	_set_next_fruit()
	_create_new_fruit()
	
	_is_game_active = true
	set_process(true)
	
	print("Game is started!")


# ゲームを終了する
func _end_game():
	_is_game_active = false
	set_process(false)
	
	# バケツ内のフルーツをすべて静止させる
	for _fruit in _fruits.get_children():
		_fruit.rb.sleeping = true
	
	# SE を鳴らす
	_audio_player.stop()
	_audio_player.stream = GAME_OVER_SOUND
	_audio_player.play()
	
	# リトライ時のメニューを設定する
	_title_label.text = "GAME OVER"
	_start_button.text = "RETRY"
	_menu_container.show()
	
	print("Game is ended!")


# ゲームを初期状態にする
func _reset_game():
	# Grobal
	Global.score = 0
	
	# Private
	_current_fruit = null
	_current_fruit_id = 0
	_next_fruit_type = Global.FruitType.NONE
	_dead_fruit_id_list = []
	
	# バケツ内のフルーツをすべて破棄する
	for _fruit in _fruits.get_children():
		_fruits.remove_child(_fruit)
		_fruit.queue_free()


# 新しいフルーツを作成する
func _create_new_fruit():
	_current_fruit = FRUIT_SCENE.instantiate()
	_current_fruit.setup(_current_fruit_id, _next_fruit_type)
	_current_fruit_id += 1
	
	_current_fruit.rb.position.x = _dropper.position.x
	_current_fruit.rb.position.y = _dropper.position.y + DROPPER_FRUIT_MARGIN
	_current_fruit.rb.freeze = true
	
	get_tree().root.get_node("Main/Game/Fruits").add_child(_current_fruit)
	
	_set_next_fruit()


# 次のフルーツを選択する
func _set_next_fruit():
	# 次のフルーツの種類を抽選する
	_next_fruit_type = FRUIT_DEFAULT_TYPES[randi() % FRUIT_DEFAULT_TYPES.size()]
	var _next_fruit_data = Global.FRUIT_DATA[_next_fruit_type]
	
	# 次のフルーツの文字を更新する
	var _next_fruit_name = _next_fruit_data["name"]
	_next_label.text = "NEXT: {0}".format([_next_fruit_name])
	
	# 次のフルーツの画像を更新する
	var _next_scale = float(_next_fruit_data["scale"]) / Global.FRUIT_SIZE_BASE
	_next_sprite.scale = Vector2(_next_scale, _next_scale)
	_next_sprite.get_node("Circle").modulate = Color(_next_fruit_data["color"])
	_next_sprite.get_node("Label").text = str(_next_fruit_data["score"])


# クレーンおよびフルーツを左右に動かす
func _move_dropper(delta):
	var _offset = Vector2(delta * DROPPER_MOVE_SPEED, 0)
	if _is_button_left_down and _dropper.position.x > DROPPER_POSITION_MIN:
		_dropper.translate(_offset * -1)
	if _is_button_right_down and _dropper.position.x < DROPPER_POSITION_MAX:
		_dropper.translate(_offset)
	
	if _current_fruit == null:
		return
	
	# クレーンにフルーツがぶら下がっている場合は位置を同期させる
	_current_fruit.rb.position.x = _dropper.position.x


# フルーツを落とす
func _drop_fruit():
	_current_fruit.rb.freeze = false
	_current_fruit = null
