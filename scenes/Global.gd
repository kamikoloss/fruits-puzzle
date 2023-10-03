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

# フルーツのデータ (名前, 点数, 大きさ)
const FRUIT_DATA = {
	FruitType.CHERRY: { "name": "CHERRY", "score": 1, "scale": 16 },
	FruitType.STRAWBERRY: { "name": "STRAWBERRY", "score": 2, "scale": 32 },
	FruitType.GRAPE: { "name": "GRAPE", "score": 4, "scale": 48 },
	FruitType.DEKOPON: { "name": "DEKOPON", "score": 8, "scale": 64 },
	FruitType.PERSIMMON: { "name": "PERSIMMON", "score": 16, "scale": 80 },
	FruitType.APPLE: { "name": "APPLE", "score": 32, "scale": 96 },
	FruitType.PEAR: { "name": "PEAR", "score": 64, "scale": 112 },
	FruitType.PEACH: { "name": "PEACH", "score": 128, "scale": 128 },
	FruitType.PINEAPPLE: { "name": "PINEAPPLE", "score": 256, "scale": 144 },
	FruitType.MELON: { "name": "MELON", "score": 512, "scale": 160 },
	FruitType.WATERMELON: { "name": "WATERMELON", "score": 1024, "scale": 176 },
}
