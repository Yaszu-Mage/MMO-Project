extends Node3D
@onready var player = $plr
var time = 0
@onready var sun: DirectionalLight3D = $sun

func _ready():
	pass

func _process(delta: float) -> void:
	time += 0.0001
	sun.rotation.x = time
