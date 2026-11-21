extends CharacterBody2D


func _process(_delta: float) -> void:
    if $RayCast2D.is_colliding():
        Global.tank_shot.emit()