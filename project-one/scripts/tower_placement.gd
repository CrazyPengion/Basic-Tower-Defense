extends Node2D

# Preload your tower scenes
const TOWER_SCENES := {
	"pistol": preload("res://scenes/towers/t_pistol.tscn"),
	# "cannon": preload("res://scenes/towers/t_cannon.tscn")
}

# Define tower radii
const TOWER_SIZE := {
	"tile": 16, # tile side lenght
	"pistol": 8
}

# 1. Detect LMB click + pos
# This is what gets called by Godot, all following
# 	actions start here.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_position: Vector2 = get_global_mouse_position()
		print("Global Click Position: ", click_position)
		
		# Verify if the selected position is valid
		if not verify_position(click_position):
			return
		
		# Show tower selection screen
		var tower_type: String = select_tower()
		
		# Place tower
		place_tower(tower_type, click_position)

# 2. Verify Position
func verify_position(tower_position: Vector2i) -> bool:
	# WIP, use Area2D from tower for it? (If not remove the physics from path layer)
	return true

# 3. SHOW SELECTION SCREEN - TODO: complete
func select_tower() -> String:
	var tower_id: String = "pistol"
	return tower_id

# 4. Place Tower
func place_tower(tower_type: String, tower_pos: Vector2i) -> void:
	
	# 1. Instantiate the tower
	var tower_scene: PackedScene = TOWER_SCENES[tower_type]
	var tower_instance: Node2D = tower_scene.instantiate()

	# 2. Set world position
	tower_instance.global_position = tower_pos
	
	# 3. Add the tower to the scene
	add_child(tower_instance)
