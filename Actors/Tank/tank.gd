class_name Tank extends CharacterBody2D

const SPEED = 40
const RAY_CAST_LENGTH = 8
const TILE_SIZE = 16

enum Orientation { 
	VERTICAL, 
	HORIZONTAL 
}

enum State {
	IDLE,
	MOVING
}

@onready var animation_player = $AnimationPlayer
@onready var ray_cast = $RayCast2D
@onready var destination_tile = Vector2i(4, 6)
@onready var orientation = Orientation.VERTICAL
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
	else:
		state = handle_moving_state()
		if state == State.IDLE:
			animation_player.pause()


func handle_idle_state() -> State:
	var movement_vector = get_movement_vector()
	if movement_vector == Vector2.UP:
		animation_player.play("movingNorth")
		if orientation == Orientation.HORIZONTAL:
			animation_player.pause()
			orientation = Orientation.VERTICAL
			ray_cast.target_position = movement_vector * RAY_CAST_LENGTH
			return State.IDLE
		elif destination_open(movement_vector):
			destination_tile.y -= 1
			velocity = Vector2(0, -SPEED)
			return State.MOVING
		else:
			animation_player.pause()
			return State.IDLE
	elif movement_vector == Vector2.DOWN:
		animation_player.play("movingSouth")
		if orientation == Orientation.HORIZONTAL:
			animation_player.pause()
			orientation = Orientation.VERTICAL
			ray_cast.target_position = movement_vector * RAY_CAST_LENGTH
			return State.IDLE
		elif destination_open(movement_vector):
			destination_tile.y += 1
			velocity = Vector2(0, SPEED)
			return State.MOVING
		else:
			animation_player.pause()
			return State.IDLE
	elif movement_vector == Vector2.LEFT:
		animation_player.play("movingWest")
		if orientation == Orientation.VERTICAL:
			animation_player.pause()
			orientation = Orientation.HORIZONTAL
			ray_cast.target_position = movement_vector * RAY_CAST_LENGTH
			return State.IDLE
		elif destination_open(movement_vector):
			destination_tile.x -= 1
			velocity = Vector2(-SPEED, 0)
			ray_cast.target_position = movement_vector * RAY_CAST_LENGTH
			return State.MOVING
		else:
			animation_player.pause()
			return State.IDLE
	elif movement_vector == Vector2.RIGHT:
		animation_player.play("movingEast")
		if orientation == Orientation.VERTICAL:
			animation_player.pause()
			orientation = Orientation.HORIZONTAL
			return State.IDLE
		elif destination_open(movement_vector):
			destination_tile.x += 1
			velocity = Vector2(SPEED, 0)
			return State.MOVING
		else:
			animation_player.pause()
			return State.IDLE
	else:
		return State.IDLE


func destination_open(movement_vector: Vector2) -> bool:
	ray_cast.target_position = movement_vector * RAY_CAST_LENGTH
	return not ray_cast.is_colliding()


func handle_moving_state() -> State:
	if reached_destination():
		return State.IDLE
	elif ray_cast.is_colliding():
		return State.IDLE
	else:
		move_and_slide()
		return State.MOVING
	

func reached_destination() -> bool:
	var direction = animation_player.current_animation
	var target_x = destination_tile.x * TILE_SIZE + 8
	var target_y = destination_tile.y * TILE_SIZE + 8
	if direction == "movingNorth" and global_position.y <= target_y:
		global_position = Vector2(target_x, target_y)
		return true
	elif direction == "movingSouth" and global_position.y >= target_y:
		global_position = Vector2(target_x, target_y)
		return true
	elif direction == "movingEast" and global_position.x >= target_x:
		global_position = Vector2(target_x, target_y)
		return true
	elif direction == "movingWest" and global_position.x <= target_x:
		global_position = Vector2(target_x, target_y)
		return true
	else: 
		return false

