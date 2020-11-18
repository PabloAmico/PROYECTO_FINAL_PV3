extends KinematicBody2D

var Vida = 3
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func Quitar_Vida():
	Vida = Vida - 1
	print(Vida)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Vida <= 0):
		queue_free()
	pass
