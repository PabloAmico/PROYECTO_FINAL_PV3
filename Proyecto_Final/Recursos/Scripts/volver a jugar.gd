extends Button


func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().is_visible_in_tree():
		if(pressed || Input.is_action_just_pressed("Start")):
			
			get_tree().reload_current_scene()