extends Node3D
var time = 0
@onready var sun = $DirectionalLight3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += 0.01
	match time:
		1:
			sun.rotation = -30
