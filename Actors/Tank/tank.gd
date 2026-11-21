class_name Tank extends CharacterBody2D

const SPEED = 40
const RAY_CAST_LENGTH = 8
const TILE_SIZE = 16

enum State {
	IDLE,
	MOVING,
	TURNING,
	FIRING
}

@onready var animation_player = $AnimationPlayer
@onready var wall_detector = $WallDetector
@onready var fire_line = $FireLine
@onready var turret_sprite = $TurretSprite

@onready var destination_tile = global_position
@onready var body_orientation = Global.Orientation.NORTH
@onready var turret_orientation = Global.Orientation.NORTH
@onready var state = State.IDLE
@onready var previous_state = State.IDLE

func _ready() -> void:
	animation_player.pause()	
	Global.tank_shot.connect(destroy_tank)


func get_movement_vector() -> Vector2:
	var mv = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var snapped_vector = Vector2(
		snapped(mv.x, 0.5), 
		snapped(mv.y, 0.5)
	).normalized()
	return snapped_vector


func _process(_delta: float) -> void:
	var movement_vector = get_movement_vector()
	var b_button_pressed = Input.is_action_pressed("turn_turret")
	if b_button_pressed and state == State.IDLE:
		handle_turret()
	else:
		handle_body(movement_vector)


func handle_body(movement_vector: Vector2) -> void:
	if Input.is_action_just_pressed("fire"):
		previous_state = state
		state = State.FIRING
	if state == State.FIRING:
		fire()
	elif state == State.IDLE:
		state = handle_idle_state(movement_vector)
	elif state == State.MOVING:
		state = handle_moving_state()
		if state == State.IDLE:
			animation_player.pause()
	elif state == State.TURNING:
		if movement_vector == Vector2.ZERO:
			state = State.IDLE
	

func handle_idle_state(movement_vector: Vector2) -> State:
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


func move_forward() -> void:
	if body_orientation == Global.Orientation.NORTH:
		animation_player.play("movingNorth")
		if destination_open(Vector2.UP):
			destination_tile = Vector2(global_position.x, global_position.y - TILE_SIZE)
			velocity = Vector2(0, -SPEED)
	elif body_orientation == Global.Orientation.SOUTH:
		animation_player.play("movingSouth")
		if destination_open(Vector2.DOWN):
			destination_tile = Vector2(global_position.x, global_position.y + TILE_SIZE)
			velocity = Vector2(0, SPEED)
	elif body_orientation == Global.Orientation.EAST:
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
	if body_orientation == Global.Orientation.NORTH:
		animation_player.play_backwards("movingNorth")
		if destination_open(Vector2.DOWN):
			destination_tile = Vector2(global_position.x, global_position.y + TILE_SIZE)
			velocity = Vector2(0, SPEED)
	elif body_orientation == Global.Orientation.SOUTH:
		animation_player.play_backwards("movingSouth")
		if destination_open(Vector2.UP):
			destination_tile = Vector2(global_position.x, global_position.y - TILE_SIZE)
			velocity = Vector2(0, -SPEED)
	elif body_orientation == Global.Orientation.EAST:
		animation_player.play_backwards("movingEast")
		if destination_open(Vector2.LEFT):
			destination_tile = Vector2(global_position.x - TILE_SIZE, global_position.y)
			velocity = Vector2(-SPEED, 0)
	else:
		animation_player.play_backwards("movingWest")
		if destination_open(Vector2.RIGHT):
			destination_tile = Vector2(global_position.x + TILE_SIZE, global_position.y)
			velocity = Vector2(SPEED, 0)


func rotate_left() -> void:
	if body_orientation == Global.Orientation.NORTH:
		animation_player.play("movingWest")
		body_orientation = Global.Orientation.WEST
		wall_detector.target_position = Vector2.LEFT * RAY_CAST_LENGTH
	elif body_orientation == Global.Orientation.SOUTH:
		animation_player.play("movingEast")
		body_orientation = Global.Orientation.EAST
		wall_detector.target_position = Vector2.RIGHT * RAY_CAST_LENGTH
	elif body_orientation == Global.Orientation.EAST:
		animation_player.play("movingNorth")
		body_orientation = Global.Orientation.NORTH
		wall_detector.target_position = Vector2.UP * RAY_CAST_LENGTH
	else:
		animation_player.play("movingSouth")
		body_orientation = Global.Orientation.SOUTH
		wall_detector.target_position = Vector2.DOWN * RAY_CAST_LENGTH
	animation_player.seek(0.0, true)
	animation_player.pause()
	rotate_turret_left()


func rotate_right() -> void:
	if body_orientation == Global.Orientation.NORTH:
		animation_player.play("movingEast")
		body_orientation = Global.Orientation.EAST
		wall_detector.target_position = Vector2.RIGHT * RAY_CAST_LENGTH
	elif body_orientation == Global.Orientation.SOUTH:
		animation_player.play("movingWest")
		body_orientation = Global.Orientation.WEST
		wall_detector.target_position = Vector2.LEFT * RAY_CAST_LENGTH
	elif body_orientation == Global.Orientation.EAST:
		animation_player.play("movingSouth")
		body_orientation = Global.Orientation.SOUTH
		wall_detector.target_position = Vector2.DOWN * RAY_CAST_LENGTH
	else:
		animation_player.play("movingNorth")
		body_orientation = Global.Orientation.NORTH
		wall_detector.target_position = Vector2.UP * RAY_CAST_LENGTH
	animation_player.seek(0.0, true)
	animation_player.pause()
	rotate_turret_right()


func destination_open(movement_vector: Vector2) -> bool:
	wall_detector.target_position = movement_vector * RAY_CAST_LENGTH
	return not wall_detector.is_colliding()


func handle_moving_state() -> State:
	if reached_destination():
		global_position = destination_tile
		return State.IDLE
	elif wall_detector.is_colliding():
		return State.IDLE
	else:
		move_and_slide()
		return State.MOVING
	

func reached_destination() -> bool:
	if velocity.y < 0 and global_position.y <= destination_tile.y:
		return true
	elif velocity.y > 0 and global_position.y >= destination_tile.y:
		return true
	elif velocity.x > 0 and global_position.x >= destination_tile.x:
		return true
	elif velocity.x < 0 and global_position.x <= destination_tile.x:
		return true
	else: 
		return false


func handle_turret() -> void:
	if Input.is_action_just_pressed("ui_right"):
		rotate_turret_right()
	elif Input.is_action_just_pressed("ui_left"):
		rotate_turret_left()


func rotate_turret_right() -> void:
	if turret_orientation == Global.Orientation.NORTH:
		turret_orientation = Global.Orientation.EAST
		turret_sprite.rotation_degrees = 90.0
		fire_line.rotation_degrees = 90.0
	elif turret_orientation == Global.Orientation.EAST:
		turret_orientation = Global.Orientation.SOUTH
		turret_sprite.rotation_degrees = 180.0
		fire_line.rotation_degrees = 180.0
	elif turret_orientation == Global.Orientation.SOUTH:
		turret_orientation = Global.Orientation.WEST
		turret_sprite.rotation_degrees = 270.0
		fire_line.rotation_degrees = 270.0
	elif turret_orientation == Global.Orientation.WEST:
		turret_orientation = Global.Orientation.NORTH
		turret_sprite.rotation_degrees = 0.0
		fire_line.rotation_degrees = 0.0


func rotate_turret_left() -> void:
	if turret_orientation == Global.Orientation.NORTH:
		turret_orientation = Global.Orientation.WEST
		turret_sprite.rotation_degrees = 270.0
		fire_line.rotation_degrees = 270.0
	elif turret_orientation == Global.Orientation.EAST:
		turret_orientation = Global.Orientation.NORTH
		turret_sprite.rotation_degrees = 0.0
		fire_line.rotation_degrees = 0.0
	elif turret_orientation == Global.Orientation.SOUTH:
		turret_orientation = Global.Orientation.EAST
		turret_sprite.rotation_degrees = 90.0
		fire_line.rotation_degrees = 90.0
	elif turret_orientation == Global.Orientation.WEST:
		turret_orientation = Global.Orientation.SOUTH
		turret_sprite.rotation_degrees = 180.0
		fire_line.rotation_degrees = 180.0


func destroy_tank() -> void:
	queue_free()


func fire() -> void:
	print(previous_state)
	if not fire_line.enabled:
		fire_line.enabled = true
	elif fire_line.is_colliding():
		var collider = fire_line.get_collider()
		if is_instance_of(collider, CharacterBody2D):
			collider.destroy()
		fire_line.enabled = false
	else:
		state = previous_state