class_name Tank extends CharacterBody2D

const SPEED = 40
const RAY_CAST_LENGTH = 8
const TILE_SIZE = 16

enum Orientation { 
	NORTH,
	SOUTH,
	EAST,
	WEST
}

enum State {
	IDLE,
	MOVING,
	TURNING
}

@onready var animation_player = $AnimationPlayer
@onready var ray_cast = $RayCast2D
@onready var destination_tile = global_position
@onready var orientation = Orientation.NORTH
@onready var state = State.IDLE

func _ready() -> void:
	animation_player.pause()	


func get_movement_vector() -> Vector2:
	var mv = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var snapped_vector = Vector2(
		snapped(mv.x, 0.5), 
		snapped(mv.y, 0.5)
	).normalized()
	return snapped_vector


func _process(_delta: float) -> void:
	if state == State.IDLE:
		state = handle_idle_state()
	elif state == State.MOVING:
		state = handle_moving_state()
		if state == State.IDLE:
			animation_player.pause()
	elif state == State.TURNING:
		var movement_vector = get_movement_vector()
		if movement_vector == Vector2.ZERO:
			state = State.IDLE


func move_forward() -> void:
	if orientation == Orientation.NORTH:
		animation_player.play("movingNorth")
		if destination_open(Vector2.UP):
			destination_tile = Vector2(global_position.x, global_position.y - TILE_SIZE)
			velocity = Vector2(0, -SPEED)
	elif orientation == Orientation.SOUTH:
		animation_player.play("movingSouth")
		if destination_open(Vector2.DOWN):
			destination_tile = Vector2(global_position.x, global_position.y + TILE_SIZE)
			velocity = Vector2(0, SPEED)
	elif orientation == Orientation.EAST:
		animation_player.play("movingEast")
		if destination_open(Vector2.RIGHT):
			destination_tile = Vector2(global_position.x + TILE_SIZE, global_position.y)
			velocity = Vector2(SPEED, 0)
	else:
		animation_player.play("movingWest")
		if destination_open(Vector2.LEFT):
			destination_tile = Vector2(global_position.x - TILE_SIZE, global_position.y)
			velocity = Vector2(-SPEED, 0)


func move_backward() -> void:
	if orientation == Orientation.NORTH:
		animation_player.play("movingSouth")
		if destination_open(Vector2.DOWN):
			destination_tile = Vector2(global_position.x, global_position.y + TILE_SIZE)
			velocity = Vector2(0, SPEED)
	elif orientation == Orientation.SOUTH:
		animation_player.play("movingNorth")
		if destination_open(Vector2.UP):
			destination_tile = Vector2(global_position.x, global_position.y - TILE_SIZE)
			velocity = Vector2(0, -SPEED)
	elif orientation == Orientation.EAST:
		animation_player.play("movingWest")
		if destination_open(Vector2.LEFT):
			destination_tile = Vector2(global_position.x - TILE_SIZE, global_position.y)
			velocity = Vector2(-SPEED, 0)
	else:
		animation_player.play("movingEast")
		if destination_open(Vector2.RIGHT):
			destination_tile = Vector2(global_position.x + TILE_SIZE, global_position.y)
			velocity = Vector2(SPEED, 0)


func rotate_left() -> void:
	if orientation == Orientation.NORTH:
		animation_player.play("movingWest")
		orientation = Orientation.WEST
		ray_cast.target_position = Vector2.LEFT * RAY_CAST_LENGTH
	elif orientation == Orientation.SOUTH:
		animation_player.play("movingEast")
		orientation = Orientation.EAST
		ray_cast.target_position = Vector2.RIGHT * RAY_CAST_LENGTH
	elif orientation == Orientation.EAST:
		animation_player.play("movingNorth")
		orientation = Orientation.NORTH
		ray_cast.target_position = Vector2.UP * RAY_CAST_LENGTH
	else:
		animation_player.play("movingSouth")
		orientation = Orientation.SOUTH
		ray_cast.target_position = Vector2.DOWN * RAY_CAST_LENGTH
	animation_player.seek(0.0, true)
	animation_player.pause()


func rotate_right() -> void:
	if orientation == Orientation.NORTH:
		animation_player.play("movingEast")
		orientation = Orientation.EAST
		ray_cast.target_position = Vector2.RIGHT * RAY_CAST_LENGTH
	elif orientation == Orientation.SOUTH:
		animation_player.play("movingWest")
		orientation = Orientation.WEST
		ray_cast.target_position = Vector2.LEFT * RAY_CAST_LENGTH
	elif orientation == Orientation.EAST:
		animation_player.play("movingSouth")
		orientation = Orientation.SOUTH
		ray_cast.target_position = Vector2.DOWN * RAY_CAST_LENGTH
	else:
		animation_player.play("movingNorth")
		orientation = Orientation.NORTH
		ray_cast.target_position = Vector2.UP * RAY_CAST_LENGTH
	animation_player.seek(0.0, true)
	animation_player.pause()


func handle_idle_state() -> State:
	var movement_vector = get_movement_vector()
	if movement_vector == Vector2.UP:
		move_forward()
		return State.MOVING
	elif movement_vector == Vector2.DOWN:
		move_backward()
		return State.MOVING
	elif movement_vector == Vector2.LEFT:
		rotate_left()
		return State.TURNING
	elif movement_vector == Vector2.RIGHT:
		rotate_right()
		return State.TURNING
	return State.IDLE


func destination_open(movement_vector: Vector2) -> bool:
	ray_cast.target_position = movement_vector * RAY_CAST_LENGTH
	return not ray_cast.is_colliding()


func handle_moving_state() -> State:
	if reached_destination():
		global_position = destination_tile
		return State.IDLE
	elif ray_cast.is_colliding():
		return State.IDLE
	else:
		move_and_slide()
		return State.MOVING
	

func reached_destination() -> bool:
	var direction = animation_player.current_animation
	if direction == "movingNorth" and global_position.y <= destination_tile.y:
		return true
	elif direction == "movingSouth" and global_position.y >= destination_tile.y:
		return true
	elif direction == "movingEast" and global_position.x >= destination_tile.x:
		return true
	elif direction == "movingWest" and global_position.x <= destination_tile.x:
		return true
	else: 
		return false

