extends Node2D

# Member
var id = 0
var type = 0
var score = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	apply_scale_to_children()


# 自身のスケールを子ノードに適用する
# ref. https://github.com/godotengine/godot/issues/5734
func apply_scale_to_children():
	get_node("RigidBody2D/Circle").scale *= scale
	get_node("RigidBody2D/CollisionShape2D").scale *= scale
	scale = Vector2.ONE
