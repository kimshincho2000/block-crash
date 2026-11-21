class_name Cell
extends Node2D

## Single Cell on the 8x8 Grid

@export var cell_size: float = 110.0

@onready var bg_sprite: Sprite2D = $BgSprite
@onready var block_sprite: Sprite2D = $BlockSprite

var is_occupied: bool = false
var current_color: Color = Color.WHITE
var grid_x: int = 0
var grid_y: int = 0

func _ready() -> void:
	block_sprite.visible = false
	block_sprite.scale = Vector2.ONE

func set_occupied(occupied: bool, color: Color = Color.WHITE, animate: bool = false) -> void:
	is_occupied = occupied
	current_color = color
	if occupied:
		block_sprite.visible = true
		block_sprite.modulate = color
		if animate:
			# Bounce pop-in animation
			block_sprite.scale = Vector2(0.5, 0.5)
			var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(block_sprite, "scale", Vector2.ONE, 0.18)
		else:
			block_sprite.scale = Vector2.ONE
	else:
		block_sprite.visible = false
		block_sprite.scale = Vector2.ONE

func set_ghost(visible_ghost: bool, color: Color = Color.WHITE) -> void:
	if is_occupied:
		return
	if visible_ghost:
		block_sprite.visible = true
		# 45% alpha for ghost preview
		var ghost_col = color
		ghost_col.a = 0.45
		block_sprite.modulate = ghost_col
		block_sprite.scale = Vector2(0.95, 0.95)
	else:
		block_sprite.visible = false
		block_sprite.scale = Vector2.ONE

func play_clear_animation(delay: float = 0.0) -> void:
	if not is_occupied:
		return
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if delay > 0.0:
		tween.tween_interval(delay)
	
	# Flash white, scale up then shrink to 0
	tween.tween_property(block_sprite, "modulate", Color.WHITE, 0.08)
	tween.parallel().tween_property(block_sprite, "scale", Vector2(1.25, 1.25), 0.08)
	tween.tween_property(block_sprite, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	set_occupied(false)
