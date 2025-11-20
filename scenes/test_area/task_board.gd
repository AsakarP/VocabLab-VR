extends Node3D

@onready var label_3d = $Label3D

@export var master_item_list: Array[String] = ["Table Lamp","Picture Frame","Cactus","Pillow","Stool"]

var current_queue: Array[String] = []
var current_idx: int = 0
var score: int = 0
var game_active: bool = false
var time: float = 0.0

# Runs every single frame
func _process(delta):
	if game_active:
		time += delta
		update_board_disp()

# Starts new round
func start_new_round():
	if game_active:
		return
	
	current_queue = master_item_list.duplicate()
	current_queue.shuffle()
	
	score = 0
	current_idx = 0
	
	time = 0.0
	game_active = true
	
	update_board_disp()
	
func update_board_disp():
	var time_str = get_formatted_time()
	
	if current_idx < current_queue.size():
		var target = current_queue[current_idx]
		label_3d.text = "Find: %s\nScore: %d\nTime: %s" % [target, score, time_str]
		label_3d.modulate = Color.WHITE
	else:
		label_3d.text = "All Tasks Done!\nFinal Score: %d\nFinal Time: %s" % [score, time_str]
		label_3d.modulate = Color.GREEN
		
func check_submission(submitted_item_name: String) -> bool:
	if !game_active or current_idx >= current_queue.size():
		return false
	
	if submitted_item_name == current_queue[current_idx]:
		score += 1
		current_idx += 1
		
		if current_idx >= current_queue.size():
			end_game()
		else:
			update_board_disp()
			
		return true
	
	return false

# To stop timer
func end_game():
	game_active = false
	update_board_disp()
	
func get_formatted_time() -> String:
	var minutes = int(time/60)
	var seconds = int(time)%60
	
	return "%02d:%02d" % [minutes,seconds]

# If button pressed start new round
func _on_interactable_area_button_button_pressed(_button):
	start_new_round()
