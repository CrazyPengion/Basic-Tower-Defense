extends Node2D

# --- 1. Preload the tower scene ---
# Update this path to match where you saved t_pistol.tscn
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/t_pistol.tscn")

# --- 2. References to the tile layers ---
@onready var grass_layer: TileMapLayer = $Grass
@onready var path_layer: TileMapLayer = $Path

# Tracks which tile coordinates already have a tower (Vector2i -> true)
var occupied_tiles: Dictionary = {}


# --- 3. Detect the mouse click ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		_try_place_tower(get_global_mouse_position())


func _try_place_tower(global_click_pos: Vector2) -> void:
	# --- 4. Convert mouse position to grid coordinates ---
	# local_to_map() expects a position LOCAL to grass_layer, so convert first.
	var local_pos: Vector2 = grass_layer.to_local(global_click_pos)
	var tile_pos: Vector2i = grass_layer.local_to_map(local_pos)

	# --- 5. Validate the location ---
	if not _is_valid_placement(tile_pos):
		return

	# --- 6. Place and position the tower ---
	var tower_instance: Node2D = TOWER_SCENE.instantiate()
	add_child(tower_instance)

	# map_to_local() gives the tile's center in grass_layer's local space,
	# so convert it back to global space before assigning.
	var world_pos: Vector2 = grass_layer.to_global(grass_layer.map_to_local(tile_pos))
	tower_instance.global_position = world_pos

	occupied_tiles[tile_pos] = true


func _is_valid_placement(tile_pos: Vector2i) -> bool:
	# No grass tile here (get_cell_source_id returns -1 when a cell is empty)
	if grass_layer.get_cell_source_id(tile_pos) == -1:
		return false

	# There's a path tile at this coordinate — enemies walk here
	if path_layer.get_cell_source_id(tile_pos) != -1:
		return false

	# Already has a tower
	if occupied_tiles.has(tile_pos):
		return false

	return true
