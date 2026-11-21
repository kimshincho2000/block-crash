class_name Main
extends Node2D

## Main Game Controller for Block Crash

const SAVE_PATH: String = "user://block_crash_save.json"

@onready var board: Board = $Board
@onready var spawner: Spawner = $Spawner
@onready var audio_manager: AudioManager = $AudioManager

# UI Nodes
@onready var score_label: Label = $UI/TopBar/ScoreBox/ScoreValue
@onready var best_label: Label = $UI/TopBar/BestBox/BestValue
@onready var combo_label: Label = $UI/ComboLabel
@onready var sound_btn: Button = $UI/TopBar/SoundButton
@onready var restart_btn: Button = $UI/TopBar/RestartButton

# Game Over Modal
@onready var game_over_modal: Control = $UI/GameOverModal
@onready var final_score_label: Label = $UI/GameOverModal/Box/FinalScore
@onready var modal_best_label: Label = $UI/GameOverModal/Box/ModalBest
@onready var modal_restart_btn: Button = $UI/GameOverModal/Box/PlayAgainButton

var floating_text_scene: PackedScene = preload("res://scenes/FloatingText.tscn")

var score: int = 0
var best_score: int = 0
var current_combo: int = 0

func _ready() -> void:
	load_high_score()
	update_ui()
	game_over_modal.visible = false
	combo_label.visible = false
	
	# Connect spawner signals
	spawner.board = board
	spawner.piece_picked.connect(_on_piece_picked)
	spawner.piece_moved.connect(_on_piece_moved)
	spawner.piece_placed.connect(_on_piece_placed)
	spawner.no_moves_left.connect(_on_no_moves_left)
	
	# Connect UI buttons
	sound_btn.pressed.connect(_on_sound_btn_pressed)
	restart_btn.pressed.connect(restart_game)
	modal_restart_btn.pressed.connect(restart_game)
	
	# Start initial round
	spawner.spawn_round()

func _on_piece_picked(piece: Piece) -> void:
	audio_manager.play_pickup()

func _on_piece_moved(piece: Piece, target_pos: Vector2) -> void:
	var rows = piece.matrix.size()
	var cols = piece.matrix[0].size()
	var grid_coord = board.world_to_grid(target_pos, rows, cols)
	board.show_ghost(piece.matrix, piece.color, grid_coord.x, grid_coord.y)

func _on_piece_placed(piece: Piece, target_pos: Vector2) -> void:
	var rows = piece.matrix.size()
	var cols = piece.matrix[0].size()
	var grid_coord = board.world_to_grid(target_pos, rows, cols)
	
	if board.can_place(piece.matrix, grid_coord.x, grid_coord.y):
		# Successfully placed!
		var placed_count = board.place_piece(piece.matrix, piece.color, grid_coord.x, grid_coord.y)
		add_score(placed_count)
		audio_manager.play_place()
		spawner.remove_piece(piece)
		
		# Check lines clear
		await get_tree().create_timer(0.06).timeout
		var clear_info = board.check_and_clear_lines()
		var lines = clear_info["lines"]
		
		if lines > 0:
			current_combo += 1
			# Combo points calculation
			var base_pts = lines * 10
			var combo_bonus = (current_combo - 1) * 20
			var total_clear_pts = (base_pts + combo_bonus) * lines
			add_score(total_clear_pts)
			
			# Show floating praise banner
			var center_pos = Vector2(540, 750)
			if clear_info["centers"].size() > 0:
				center_pos = clear_info["centers"][0]
				
			if current_combo > 1:
				spawn_floating_text("COMBO x" + str(current_combo) + "!", Color("#FFD11A"), center_pos, 1.3)
				audio_manager.play_combo(current_combo)
			elif lines >= 3:
				spawn_floating_text("UNBELIEVABLE!", Color("#FF3B30"), center_pos, 1.4)
				audio_manager.play_combo(3)
			elif lines == 2:
				spawn_floating_text("DOUBLE CRASH!", Color("#00D2FF"), center_pos, 1.2)
				audio_manager.play_clear()
			else:
				spawn_floating_text("CRASH! +" + str(total_clear_pts), Color.WHITE, center_pos, 1.0)
				audio_manager.play_clear()
		else:
			current_combo = 0
			
		# Check if any moves remain
		spawner.check_game_over()
	else:
		# Invalid placement -> return smoothly to slot
		board.clear_ghost()
		piece.return_to_slot()

func _on_no_moves_left() -> void:
	audio_manager.play_gameover()
	show_game_over()

func add_score(pts: int) -> void:
	score += pts
	if score > best_score:
		best_score = score
		save_high_score()
	update_ui()

func update_ui() -> void:
	score_label.text = str(score)
	best_label.text = str(best_score)

func spawn_floating_text(text: String, col: Color, pos: Vector2, scale_mult: float = 1.0) -> void:
	var ft: FloatingText = floating_text_scene.instantiate()
	ft.position = pos
	add_child(ft)
	ft.setup(text, col, scale_mult)

func show_game_over() -> void:
	final_score_label.text = str(score)
	modal_best_label.text = "BEST: " + str(best_score)
	game_over_modal.visible = true
	game_over_modal.modulate.a = 0.0
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(game_over_modal, "modulate:a", 1.0, 0.3)

func restart_game() -> void:
	game_over_modal.visible = false
	score = 0
	current_combo = 0
	update_ui()
	board.reset_board()
	spawner.reset_spawner()

func _on_sound_btn_pressed() -> void:
	var muted = audio_manager.toggle_mute()
	sound_btn.text = "🔇" if muted else "🔊"

func save_high_score() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data = {"best_score": best_score}
		file.store_string(JSON.stringify(data))
		file.close()

func load_high_score() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.parse_string(content)
			if json is Dictionary and json.has("best_score"):
				best_score = int(json["best_score"])
			file.close()
