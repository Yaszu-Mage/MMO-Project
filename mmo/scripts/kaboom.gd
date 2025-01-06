extends Area3D
var kaboom_size = 10
var kaboom_set = false
var waiting = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if kaboom_set:
		while !(kaboom_size < self.scale.x):
			self.scale = self.scale + Vector3(1,1,1)
			await get_tree().create_timer(0.1).timeout
		await get_tree().create_timer(1.5).timeout
		while self.scale.x > 0:
			self.scale = self.scale + Vector3(-1,-1,-1)
			await get_tree().create_timer(0.1).timeout
		self.queue_free()
