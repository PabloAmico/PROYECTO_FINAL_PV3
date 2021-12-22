extends KinematicBody2D

var Move_Dir = Vector2(0,0)
var Shoot_Dir = Vector2.ZERO

export var Move_Speed = 250
export var Move_Run = 325 #Se mueve un 30% mas rapido
export var run = false
var deadzone = 0.3
var rs_look = Vector2()
var velocity

export var life = 120

var Num_Arma_Equipada

var target

export var Ataque = false

var cooldown_punch = false

var cooldown_knife = false

var time_Run = 0

export var is_dead = false

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

#Array de Animaciones
var Animaciones_Idle = ["Flashlight_Idle", "knife_idle", "Pistol_Idle", "Shotgun_Idle", "Rifle_Idle"]
var Animaciones_Move = ["Flashlight_Move", "knife_move", "Pistol_Move", "Shotgun_Move", "Rifle_Move"]
var Animaciones_Attack = ["flshlight_attack", "knife_attack", "Pistol_Shoot", "Shotgun_Shoot", "Rifle__Shoot"]
var Animaciones_Shoot = [null, null, "Pistol_Shoot", "Shotgun_Shoot", "Rifle__Shoot"]
var Animaciones_Reload = [null, null, "Pistol_Reload", "Shotgun_Reload", "Rifle_Reload"]
var Animaciones_MeleeAttack = [null,null,"Pistol_Attack", "Shotgun_Attack", "Rifle_Attack"]

#Daño de las armas
export(int) var Damage_pistol: int = 0
export(int) var Damage_shotgun: int = 0
export(int) var Damage_rifle: int = 0
export(int) var Damage_punch: int = 0
export(int) var Damage_knife: int = 0

var damage_weapons = []

#Cantidad maxima de balas que se pueden llevar.
export(int) var cant_max_bullet_pistol: int = 120 # 8 cargadores de 15 balas.
export(int) var cant_max_bullet_shotgun: int = 64 # 8 cargadores de 8 balas.
export(int) var cant_max_bullet_rifle : int = 240 # 8 cargadores de 30 balas.

var cant_max_weapons = []

#Balas disponibles.
export(int) var bullets_current_pistol: int = 120
export(int) var bullets_current_shotgun: int = 64
export(int) var bullets_current_rifle: int = 240

var bullets_current_weapons = []

#Cargadores de las armas.

var bullets_in_magazine_pistol = 15
var bullets_in_magazine_shotgun = 8
var bullets_in_magazine_rifle = 30

var bullets_in_magazine_weapons = []

#capacidad maxima cargadores

var max_magazine_pistol = 15
var max_magazine_shotgun = 8
var max_magazine_rifle = 30

var max_magazine_weapons = []

var reloading = false

#Dispersion de las armas y daño de la escopeta a la distancia
var rotation_Raycast = 0

var dispersion_change = false

var disp_Rifle = false

var time_trigger = 0

var time_less_dispersion = 1

#////////////////////////////////////////////////////////////////////////////////////////////////////////////////


func _ready():
	rotation_Raycast = $RayCast2D.rotation_degrees
	Armas_Disponibles = [Desarmado, Tiene_Cuchillo, Tiene_Pistola, Tiene_Escopeta, Tiene_Rifle]
	Num_Arma_Equipada = 0
	target = true
	$RayCast2D.enabled = false
	damage_weapons = [null, null, Damage_pistol, Damage_shotgun, Damage_rifle]
	cant_max_weapons = [null,null, cant_max_bullet_pistol, cant_max_bullet_shotgun, cant_max_bullet_rifle]
	bullets_current_weapons = [null, null, bullets_current_pistol, bullets_current_shotgun, bullets_current_rifle]
	bullets_in_magazine_weapons = [null, null, bullets_in_magazine_pistol, bullets_in_magazine_shotgun, bullets_in_magazine_rifle]
	max_magazine_weapons = [null, null, max_magazine_pistol, max_magazine_shotgun, max_magazine_rifle]
	pass

func _process(delta):
	if disp_Rifle:
		time_less_dispersion -= delta
		if(time_less_dispersion <= 0):
			time_less_dispersion = 1;
			disp_Rifle = false
			$RayCast2D.rotation_degrees = 270
			time_trigger = 0
		pass

func _physics_process(delta):
	
	Aim()
	
	_joypads()
	
	_Set_Animations()
	
	if(run):
		velocity = Move_Dir * Move_Run
		time_Run += delta
	else:
		velocity = Move_Dir * Move_Speed
		if time_Run >= 3:
			$Audio/Stop_Run.play()
			time_Run = 0
		else:
			time_Run = 0
	velocity = move_and_slide(velocity)


func rslook():
	rs_look.y = Input.get_joy_axis(0, JOY_AXIS_3)
	rs_look.x = Input.get_joy_axis(0, JOY_AXIS_2)
	if rs_look.length() >= deadzone:
		rotation = rs_look.angle()


func _Set_Animations():
	if !Ataque && !reloading:
		if velocity == Vector2(0,0):
			$AnimationPlayer.play(Animaciones_Idle[Num_Arma_Equipada])
		else:
			$AnimationPlayer.play(Animaciones_Move[Num_Arma_Equipada])
	elif Ataque:
		$AnimationPlayer.play(Animaciones_Attack[Num_Arma_Equipada])
	elif reloading && Num_Arma_Equipada > 1:
		$AnimationPlayer.play(Animaciones_Reload[Num_Arma_Equipada])
		
	

func _joypads():
	velocity = Vector2.ZERO
	Move_Dir.x = -Input.get_action_strength("Mover_Izquierda") + Input.get_action_strength("Mover_Derecha")
	Move_Dir.y = -Input.get_action_strength("Mover_Arriba") + Input.get_action_strength("Mover_Abajo")
	rslook() #Movimiento en circulo del personaje.
	
	if Input.is_action_just_pressed("Atacar"):
		if Num_Arma_Equipada != 4:
			if(Num_Arma_Equipada > 1 && !reloading):
				if (bullets_in_magazine_weapons[Num_Arma_Equipada] > 0):
					Ataque = true
					$RayCast2D.enabled = true
					bullets_in_magazine_weapons[Num_Arma_Equipada] -= 1
					Sounds_Weapons()
				elif !reloading:
					Reload()
			elif Num_Arma_Equipada <= 1:
				Sounds_Weapons()
				Ataque = true
		
	if Input.is_action_just_pressed("Arma_Siguiente"):
		if(!Ataque && !reloading):
			Change_Arma_UP()
	
	if Input.is_action_just_pressed("Arma_Anterior"):
		if(!Ataque && !reloading):
			Change_Arma_DOWN()
	
	if Input.is_action_pressed("Correr"):
		run = true
	else:
		run = false;
	
	if Input.is_action_pressed("Atacar"):
		if(Num_Arma_Equipada == 4 && !Ataque):
			if(bullets_in_magazine_weapons[4] > 0):
				time_trigger += 0.4
				if(time_trigger >= 1.6):
					Dispersion_Rifle(time_trigger)
				Ataque = true
				$RayCast2D.enabled = true
				bullets_in_magazine_weapons[4] -= 1
				Sounds_Weapons()
			elif !reloading:
				Reload()
	
	if Input.is_action_just_released("Atacar"):
		if(Num_Arma_Equipada == 4):
			disp_Rifle = true
		
	if Input.is_action_just_released("Correr"):
		pass

	
	
	#if Input.action_release("Atacar"):
		
func Sounds_Weapons():
	match Num_Arma_Equipada:
		0:
			if !cooldown_punch:
				$Audio/Punch.play()
				cooldown_punch = true
		1:
				if !cooldown_knife:
					$Audio/Knife.play()
					cooldown_knife = true
		2:
			$Audio/Pistol.play()
		
		3:
			$Audio/Shotgun.play()
		
		4:
			$Audio/Rifle.play()
		


func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == Animaciones_Reload[2]) || (anim_name == Animaciones_Reload[3]) || (anim_name == Animaciones_Reload[4]):
		Assign_Bullets()
		reloading = false
	if (Num_Arma_Equipada != Armas_Disponibles.size()):
		Ataque = false
	$RayCast2D.enabled = false
	target = true
	if anim_name == Animaciones_Attack[0]:
		cooldown_punch = false
	
	if anim_name == Animaciones_Attack[1]:
		cooldown_knife = false
	pass # Replace with function body.

func Set_Arma_Equipada():
	Arma_Equipada[Num_Arma_Equipada] = true
	for i in range(Arma_Equipada.size()-1):
		if(i != Num_Arma_Equipada):
			Arma_Equipada[i] = false


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
		var col = $RayCast2D.get_collider()
		if(col.is_in_group("enemigos")):
			if(Num_Arma_Equipada == 3):
				var distancia = position.distance_to(col.position)
				col.Reduce_Life(Dispersion_Shotgun(distancia))
			else:
				col.Reduce_Life(damage_weapons[Num_Arma_Equipada])


func Reload():
	if !reloading && bullets_current_weapons[Num_Arma_Equipada] > 0:
		$Audio/Reload.play()
		#$AnimationPlayer.play(Animaciones_Reload[Num_Arma_Equipada])
		reloading = true
	else:
		reloading = false
		
	
func Assign_Bullets():
	if bullets_current_weapons[Num_Arma_Equipada] > 0:
		if bullets_current_weapons[Num_Arma_Equipada] >= max_magazine_weapons[Num_Arma_Equipada]:
			var _aux_bullets = bullets_in_magazine_weapons[Num_Arma_Equipada]
			bullets_in_magazine_weapons[Num_Arma_Equipada] = max_magazine_weapons[Num_Arma_Equipada]
			bullets_current_weapons[Num_Arma_Equipada] -= max_magazine_weapons[Num_Arma_Equipada] - _aux_bullets
		elif (bullets_in_magazine_weapons[Num_Arma_Equipada] + bullets_current_weapons[Num_Arma_Equipada]) <= max_magazine_weapons[Num_Arma_Equipada]:
			bullets_in_magazine_weapons[Num_Arma_Equipada] += bullets_current_weapons[Num_Arma_Equipada]
			bullets_current_weapons[Num_Arma_Equipada] = 0
		else:
			bullets_current_weapons[Num_Arma_Equipada] -= (max_magazine_weapons[Num_Arma_Equipada] - bullets_in_magazine_weapons[Num_Arma_Equipada])
			bullets_in_magazine_weapons[Num_Arma_Equipada] = max_magazine_weapons[Num_Arma_Equipada]
	reloading = false
		
func Check_Magazine():
	if max_magazine_weapons[Num_Arma_Equipada] <= 0:
		Reload()

func Dispersion_Shotgun(var distancia):
	
	if distancia < 600:
		return damage_weapons[3]
	elif distancia >= 600 && distancia <= 900:
		return int(damage_weapons[3] / rand_range(1,2.5))
	elif distancia > 900:
		return int(damage_weapons[3] / rand_range(3,5))

func Dispersion_Rifle(var time_press):
	disp_Rifle = false
	if(dispersion_change):
		$RayCast2D.rotation_degrees -= time_press
		dispersion_change = false
	else:
		$RayCast2D.rotation_degrees  += time_press
		dispersion_change = true
	pass



func _on_hitarea_body_entered(body):
	if body.is_in_group("enemigos"):
		if Num_Arma_Equipada == 0:
			body.Reduce_Life(Damage_punch)
			body.punch_received = true
		elif Num_Arma_Equipada == 1:
			body.Reduce_Life(Damage_knife)
			body.stun_received = true
		
func Reduce_Life(var Damage):
	if life > 0:
		life -= Damage
		Sound_damage()
		if(life <= 0):
			Kill_Player()
	else:
		Kill_Player()


func Sound_damage():
	var select = (randi() % 4) -1
	match select:
		0:
			$Audio/Damage_1.play()
		1:
			$Audio/Damage_2.play()
		2: 
			$Audio/Damage_3.play()
	pass


func Kill_Player():
	is_dead = true
	$Audio/Death.play()
	print("Estoy muerto")