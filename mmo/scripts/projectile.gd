extends RigidBody3D
signal kaboom
var explode_instance = preload("res://scenes/explosion.tscn")
@export var sho_velocity = 25
@export var grav = Vector3.DOWN * 20
var velocity = Vector3.ZERO
var dir : Vector3
var variablesinstatiated = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(10.0).timeout
	get_tree().queue_delete(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _physics_process(delta):
	if variablesinstatiated:
		move_and_collide(linear_velocity.move_toward(dir,delta*1987))


func _on_area_3d_body_entered(body):
	if body is CharacterBody3D or body is StaticBody3D:
		self.queue_free()
		var kaboom = explode_instance.instantiate()
		kaboom.global_position = self.global_position
		get_parent().add_child(kaboom)
		kaboom.kaboom_set = true
