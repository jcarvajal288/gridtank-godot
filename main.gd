extends Node2D

const TICKS_PER_CYCLE = 8

@onready var tick_count = 0

func _ready() -> void:
	$TickTimer.timeout.connect(trigger_enemy_updates)
		

func trigger_enemy_updates() -> void:
	tick_count += 1
	tick_count %= TICKS_PER_CYCLE
	Global.trigger_update.emit(tick_count)
