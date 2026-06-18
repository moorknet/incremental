class_name AttackStats
extends RefCounted

var damage: float = 10.0
var cooldown: float = 1.2
var count: int = 1
var range: float = 800.0
var pierce: int = 0
var bounce: int = 0
var chain: int = 0
var crit_chance: float = 0.0
var crit_multiplier: float = 2.0
var speed: float = 400.0

func clone() -> AttackStats:
	var s := AttackStats.new()
	s.damage = damage
	s.cooldown = cooldown
	s.count = count
	s.range = range
	s.pierce = pierce
	s.bounce = bounce
	s.chain = chain
	s.crit_chance = crit_chance
	s.crit_multiplier = crit_multiplier
	s.speed = speed
	return s
