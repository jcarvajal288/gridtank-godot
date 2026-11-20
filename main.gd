extends Node2D

@onready var tick_count = 0

func _ready() -> void:
	$TickTimer.timeout.connect(trigger_enemy_updates)
		

func trigger_enemy_updates() -> void:
	tick_count += 1
	tick_count %= 255
	Global.trigger_update.emit(tick_count)
