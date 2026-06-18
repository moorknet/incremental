class_name Player
extends Node2D

# Fixed in the closest corner of the arena — set at start by Main
func place_in_corner(corner_position: Vector2) -> void:
	global_position = corner_position
