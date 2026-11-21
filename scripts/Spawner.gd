class_name Spawner
extends Node2D

## Piece Spawner for Block Crash

signal piece_picked(piece: Piece)
signal piece_moved(piece: Piece, target_pos: Vector2)
signal piece_placed(piece: Piece, target_pos: Vector2)
signal no_moves_left

@export var board: Board

var piece_scene: PackedScene = preload("res://scenes/Piece.tscn")
var slot_positions: Array[Vector2] = [
	Vector2(210, 0),
	Vector2(540, 0),
	Vector2(870, 0)
]

var active_pieces: Array[Piece] = [null, null, null]

func _ready() -> void:
	pass

func reset_spawner() -> void:
	for i in range(3):
		if active_pieces[i] != null and is_instance_valid(active_pieces[i]):
			active_pieces[i].queue_free()
		active_pieces[i] = null
	spawn_round()

func spawn_round() -> void:
	var spawned_any = false
	var guaranteed_placeable = false
	
	for i in range(3):
		var shape_info = ShapesData.get_random_shape()
		
		# If this is the last piece and none so far can be placed, force a placeable one if possible
		if i == 2 and not guaranteed_placeable and board != null:
			for attempt in range(20):
				if board.can_fit_anywhere(shape_info["matrix"]):
					guaranteed_placeable = true
					break
				shape_info = ShapesData.get_random_shape()
				
		if board != null and board.can_fit_anywhere(shape_info["matrix"]):
			guaranteed_placeable = true
			
		var piece_inst: Piece = piece_scene.instantiate()
		add_child(piece_inst)
		piece_inst.setup(shape_info["matrix"], shape_info["color"], i, slot_positions[i])
		
		piece_inst.drag_started.connect(_on_piece_drag_started)
		piece_inst.drag_moved.connect(_on_piece_drag_moved)
		piece_inst.drag_ended.connect(_on_piece_drag_ended)
		
		active_pieces[i] = piece_inst
		
		# Pop-in bounce animation
		piece_inst.scale = Vector2.ZERO
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_interval(i * 0.08)
		tween.tween_property(piece_inst, "scale", Vector2(Piece.SLOT_SCALE, Piece.SLOT_SCALE), 0.25)
		spawned_any = true

	check_game_over()

func _on_piece_drag_started(piece: Piece) -> void:
	piece_picked.emit(piece)

func _on_piece_drag_moved(piece: Piece, target_pos: Vector2) -> void:
	piece_moved.emit(piece, target_pos)

func _on_piece_drag_ended(piece: Piece, target_pos: Vector2) -> void:
	piece_placed.emit(piece, target_pos)

func remove_piece(piece: Piece) -> void:
	var idx = piece.slot_index
	if idx >= 0 and idx < 3:
		active_pieces[idx] = null
	piece.queue_free()
	
	# Check if all 3 pieces have been used
	var all_empty = true
	for p in active_pieces:
		if p != null and is_instance_valid(p):
			all_empty = false
			break
			
	if all_empty:
		spawn_round()
	else:
		check_game_over()

func check_game_over() -> void:
	if board == null:
		return
		
	var any_can_fit = false
	for p in active_pieces:
		if p != null and is_instance_valid(p):
			if board.can_fit_anywhere(p.matrix):
				any_can_fit = true
				break
				
	if not any_can_fit:
		# Check if any piece exists at all
		var has_pieces = false
		for p in active_pieces:
			if p != null and is_instance_valid(p):
				has_pieces = true
				break
		if has_pieces:
			no_moves_left.emit()
