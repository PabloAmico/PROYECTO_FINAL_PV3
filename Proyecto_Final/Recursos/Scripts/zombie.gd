extends KinematicBody2D

var Vida = 3
var Estado_Actual
var Estado_Anterior

func _ready():
	pass 

func Quitar_Vida():
	Vida = Vida - 1
	print(Vida)

func _process(delta):
	if(Vida <= 0):
		queue_free()
	pass

func _physics_process(delta):
	pass

func Cambiar_Estado(Nuevo_Estado):
	Estado_Anterior = Estado_Actual
	Estado_Actual = Nuevo_Estado
	print("Se cambio de estado")

func Estado_Idle():
	$AnimacionZombie.play("Zombie_Idle")

func _on_Timer_Cambio_Estado_timeout():
	pass # Replace with function body.
