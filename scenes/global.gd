extends Node


signal score_changed
signal fruit_fell
signal fruit_conbined


# フルーツの種類
enum FruitType {
	NONE,
	CHERRY,
	STRAWBERRY,
	GRAPE,
	DEKOPON,
	PERSIMMON, # 柿
	APPLE,
	PEAR,
	PEACH,
	PINEAPPLE,
	MELON,
	WATERMELON,
}


# フルーツの大きさの基準
# 256 * FRUIT_DATA["scale"] / FRUIT_SIZE_BASE (px) になる
const FRUIT_SIZE_BASE = 224

# フルーツのデータ (名前, 点数, 大きさ, 色)
# ref. https://www.colordic.org/y
const FRUIT_DATA = {
	FruitType.CHERRY: { "name": "CHERRY", "score": 1, "scale": 16, "color": "#b33e5c" },
	FruitType.STRAWBERRY: { "name": "STRAWBERRY", "score": 2, "scale": 24, "color": "#e73562" },
	FruitType.GRAPE: { "name": "GRAPE", "score": 4, "scale": 32, "color": "#915da3" },
	FruitType.DEKOPON: { "name": "DEKOPON", "score": 8, "scale": 40, "color": "#fac559" },
	FruitType.PERSIMMON: { "name": "PERSIMMON", "score": 16, "scale": 48, "color": "#f3981d" },
	FruitType.APPLE: { "name": "APPLE", "score": 32, "scale": 56, "color": "#d70035" },
	FruitType.PEAR: { "name": "PEAR", "score": 64, "scale": 64, "color": "#fad09e" },
	FruitType.PEACH: { "name": "PEACH", "score": 128, "scale": 80, "color": "#f19ca7" },
	FruitType.PINEAPPLE: { "name": "PINEAPPLE", "score": 256, "scale": 96, "color": "#fcc800" },
	FruitType.MELON: { "name": "MELON", "score": 512, "scale": 112, "color": "#9fc24d" },
	FruitType.WATERMELON: { "name": "WATERMELON", "score": 1024, "scale": 128, "color": "#417038" },
}


# スコア
var score = 0:
	get:
		return score
	set(value):
		score = value
		score_changed.emit(value)
		print("Score is changed. ({0})".format([value]))
