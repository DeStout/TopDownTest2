extends Node

var high_score_save = File.new()
var save_path = "user://high_score_save.hs"
var save_data = {"high_score": 0}

const grid_size = Vector2(11, 6)
const TILE_SIZE = 64
var viewport = Vector2((grid_size.x*2+1)*(TILE_SIZE/2), (grid_size.y*2+1)*(TILE_SIZE/2)+64)

const NUM_ENEMIES = 5
var num_lives = 2

var collect_grid = []
var collects = 0

var high_score = 0
var score = 0


func _ready():
	randomize()
	#reset_high_score()
	
	OS.set_window_size(viewport*1.2)
	OS.window_maximized = true
	get_tree().get_root().size = viewport
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Globals.viewport)
	
	if !high_score_save.file_exists(save_path):
		create_save()
	read_high_score()
		
	create_grid_array()


func create_grid_array():
	for x in range(Globals.grid_size.x):
		collect_grid.append([])
		collect_grid[x] = []
		for y in range(Globals.grid_size.y):
			collect_grid[x].append([])
			collect_grid[x][y] = 0


func set_high_score():
	if score > high_score:
		high_score = score


func create_save():
	high_score_save.open(save_path, File.WRITE)
	high_score_save.store_var(save_data)
	high_score_save.close()


func read_high_score():
	high_score_save.open(save_path, File.READ)
	save_data = high_score_save.get_var()
	high_score_save.close()
	high_score = save_data["high_score"]


func save_high_score():
	if high_score > save_data["high_score"]:
		save_data["high_score"] = high_score
		create_save()


func reset_high_score():
	save_data["high_score"] = 0
	create_save()
