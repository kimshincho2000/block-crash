class_name Board
extends Node2D

## 8x8 Game Grid Board for Block Crash

signal lines_cleared(line_count: int, cells_cleared: int, center_positions: Array)
signal block_placed(count: int)

const GRID_SIZE: int = 8
const CELL_SIZE: float = 112.0

var cell_scene: PackedScene = preload("res://scenes/Cell.tscn")
var cells: Array = [] # 2D array [x][y]
var current_ghost_coords: Array = []

func _ready() -> void:
	create_grid()

func create_grid() -> void:
	cells.clear()
	var offset_x = - (GRID_SIZE * CELL_SIZE) / 2.0 + (CELL_SIZE / 2.0)
	var offset_y = - (GRID_SIZE * CELL_SIZE) / 2.0 + (CELL_SIZE / 2.0)
	
	for x in range(GRID_SIZE):
		cells.append([])
		for y in range(GRID_SIZE):
			var cell_inst: Cell = cell_scene.instantiate()
			cell_inst.position = Vector2(offset_x + x * CELL_SIZE, offset_y + y * CELL_SIZE)
			cell_inst.grid_x = x
			cell_inst.grid_y = y
			add_child(cell_inst)
			cells[x].append(cell_inst)

func reset_board() -> void:
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			cells[x][y].set_occupied(false)
	clear_ghost()

## Converts a global world position to the nearest grid coordinate (top-left of shape)
func world_to_grid(world_pos: Vector2, shape_rows: int, shape_cols: int) -> Vector2i:
	var local_pos = to_local(world_pos)
	var offset_x = - (GRID_SIZE * CELL_SIZE) / 2.0 + (CELL_SIZE / 2.0)
	var offset_y = - (GRID_SIZE * CELL_SIZE) / 2.0 + (CELL_SIZE / 2.0)
	
	# Piece origin is centered, so calculate where top-left block lands
	var top_left_local_x = local_pos.x - ((shape_cols - 1) * CELL_SIZE / 2.0)
	var top_left_local_y = local_pos.y - ((shape_rows - 1) * CELL_SIZE / 2.0)
	
	var gx = roundi((top_left_local_x - offset_x) / CELL_SIZE)
	var gy = roundi((top_left_local_y - offset_y) / CELL_SIZE)
	
	return Vector2i(gx, gy)

## Checks if shape can be placed at grid coordinate (gx, gy)
func can_place(matrix: Array, gx: int, gy: int) -> bool:
	var rows = matrix.size()
	var cols = matrix[0].size()
	
	for r in range(rows):
		for c in range(cols):
			if matrix[r][c] == 1:
				var target_x = gx + c
				var target_y = gy + r
				
				# Out of bounds check
				if target_x < 0 or target_x >= GRID_SIZE or target_y < 0 or target_y >= GRID_SIZE:
					return false
				# Overlap check
				if cells[target_x][target_y].is_occupied:
					return false
	return true

## Shows ghost highlight preview under the dragging piece
func show_ghost(matrix: Array, color: Color, gx: int, gy: int) -> void:
	clear_ghost()
	if not can_place(matrix, gx, gy):
		return
		
	var rows = matrix.size()
	var cols = matrix[0].size()
	for r in range(rows):
		for c in range(cols):
			if matrix[r][c] == 1:
				var tx = gx + c
				var ty = gy + r
				cells[tx][ty].set_ghost(true, color)
				current_ghost_coords.append(Vector2i(tx, ty))

func clear_ghost() -> void:
	for coord in current_ghost_coords:
		cells[coord.x][coord.y].set_ghost(false)
	current_ghost_coords.clear()

## Places shape onto the grid
func place_piece(matrix: Array, color: Color, gx: int, gy: int) -> int:
	clear_ghost()
	var rows = matrix.size()
	var cols = matrix[0].size()
	var placed_count = 0
	
	for r in range(rows):
		for c in range(cols):
			if matrix[r][c] == 1:
				var tx = gx + c
				var ty = gy + r
				cells[tx][ty].set_occupied(true, color, true)
				placed_count += 1
				
	block_placed.emit(placed_count)
	return placed_count

## Checks and clears completed rows & columns
func check_and_clear_lines() -> Dictionary:
	var rows_to_clear: Array[int] = []
	var cols_to_clear: Array[int] = []
	
	# Check rows
	for y in range(GRID_SIZE):
		var full = true
		for x in range(GRID_SIZE):
			if not cells[x][y].is_occupied:
				full = false
				break
		if full:
			rows_to_clear.append(y)
			
	# Check columns
	for x in range(GRID_SIZE):
		var full = true
		for y in range(GRID_SIZE):
			if not cells[x][y].is_occupied:
				full = false
				break
		if full:
			cols_to_clear.append(x)
			
	var total_lines = rows_to_clear.size() + cols_to_clear.size()
	var cleared_cells_set: Dictionary = {}
	var center_positions: Array[Vector2] = []
	
	if total_lines > 0:
		for y in rows_to_clear:
			for x in range(GRID_SIZE):
				cleared_cells_set[Vector2i(x, y)] = true
		for x in cols_to_clear:
			for y in range(GRID_SIZE):
				cleared_cells_set[Vector2i(x, y)] = true
				
		var i = 0
		for coord in cleared_cells_set.keys():
			var cell = cells[coord.x][coord.y]
			center_positions.append(cell.global_position)
			cell.play_clear_animation(i * 0.015)
			i += 1
			
		lines_cleared.emit(total_lines, cleared_cells_set.size(), center_positions)
		
	return {
		"lines": total_lines,
		"cells": cleared_cells_set.size(),
		"centers": center_positions
	}

## Checks if a shape can fit anywhere on the current board
func can_fit_anywhere(matrix: Array) -> bool:
	var rows = matrix.size()
	var cols = matrix[0].size()
	
	for x in range(GRID_SIZE - cols + 1):
		for y in range(GRID_SIZE - rows + 1):
			if can_place(matrix, x, y):
				return true
	return false
