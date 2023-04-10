extends KinematicBody2D

export(String) var color_key = "none";
#export(float) var degress = 0;
var open = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	Color_Door();
	pass # Replace with function body.



func _process(delta):
	if open:
		#rotation  -=5 * delta
		#if(rotation < degress):
		#	rotation =  degress;
		#	open = false;
		#	get_node("Area2D").queue_free();
		queue_free()
	pass

func Open_The_Door(Player):

	if(color_key == "none"):
		open = true;
	elif(Player.Get_Key(color_key)):
		open = true;
	pass

func Color_Door():
	match color_key:
		"red":
			get_node("Sprite").modulate = Color.red;
		"green":
			get_node("Sprite").modulate = Color.green;
		"blue":
			get_node("Sprite").modulate = Color.blue;

func _on_Area2D_body_entered(body:Node):
	if body.is_in_group("Player"):
		Open_The_Door(body);
	pass # Replace with function body.
