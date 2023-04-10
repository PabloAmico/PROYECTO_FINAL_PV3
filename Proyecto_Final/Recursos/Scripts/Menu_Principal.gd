extends Button

func _process(delta):
	if get_parent().is_visible_in_tree():
		if pressed || Input.is_action_just_pressed("Recargar"):
			get_tree().change_scene("res://Niveles/Main Menu.tscn");
	pass
