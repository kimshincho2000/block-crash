class_name Piece
extends Node2D

## Draggable Shape Piece for Block Crash

signal drag_started(piece: Piece)
signal drag_moved(piece: Piece, target_pos: Vector2)
signal drag_ended(piece: Piece, target_pos: Vector2)

const CELL_SIZE: float = 112.0
const SLOT_SCALE: float = 0.55
const DRAG_SCALE: float = 1.0
const FINGER_OFFSET: float = 180.0 # Floats above finger on touch screen

var matrix: Array = []
var color: Color = Color.WHITE
var slot_index: int = 0
var slot_position: Vector2 = Vector2.ZERO

var is_dragging: bool = false
var touch_id: int = -1
var blocks: Array[Sprite2D] = []
var block_texture: Texture2D = preload("res://assets/block.png")

var shape_width_px: float = 0.0
var shape_height_px: float = 0.0

func setup(shape_matrix: Array, shape_color: Color, index: int, slot_pos: Vector2) -> void:
	matrix = shape_matrix
	color = shape_color
	slot_index = index
	slot_position = slot_pos
	position = slot_pos
	scale = Vector2(SLOT_SCALE, SLOT_SCALE)
	
	build_visuals()

func build_visuals() -> void:
	# Clear previous blocks
	for b in blocks:
		b.queue_free()
	blocks.clear()
	
	var rows = matrix.size()
	var cols = matrix[0].size()
	shape_width_px = cols * CELL_SIZE
	shape_height_px = rows * CELL_SIZE
	
	# Center shape around piece origin (0, 0)
	var offset_x = - (cols * CELL_SIZE) / 2.0 + (CELL_SIZE / 2.0)
	var offset_y = - (rows * CELL_SIZE) / 2.0 + (CELL_SIZE / 2.0)
	
	for r in range(rows):
		for c in range(cols):
			if matrix[r][c] == 1:
				var sprite = Sprite2D.new()
				sprite.texture = block_texture
				sprite.scale = Vector2(CELL_SIZE / 128.0, CELL_SIZE / 128.0)
				sprite.modulate = color
				sprite.position = Vector2(offset_x + c * CELL_SIZE, offset_y + r * CELL_SIZE)
				add_child(sprite)
				blocks.append(sprite)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if not is_dragging and touch_id == -1:
				if is_point_inside(event.position):
					touch_id = event.index
					start_drag(event.position)
		else:
			if is_dragging and event.index == touch_id:
				end_drag(event.position)
				touch_id = -1
				
	elif event is InputEventScreenDrag:
		if is_dragging and event.index == touch_id:
			update_drag(event.position)
			
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_dragging:
				if is_point_inside(event.position):
					touch_id = 999
					start_drag(event.position)
			elif not event.pressed and is_dragging and touch_id == 999:
				end_drag(event.position)
				touch_id = -1
				
	elif event is InputEventMouseMotion:
		if is_dragging and touch_id == 999:
			update_drag(event.position)

func is_point_inside(point: Vector2) -> bool:
	var local_point = to_local(point)
	var half_w = (shape_width_px * 0.7)
	var half_h = (shape_height_px * 0.7)
	var hit_rect = Rect2(-half_w, -half_h, half_w * 2.0, half_h * 2.0)
	return hit_rect.has_point(local_point)

func start_drag(touch_pos: Vector2) -> void:
	is_dragging = true
	z_index = 100
	
	# Smoothly scale up to 1.0 (real game board size)
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(DRAG_SCALE, DRAG_SCALE), 0.12)
	
	global_position = touch_pos + Vector2(0, -FINGER_OFFSET)
	drag_started.emit(self)
	drag_moved.emit(self, global_position)

func update_drag(touch_pos: Vector2) -> void:
	global_position = touch_pos + Vector2(0, -FINGER_OFFSET)
	drag_moved.emit(self, global_position)

func end_drag(touch_pos: Vector2) -> void:
	is_dragging = false
	var target_pos = touch_pos + Vector2(0, -FINGER_OFFSET)
	drag_ended.emit(self, target_pos)

func return_to_slot() -> void:
	z_index = 10
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", slot_position, 0.22)
	tween.parallel().tween_property(self, "scale", Vector2(SLOT_SCALE, SLOT_SCALE), 0.22)
