extends KinematicBody2D

var Move_Dir = Vector2(0,0)
var Shoot_Dir = Vector2.ZERO

export var Move_Speed = 250
var deadzone = 0.3
var rs_look = Vector2()
var velocity

var Num_Arma_Equipada
var Animaciones_Idle = ["Flashlight_Idle"]
#Variables booleanas de armas y desarmado
export var Desarmado = true
export var Tiene_Pistola = true
export var Pistola_Equipada = false
export var Tiene_Escopeta = true
export var Escopeta_Equipada = false
export var Tiene_Rifle = true
export var Rifle_Equipado = false
export var Tiene_Cuchillo = true
export var Cuchillo_Equipado = false
var Armas_Disponibles = [Desarmado, Tiene_Cuchillo, Tiene_Pistola, Tiene_Escopeta, Tiene_Rifle]
var Nombre_Arma_Equipada = ["Linterna","Cuchillo","Pistola","Escopeta","Rifle"]
var Arma_Equipada = [Desarmado, Cuchillo_Equipado, Pistola_Equipada, Escopeta_Equipada, Rifle_Equipado]

var Ataque = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Armas_Disponibles = [Desarmado, Tiene_Cuchillo, Tiene_Pistola, Tiene_Escopeta, Tiene_Rifle]
	Num_Arma_Equipada = 0
	pass # Replace with function body.

func _physics_process(delta):
	
	_joypads()
	
	_Set_Animations()
	
	velocity = Move_Dir * Move_Speed
	velocity = move_and_slide(velocity)


func rslook():
	rs_look.y = Input.get_joy_axis(0, JOY_AXIS_3)
	rs_look.x = Input.get_joy_axis(0, JOY_AXIS_2)
	if rs_look.length() >= deadzone:
		rotation = rs_look.angle()


func _Set_Animations():
	if Arma_Equipada[0]:
		if !Ataque:
			if velocity == Vector2(0,0):
				$AnimationPlayer.play(Animaciones_Idle[0])
			else:
				$AnimationPlayer.play("Flashlight_Move")
		else:
			$AnimationPlayer.play("flshlight_attack")
			
	if Arma_Equipada[1]:
		if !Ataque:
			if velocity == Vector2(0,0):
				$AnimationPlayer.play("knife_idle")
			else:
				$AnimationPlayer.play("knife_move")
		else:
			$AnimationPlayer.play("knife_attack")
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _joypads():
	velocity = Vector2.ZERO
	Move_Dir.x = -Input.get_action_strength("Mover_Izquierda") + Input.get_action_strength("Mover_Derecha")
	Move_Dir.y = -Input.get_action_strength("Mover_Arriba") + Input.get_action_strength("Mover_Abajo")
	rslook() #Movimiento en circulo del personaje.
	
	if Input.is_action_just_pressed("Atacar"):
		Ataque = true
		
	if Input.is_action_just_pressed("Arma_Siguiente"):
		Change_Arma_UP()
	
	if Input.is_action_just_pressed("Arma_Anterior"):
		Change_Arma_DOWN()


func _on_AnimationPlayer_animation_finished(anim_name):
	Ataque = false
	pass # Replace with function body.

func Set_Arma_Equipada():
	Arma_Equipada[Num_Arma_Equipada] = true
	for i in range(Arma_Equipada.size()-1):
		if(i != Num_Arma_Equipada):
			Arma_Equipada[i] = false
	print(Nombre_Arma_Equipada[Num_Arma_Equipada])


func Change_Arma_UP():
	var Bandera
	while(!Bandera):
		Num_Arma_Equipada = Num_Arma_Equipada +1
		if (Num_Arma_Equipada == Armas_Disponibles.size()):
			Num_Arma_Equipada = 0
			Bandera = true
		elif(Armas_Disponibles[Num_Arma_Equipada]):
			Bandera = true
	Set_Arma_Equipada()
	
func Change_Arma_DOWN():
	var Bandera
	while(!Bandera):
		Num_Arma_Equipada = Num_Arma_Equipada - 1
		if(Num_Arma_Equipada < 0):
			Num_Arma_Equipada = 5
		elif(Armas_Disponibles[Num_Arma_Equipada]):
			Bandera = true
	Set_Arma_Equipada()
