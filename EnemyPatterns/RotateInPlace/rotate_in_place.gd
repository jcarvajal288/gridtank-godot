extends EnemyPattern

func trigger_update(tick_count: int) -> void:
	var _stage = tick_count / 2
	if _stage == 0:
		subject.rotation_degrees = 0
	elif _stage == 1:
		subject.rotation_degrees = 90
	elif _stage == 2:
		subject.rotation_degrees = 180
	elif _stage == 3:
		subject.rotation_degrees = 270
