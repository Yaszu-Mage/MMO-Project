extends Area3D
var kaboom_size = 10
var kaboom_set = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if kaboom_set:
		while kaboom_size > self.scale.x:
			self.scale += Vector3(0.01,0.01,0.01)
