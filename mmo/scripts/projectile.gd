extends Area3D
signal kaboom

@export var sho_velocity = 25
@export var grav = Vector3.DOWN * 20
var velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	velocity += grav * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	emit_signal("kaboom", transform.origin)
	queue_free()
