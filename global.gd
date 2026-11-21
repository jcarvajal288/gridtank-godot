extends Node

enum Orientation { 
	NORTH,
	SOUTH,
	EAST,
	WEST
}


signal trigger_update(num_tick: int)
signal tank_shot()