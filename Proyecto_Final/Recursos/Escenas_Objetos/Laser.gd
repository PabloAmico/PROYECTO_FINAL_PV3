extends Node2D

var no_col = false
var laser = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Raycast_Laser.rotation_degrees = 270
	$Line2D.rotation_degrees = 0
	pass # Replace with function body.



func _physics_process(delta):
	
	Change_Long_Laser()
	pass



func Change_Long_Laser():
	
	var laserOrigin = to_local($Raycast_Laser.global_position)

	var laser_end
	
	if $Raycast_Laser.is_colliding():
		laser_end = to_local($Raycast_Laser.get_collision_point())
		no_col = false
		$Line2D.clear_points()
		$Line2D.add_point(laserOrigin)
		$Line2D.add_point(laser_end)
		
	else:
		$Line2D.clear_points()
		pass
	
	
	
