extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Multi.server_init(57785)
	Multi.client_join("localhost",57785)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
