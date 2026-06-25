extends Node

const NIVEL_INICIAL := "res://scenes/levels/nivel_01.tscn"


func _ready() -> void:
	get_tree().call_deferred("change_scene_to_file", NIVEL_INICIAL)
