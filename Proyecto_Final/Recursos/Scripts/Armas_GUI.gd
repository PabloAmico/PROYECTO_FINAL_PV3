extends Node2D

onready var Pistol = $Pistol
onready var Rifle = $Rifle
onready var Shotgun = $Shotgun
onready var Text = $Label

var max_bullets = 0 #balas que tiene en total el jugador

var current_bullets = 0	#balas que se encuentran en el cargador del arma

var player = null

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	
	pass # Replace with function body.



func _process(delta):
	_on_change_weapon()
	pass

func _on_change_weapon():
	match player.Num_Arma_Equipada:
		0:
			Pistol.visible = false
			Rifle.visible = false
			Shotgun.visible = false
			Text.visible = false

		1:
			Pistol.visible = false
			Rifle.visible = false
			Shotgun.visible = false
			Text.visible = false

		2:
			Pistol.visible = true
			Rifle.visible = false
			Shotgun.visible = false
			Text.visible = true
			
			Text.text = String(player.bullets_in_magazine_weapons[2]) + " / " + (String(player.bullets_current_weapons[2]))
			
		3:
			Pistol.visible = false
			Rifle.visible = false
			Shotgun.visible = true
			Text.visible = true
			Text.text = String(player.bullets_in_magazine_weapons[3]) + " / " + (String(player.bullets_current_weapons[3]))
		
		4:
			Pistol.visible = false
			Rifle.visible = true
			Shotgun.visible = false
			Text.visible = true
			Text.text = String(player.bullets_in_magazine_weapons[4]) + " / " + (String(player.bullets_current_weapons[4]))
