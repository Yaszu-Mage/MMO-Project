extends Node3D
var time = 0
@onready var sun: DirectionalLight3D = $sun
var player_load = preload("res://scenes/plr.tscn")
var players = []
func _ready():
	multiplayer.peer_connected.connect(player_joined)

func _process(delta: float) -> void:
	time += 0.0001
	sun.rotation.x = time


func player_joined():
	var instance = player_load.instantiate()
	players.append(instance)
	instance.global_position = Vector3(315,728,64)
	instance.camera = true
	add_child(instance)

func player_left():
	pass
