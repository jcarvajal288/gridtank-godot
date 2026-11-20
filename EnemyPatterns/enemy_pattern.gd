class_name EnemyPattern extends Node

@export var subject: CharacterBody2D


func _ready() -> void:
	Global.trigger_update.connect(trigger_update)


func trigger_update(_tick_count: int) -> void:
	pass
