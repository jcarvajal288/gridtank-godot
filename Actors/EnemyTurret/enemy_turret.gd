extends CharacterBody2D

@onready var ray_cast = $RayCast2D

func _process(_delta: float) -> void:
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if is_instance_of(collider, Tank):
			Global.tank_shot.emit()
