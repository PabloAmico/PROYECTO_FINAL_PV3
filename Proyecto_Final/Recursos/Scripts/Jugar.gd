extends Button

func _process(delta):
	if(pressed):
		get_tree().change_scene("res://Niveles/Nivel 1.tscn");
