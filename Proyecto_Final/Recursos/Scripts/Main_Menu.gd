extends Node2D

func _init():
	PlayerStatsGlobal.Restart_Data();

func _process(delta):
	if Input.is_action_just_pressed("Start"):
		get_tree().change_scene("res://Niveles/Nivel 1.tscn");
	pass
