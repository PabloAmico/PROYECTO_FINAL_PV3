extends KinematicBody2D

var Move_Dir = Vector2(0,0)
var Shoot_Dir = Vector2.ZERO

export var Move_Speed = 250
export var Rotation_Speed = 100.0
var rotation_dir = 0
var deadzone = 0.3
var rs_look = Vector2()
var velocity

#Variables booleanas de armas y desarmado
export var Desarmado = true
export var Tiene_Pistola = false
export var Pistola_Equipada = false
export var Tiene_Escopeta = false
export var Escopeta_Equipada = false
export var Tiene_Cuchillo = false
export var Cuchillo_Equipado = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	
	velocity = Vector2.ZERO
	Move_Dir.x = -Input.get_action_strength("Mover_Izquierda") + Input.get_action_strength("Mover_Derecha")
	Move_Dir.y = -Input.get_action_strength("Mover_Arriba") + Input.get_action_strength("Mover_Abajo")
	
	
	
	rslook()
	velocity = Move_Dir * Move_Speed
	
	_Set_Animations()
	
	velocity = move_and_slide(velocity)
	


func rslook():
	rs_look.y = Input.get_joy_axis(0, JOY_AXIS_3)
	rs_look.x = Input.get_joy_axis(0, JOY_AXIS_2)
	if rs_look.length() >= deadzone:
		rotation = rs_look.angle()


func _Set_Animations():
	if Desarmado:
		if velocity == Vector2(0,0):
			$AnimationPlayer.play("Flashlight_Idle")
			print("Estoy idle")
		else:
			$AnimationPlayer.play("Flashlight_Move")
			
	if Cuchillo_Equipado:
		if velocity == Vector2(0,0):
			$AnimationPlayer.play("knife_idle")
			print("Estoy idle")
		else:
			$AnimationPlayer.play("knife_move")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
