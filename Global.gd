extends Node

var black_company_unlocked := false

enum Difficulty {
	EASY,
	NORMAL,
	HARD,
	VERY_HARD,
	BLACK
}

var difficulty: Difficulty = Difficulty.NORMAL

var boss_speed := 4.5
var time_limit := 20.0
var total_trash_count := 10
var time_bouns := 1.0

func apply_difficulty():
	match difficulty:
		Difficulty.EASY:
			boss_speed = 3.5
			time_limit = 25.0
			total_trash_count = 5
			time_bouns = 1.5
		Difficulty.NORMAL:
			boss_speed = 4.3
			time_limit = 20.0
			total_trash_count = 10
			time_bouns = 1.0
		Difficulty.HARD:
			boss_speed = 4.7
			time_limit = 15.0
			total_trash_count = 12
			time_bouns = 0.5
		Difficulty.VERY_HARD:
			boss_speed = 3.5
			time_limit = 10.0
			total_trash_count = 1
			time_bouns = 0.2
		Difficulty.BLACK:
			boss_speed = 3.0
			time_limit = 5.0
			total_trash_count = 25
			time_bouns = -0.5
