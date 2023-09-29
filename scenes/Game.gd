extends Node2D


# Fruit
var FRUIT_SCENE = preload("res://scenes/Fruit.tscn")
var current_fruit = null
var next_fruit = null
const FRUIT_DEFAULT_POSITION = Vector2i(180, 160)
const FRUIT_MOVE_SPEED = 1 # px/frame
const FRUIT_DELAY_SECOND = 1
# Button
var is_button_left_down = false
var is_button_right_down = false
# Score
var score = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	create_new_fruit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_fruit()


# 新しいフルーツを生成する
# TODO: 引数でフルーツの種類を指定できるようにする
func create_new_fruit():
	current_fruit = FRUIT_SCENE.instantiate()
	current_fruit.global_position = FRUIT_DEFAULT_POSITION
	current_fruit.scale = Vector2(0.125, 0.125)
	current_fruit.get_node("RigidBody2D").freeze = true
	add_child(current_fruit)


# フルーツを左右に動かす
func move_fruit():
	var offset = Vector2(FRUIT_MOVE_SPEED, 0)
	if is_button_left_down:
		current_fruit.global_translate(offset * -1)
	if is_button_right_down:
		current_fruit.global_translate(offset)


# フルーツを落とす
func drop_fruit():
	current_fruit.get_node("RigidBody2D").freeze = false
	current_fruit = null


# Events
func _on_button_left_button_down():
	is_button_left_down = true


func _on_button_left_button_up():
	is_button_left_down = false


func _on_button_right_button_down():
	is_button_right_down = true


func _on_button_right_button_up():
	is_button_right_down = false


func _on_button_drop_button_up():
	if current_fruit == null:
		return

	# 現在のフルーツを落とす
	drop_fruit()
	# フルーツが落ちるまで少し待つ
	await get_tree().create_timer(FRUIT_DELAY_SECOND).timeout
	# 次のフルーツを作成する
	create_new_fruit()
