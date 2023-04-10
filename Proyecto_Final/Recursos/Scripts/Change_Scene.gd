extends Area2D

func _on_Change_Scene_body_entered(body:Node):
	if body.is_in_group("Player"):
		PlayerStatsGlobal.current_level = 2;
		PlayerStatsGlobal.Save_Data();
		get_tree().change_scene("res://Niveles/Nivel 2.tscn");
	pass # Replace with function body.
