extends KinematicBody2D

var Move_Dir = Vector2(0,0)
var Shoot_Dir = Vector2.ZERO

export var Move_Speed = 250
export var Move_Run = 325 #Se mueve un 30% mas rapido
export var run = false
var deadzone = 0.3
var rs_look = Vector2()
var velocity

var Num_Arma_Equipada

var target

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
var Tiempo_Entre_Disparos = false;

export var Ataque = false




#Array de Animaciones
var Animaciones_Idle = ["Flashlight_Idle", "knife_idle", "Pistol_Idle", "Shotgun_Idle", "Rifle_Idle"]
var Animaciones_Move = ["Flashlight_Move", "knife_move", "Pistol_Move", "Shotgun_Move", "Rifle_Move"]
var Animaciones_Attack = ["flshlight_attack", "knife_attack", "Pistol_Shoot", "Shotgun_Shoot", "Rifle__Shoot"]
var Animaciones_Shoot = [null, null, "Pistol_Shoot", "Shotgun_Shoot", "Rifle__Shoot"]
var Animaciones_Reload = [null, null, "Pistol_Reload", "Shotgun_Reload", "Rifle_Reload"]
var Animaciones_MeleeAttack = [null,null,"Pistol_Attack", "Shotgun_Attack", "Rifle_Attack"]

# Called when the node enters the scene tree for the first time.
func _ready():
	Armas_Disponibles = [Desarmado, Tiene_Cuchillo, Tiene_Pistola, Tiene_Escopeta, Tiene_Rifle]
	Num_Arma_Equipada = 0
	target = true
	$RayCast2D.enabled = false
	pass # Replace with function body.

func _physics_process(delta):
	
	Aim()
	
	_joypads()
	
	_Set_Animations()
	
	if(run):
		velocity = Move_Dir * Move_Run
	else:
		velocity = Move_Dir * Move_Speed
	velocity = move_and_slide(velocity)


func rslook():
	rs_look.y = Input.get_joy_axis(0, JOY_AXIS_3)
	rs_look.x = Input.get_joy_axis(0, JOY_AXIS_2)
	if rs_look.length() >= deadzone:
		rotation = rs_look.angle()


func _Set_Animations():
	if !Ataque:
		if velocity == Vector2(0,0):
			$AnimationPlayer.play(Animaciones_Idle[Num_Arma_Equipada])
		else:
			$AnimationPlayer.play(Animaciones_Move[Num_Arma_Equipada])
	else:
		$AnimationPlayer.play(Animaciones_Attack[Num_Arma_Equipada])

func _joypads():
	velocity = Vector2.ZERO
	Move_Dir.x = -Input.get_action_strength("Mover_Izquierda") + Input.get_action_strength("Mover_Derecha")
	Move_Dir.y = -Input.get_action_strength("Mover_Arriba") + Input.get_action_strength("Mover_Abajo")
	rslook() #Movimiento en circulo del personaje.
	
	if Input.is_action_just_pressed("Atacar"):
		if !Arma_Equipada[4]:
			Ataque = true
			if(Num_Arma_Equipada > 1):
				$RayCast2D.enabled = true
		
	if Input.is_action_just_pressed("Arma_Siguiente"):
		if(!Ataque):
			Change_Arma_UP()
	
	if Input.is_action_just_pressed("Arma_Anterior"):
		if(!Ataque):
			Change_Arma_DOWN()
	
	if Input.is_action_pressed("Correr"):
		run = true
	else:
		run = false;
	
	if Input.is_action_pressed("Atacar"):
		if(Arma_Equipada[4]):
			print("Rifle")
			Ataque = true
			$RayCast2D.enabled = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if (Num_Arma_Equipada != Armas_Disponibles.size()):
		Ataque = false
	$RayCast2D.enabled = false
	target = true
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
	
func Aim():
	if $RayCast2D.is_colliding() && target:
		target = false
		print("colisione con algo")
		var col = $RayCast2D.get_collider()
		if(col.is_in_group("enemigos")):
			col.Reduce_Life(25)
