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

# フルーツのデータ (名前, 点数, 大きさ, 色)
# ref. https://www.colordic.org/y
const FRUIT_DATA = {
	FruitType.CHERRY: { "name": "CHERRY", "score": 1, "scale": 16, "color": "#942343" },
	FruitType.STRAWBERRY: { "name": "STRAWBERRY", "score": 2, "scale": 32, "color": "#d70035" },
	FruitType.GRAPE: { "name": "GRAPE", "score": 4, "scale": 48, "color": "#56256e" },
	FruitType.DEKOPON: { "name": "DEKOPON", "score": 8, "scale": 64, "color": "#f6ae54" },
	FruitType.PERSIMMON: { "name": "PERSIMMON", "score": 16, "scale": 80, "color": "#f3981d" },
	FruitType.APPLE: { "name": "APPLE", "score": 32, "scale": 96, "color": "#d70035" },
	FruitType.PEAR: { "name": "PEAR", "score": 64, "scale": 112, "color": "#fad09e" },
	FruitType.PEACH: { "name": "PEACH", "score": 128, "scale": 128, "color": "#f19ca7" },
	FruitType.PINEAPPLE: { "name": "PINEAPPLE", "score": 256, "scale": 144, "color": "#fcc800" },
	FruitType.MELON: { "name": "MELON", "score": 512, "scale": 160, "color": "#65ab31" },
	FruitType.WATERMELON: { "name": "WATERMELON", "score": 1024, "scale": 176, "color": "#417038" },
}

# グローバル変数
var state = 0
var score = 0
