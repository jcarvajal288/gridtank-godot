extends EnemyPattern

@export var directions: Array[Global.Orientation] = [
	Global.Orientation.NORTH,
	Global.Orientation.NORTH,
	Global.Orientation.NORTH,
	Global.Orientation.NORTH,
	Global.Orientation.NORTH,
	Global.Orientation.NORTH,
	Global.Orientation.NORTH,
	Global.Orientation.NORTH
]

func trigger_update(tick_count: int) -> void:
	var orientation = directions[tick_count % len(directions)]
	if orientation == Global.Orientation.NORTH:
		subject.rotation_degrees = 0
	elif orientation == Global.Orientation.EAST:
		subject.rotation_degrees = 90
	elif orientation == Global.Orientation.SOUTH:
		subject.rotation_degrees = 180
	elif orientation == Global.Orientation.WEST:
		subject.rotation_degrees = 270
