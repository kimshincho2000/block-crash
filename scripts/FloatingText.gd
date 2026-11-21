class_name FloatingText
extends Node2D

## Floating Score / Combo Banner Animation

@onready var label: Label = $Label

func setup(text: String, color: Color = Color.GOLD, scale_mult: float = 1.0) -> void:
	if not is_inside_tree():
		await ready
	label.text = text
	label.modulate = color
	scale = Vector2(0.5, 0.5) * scale_mult
	
	var tween = create_tween().set_parallel(true)
	# Pop scale
	tween.tween_property(self, "scale", Vector2.ONE * scale_mult, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Float upwards
	tween.tween_property(self, "position:y", position.y - 120.0, 0.85).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Fade out near end
	var fade_tween = create_tween()
	fade_tween.tween_interval(0.45)
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	await tween.finished
	queue_free()
