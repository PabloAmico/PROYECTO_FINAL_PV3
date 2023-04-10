extends Node

onready var my_sprite = get_node("Spr_Items");
export(int) var integer;

var images = [
		load("res://Recursos/Sprites/GUI/medkit-d.png"),
		load("res://Recursos/Sprites/GUI/g9821.png"),
		load("res://Recursos/Sprites/GUI/GUN_01_[square_frame]_01_V1.00.png"),
		load("res://Recursos/Sprites/GUI/[design]Shotgun_V1.02.png"),
		load("res://Recursos/Sprites/GUI/[design] Assault_rifle_V1.00.png"),
		load("res://Recursos/Sprites/GUI/Key_Red.png"),
		load("res://Recursos/Sprites/GUI/Key_Blue.png"),
		load("res://Recursos/Sprites/GUI/Key_Green.png")
		
	]

func _ready():
	
	my_sprite.texture = images[integer];
	
	pass 

func Set_Integer( var num):
	integer = num
	my_sprite.texture = images[integer];


func _on_Area2D_body_entered(body:Node):
	var random_num = 0
	match integer:
		0:
			if body.is_in_group("Player"):
				body.Add_Life(50);
				queue_free();
		
		1:	
			if body.is_in_group("Player"):
				body.Enabled_Knife()
				queue_free();		

		2:	
			if body.is_in_group("Player"):
				random_num = (randi() % 12) + 9
				body.Add_Bullets(random_num, "Pistol");
				
				queue_free();
				
		
		3:
			if body.is_in_group("Player"):
				random_num = (randi() % 9) +1
				body.Add_Bullets(random_num, "Shotgun");
				queue_free();
		
		4:
			if body.is_in_group("Player"):
				random_num = (randi() % 22) +1
				body.Add_Bullets(random_num, "Rifle");
				queue_free();
			
		5:
			if body.is_in_group("Player"):
				body.Add_Key("red");
				queue_free();
		6:
			if body.is_in_group("Player"):
				body.Add_Key("blue");
				queue_free();
		7:
			if body.is_in_group("Player"):
				body.Add_Key("green");
				queue_free();
	
