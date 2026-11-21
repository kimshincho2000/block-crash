class_name AudioManager
extends Node

## Audio Manager for Sound Effects in Block Crash

var is_muted: bool = false

var sound_pickup: AudioStream = preload("res://assets/sounds/pickup.wav")
var sound_place: AudioStream = preload("res://assets/sounds/place.wav")
var sound_clear: AudioStream = preload("res://assets/sounds/clear.wav")
var sound_combo: AudioStream = preload("res://assets/sounds/combo.wav")
var sound_gameover: AudioStream = preload("res://assets/sounds/gameover.wav")

var players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# Create pool of players for overlapping sounds
	for i in range(8):
		var p = AudioStreamPlayer.new()
		add_child(p)
		players.append(p)

func play_sound(stream: AudioStream, pitch_scale: float = 1.0) -> void:
	if is_muted or stream == null:
		return
	for p in players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = pitch_scale
			p.play()
			return
	# Fallback if all busy
	players[0].stream = stream
	players[0].pitch_scale = pitch_scale
	players[0].play()

func play_pickup() -> void:
	play_sound(sound_pickup, randf_range(0.95, 1.05))

func play_place() -> void:
	play_sound(sound_place, randf_range(0.95, 1.05))

func play_clear() -> void:
	play_sound(sound_clear, 1.0)

func play_combo(combo_level: int) -> void:
	# Higher pitch for higher combos!
	var pitch = 1.0 + (combo_level * 0.1)
	play_sound(sound_combo, min(1.8, pitch))

func play_gameover() -> void:
	play_sound(sound_gameover, 1.0)

func toggle_mute() -> bool:
	is_muted = not is_muted
	return is_muted
