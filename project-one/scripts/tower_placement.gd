extends Node2D

# --- Tower scene ---
# Update this path to match where you saved t_pistol.tscn
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/t_pistol.tscn")

# The tower's actual footprint radius, read from its own scene once at
# startup (see _ready below) so there's exactly one place this is defined —
# the tower's own Footprint shape. Nothing to keep manually in sync.
var tower_radius: float

# The physics layer your placed towers live on (set in Project Settings ->
# Layer Names -> 2D Physics). Used to make sure the overlap check only
# matches other towers, not enemies/path/projectiles.
@export_flags_2d_physics var tower_collision_mask: int = 1

# --- Tile layers ---
@onready var grass_layer: TileMapLayer = $"../Grass"
@onready var path_layer: TileMapLayer = $"../Path"


func _ready() -> void:
	# Instantiate one throwaway tower, just to read its real collision
	# radius, then immediately discard it. Runs once at scene start, not
	# on every click.
	var temp: Node2D = TOWER_SCENE.instantiate()
	var footprint: CollisionShape2D = temp.get_node("Footprint/Footprint")
	tower_radius = footprint.shape.radius
	temp.free()


# --- 1. Click detection ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		_try_place_tower(grass_layer.get_global_mouse_position())


func _try_place_tower(click_pos: Vector2) -> void:
	# --- 2. Validation ---
	if not _is_ground_valid(click_pos):
		return
	if not _is_clear_of_towers(click_pos):
		return

	# --- 3. Placement ---
	_place_tower(click_pos)


# Checks every tile the tower's circular footprint would cover.
# Rejects the placement if any path tile falls within the tower's radius.
func _is_ground_valid(click_pos: Vector2) -> bool:
	var top_left: Vector2 = click_pos - Vector2(tower_radius, tower_radius)
	var bottom_right: Vector2 = click_pos + Vector2(tower_radius, tower_radius)

	var tile_min: Vector2i = grass_layer.local_to_map(grass_layer.to_local(top_left))
	var tile_max: Vector2i = grass_layer.local_to_map(grass_layer.to_local(bottom_right))

	for x in range(tile_min.x, tile_max.x + 1):
		for y in range(tile_min.y, tile_max.y + 1):
			var tile_pos := Vector2i(x, y)

			# Only care about tiles the circle actually reaches, not just
			# the square bounding box around it.
			var tile_center: Vector2 = grass_layer.to_global(grass_layer.map_to_local(tile_pos))
			if click_pos.distance_to(tile_center) > tower_radius:
				continue

			if path_layer.get_cell_source_id(tile_pos) != -1:
				return false # a path tile is within the tower's footprint

	return true


# Physics query: would the tower's circular footprint, placed here,
# touch any existing tower's Footprint shape?
func _is_clear_of_towers(click_pos: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state

	var query := PhysicsShapeQueryParameters2D.new()
	var probe_shape := CircleShape2D.new()
	probe_shape.radius = tower_radius

	query.shape = probe_shape
	query.transform = Transform2D(0, click_pos)
	query.collision_mask = tower_collision_mask

	var result := space_state.intersect_shape(query)
	return result.size() == 0


func _place_tower(click_pos: Vector2) -> void:
	var tower_instance: Node2D = TOWER_SCENE.instantiate()
	add_child(tower_instance)
	tower_instance.global_position = click_pos
