extends CanvasLayer

var control = null;

func _init():
	PlayerStatsGlobal.Restart_Data();

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
		

	if Input.is_action_just_pressed("Start") && !get_node("ColorRect").visible:
		if(!get_tree().paused):
			get_tree().set_pause(true)
			get_node("Menu Pause").visible = true;
		else:
			get_node("Menu Pause").visible = false;
			get_tree().set_pause(false)
