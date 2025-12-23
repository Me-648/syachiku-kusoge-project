extends Node

enum Difficulty {
	EASY,
	NORMAL,
	HARD,
	VERY_HARD
}

var difficulty: Difficulty = Difficulty.NORMAL

var boss_speed := 4.5
var time_limit := 20.0
var total_trash_count := 10

func apply_difficulty():
	match difficulty:
		Difficulty.EASY:
			boss_speed = 3.0
			time_limit = 25.0
			total_trash_count = 5
		Difficulty.NORMAL:
			boss_speed = 4.0
			time_limit = 20.0
			total_trash_count = 10
		Difficulty.HARD:
			boss_speed = 4.5
			time_limit = 15.0
			total_trash_count = 12
		Difficulty.VERY_HARD:
			boss_speed = 5.0
			time_limit = 12.0
			total_trash_count = 15
