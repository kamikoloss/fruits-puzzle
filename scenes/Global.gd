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
const FRUIT_DATA = {
	FruitType.CHERRY: { "name": "CHERRY", "score": 1, "scale": 16, "color": "#8b0000" },
	FruitType.STRAWBERRY: { "name": "STRAWBERRY", "score": 2, "scale": 32, "color": "#b22222" },
	FruitType.GRAPE: { "name": "GRAPE", "score": 4, "scale": 48, "color": "#9370db" },
	FruitType.DEKOPON: { "name": "DEKOPON", "score": 8, "scale": 64, "color": "#f4a460" },
	FruitType.PERSIMMON: { "name": "PERSIMMON", "score": 16, "scale": 80, "color": "#ff8c00" },
	FruitType.APPLE: { "name": "APPLE", "score": 32, "scale": 96, "color": "#dc143c" },
	FruitType.PEAR: { "name": "PEAR", "score": 64, "scale": 112, "color": "#f0e68c" },
	FruitType.PEACH: { "name": "PEACH", "score": 128, "scale": 128, "color": "#ffb6c1" },
	FruitType.PINEAPPLE: { "name": "PINEAPPLE", "score": 256, "scale": 144, "color": "#ffd700" },
	FruitType.MELON: { "name": "MELON", "score": 512, "scale": 160, "color": "#9acd32" },
	FruitType.WATERMELON: { "name": "WATERMELON", "score": 1024, "scale": 176, "color": "#32cd32" },
}
