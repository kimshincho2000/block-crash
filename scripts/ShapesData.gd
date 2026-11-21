class_name ShapesData
extends RefCounted

## Shape definitions and color palettes for Block Crash

# Predefined colors for blocks
const COLORS = [
	Color("#FFD11A"), # Shiny Gold/Yellow
	Color("#00D2FF"), # Bright Cyan/Blue
	Color("#FF3B30"), # Vibrant Red
	Color("#B026FF"), # Electric Purple
	Color("#34C759"), # Emerald Green
	Color("#FF9500"), # Energetic Orange
	Color("#007AFF"), # Royal Blue
]

# All available shapes defined as 2D boolean matrices [[row0], [row1], ...]
const SHAPES = [
	# 1x1 Single Dot
	{
		"matrix": [[1]],
		"name": "Dot_1x1"
	},
	# 2x1 Horizontal
	{
		"matrix": [[1, 1]],
		"name": "Line_2x1"
	},
	# 1x2 Vertical
	{
		"matrix": [[1], [1]],
		"name": "Line_1x2"
	},
	# 3x1 Horizontal
	{
		"matrix": [[1, 1, 1]],
		"name": "Line_3x1"
	},
	# 1x3 Vertical
	{
		"matrix": [[1], [1], [1]],
		"name": "Line_1x3"
	},
	# 4x1 Horizontal
	{
		"matrix": [[1, 1, 1, 1]],
		"name": "Line_4x1"
	},
	# 1x4 Vertical
	{
		"matrix": [[1], [1], [1], [1]],
		"name": "Line_1x4"
	},
	# 5x1 Horizontal
	{
		"matrix": [[1, 1, 1, 1, 1]],
		"name": "Line_5x1"
	},
	# 1x5 Vertical
	{
		"matrix": [[1], [1], [1], [1], [1]],
		"name": "Line_1x5"
	},
	# 2x2 Square
	{
		"matrix": [
			[1, 1],
			[1, 1]
		],
		"name": "Square_2x2"
	},
	# 3x3 Square (rare)
	{
		"matrix": [
			[1, 1, 1],
			[1, 1, 1],
			[1, 1, 1]
		],
		"name": "Square_3x3"
	},
	# Small L (2x2 with 3 blocks) - 4 Rotations
	{
		"matrix": [
			[1, 0],
			[1, 1]
		],
		"name": "L_Small_0"
	},
	{
		"matrix": [
			[0, 1],
			[1, 1]
		],
		"name": "L_Small_1"
	},
	{
		"matrix": [
			[1, 1],
			[1, 0]
		],
		"name": "L_Small_2"
	},
	{
		"matrix": [
			[1, 1],
			[0, 1]
		],
		"name": "L_Small_3"
	},
	# Big L (3x3 with 5 blocks) - 4 Rotations
	{
		"matrix": [
			[1, 0, 0],
			[1, 0, 0],
			[1, 1, 1]
		],
		"name": "L_Big_0"
	},
	{
		"matrix": [
			[0, 0, 1],
			[0, 0, 1],
			[1, 1, 1]
		],
		"name": "L_Big_1"
	},
	{
		"matrix": [
			[1, 1, 1],
			[1, 0, 0],
			[1, 0, 0]
		],
		"name": "L_Big_2"
	},
	{
		"matrix": [
			[1, 1, 1],
			[0, 0, 1],
			[0, 0, 1]
		],
		"name": "L_Big_3"
	},
	# T-Shape (3x2) - 4 Rotations
	{
		"matrix": [
			[1, 1, 1],
			[0, 1, 0]
		],
		"name": "T_0"
	},
	{
		"matrix": [
			[0, 1],
			[1, 1],
			[0, 1]
		],
		"name": "T_1"
	},
	{
		"matrix": [
			[0, 1, 0],
			[1, 1, 1]
		],
		"name": "T_2"
	},
	{
		"matrix": [
			[1, 0],
			[1, 1],
			[1, 0]
		],
		"name": "T_3"
	},
	# Z-Shape
	{
		"matrix": [
			[1, 1, 0],
			[0, 1, 1]
		],
		"name": "Z_0"
	},
	{
		"matrix": [
			[0, 1],
			[1, 1],
			[1, 0]
		],
		"name": "Z_1"
	},
	# S-Shape
	{
		"matrix": [
			[0, 1, 1],
			[1, 1, 0]
		],
		"name": "S_0"
	},
	{
		"matrix": [
			[1, 0],
			[1, 1],
			[0, 1]
		],
		"name": "S_1"
	}
]

static func get_random_shape() -> Dictionary:
	var shape_data = SHAPES[randi() % SHAPES.size()]
	var color = COLORS[randi() % COLORS.size()]
	return {
		"matrix": shape_data["matrix"],
		"name": shape_data["name"],
		"color": color
	}
