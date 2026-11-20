extends Node2D

const TICKS_PER_CYCLE = 8

@onready var tick_count = 0

func _ready() -> void:
	$TickTimer.timeout.connect(trigger_enemy_updates)
		

func trigger_enemy_updates() -> void:
	for enemy in $Enemies.get_children():
		enemy.trigger_update(tick_count)
	tick_count += 1
	tick_count %= TICKS_PER_CYCLE