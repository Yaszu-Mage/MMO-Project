extends CharacterBody3D
var health = 100
var mana = 100
var stamina = 1000
var double_jump = false
var health_range = [0,100]
var stamina_range = [0,100]
const SPEED = 5.0
var cam_toggle
const JUMP_VELOCITY = 4.5
@onready var cam: Camera3D = $Camera3D
var projectile = preload("res://scenes/projectile.tscn")
var camera = false
var sprintmulti = 1
var slide_multiplier = 4
var last_dir = Vector3.ZERO
var mouse_sensitivity = 0.002
@onready var front: Marker3D = $"Camera3D/bullet spawn"
@onready var healthbar: TextureProgressBar = $Node2D/health
@onready var staminabar: TextureProgressBar = $Node2D/stamina
@onready var manabar: TextureProgressBar = $Node2D/mana

func _ready():
	pass
func _enter_tree():
	set_multiplayer_authority(name.to_int())
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		camera = true
	if camera and cam_toggle:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cam.current = camera
	staminabar.value = stamina / 100


func _physics_process(delta: float) -> void:
	if not is_on_floor():
			velocity += get_gravity() * delta
	if is_multiplayer_authority() and camera:
		if Input.is_action_pressed("slide"):
			velocity = global_position.move_toward(Vector3(front.global_position.x,self.position.y,front.global_position.z),delta)
		
		
		if Input.is_action_pressed("sprint") and stamina > 1 or Input.is_action_pressed("dash") and stamina > 1:
			#Sprint multiplier increases with button
			cam.fov = lerp(cam.fov,90.0,delta * 2)
			sprintmulti = 1.2
			stamina -= 1
			if Input.is_action_pressed("dash"):
				stamina -= 10
		else:
			cam.fov = lerp(cam.fov,75.0,delta * 2)
			sprintmulti = 1
			stamina += 0.5
		if not is_on_floor():
			velocity += get_gravity() * delta
		if is_on_floor():
			double_jump = false
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif  Input.is_action_just_pressed("ui_accept") and !double_jump:
			velocity.y = JUMP_VELOCITY
			double_jump = true
			print("double jump")
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * SPEED * sprintmulti
			velocity.z = direction.z * SPEED * sprintmulti
			last_dir = direction
		elif Input.is_action_pressed("dash"):
			velocity.x = last_dir.x * SPEED * sprintmulti * slide_multiplier
			velocity.z = last_dir.z * SPEED * sprintmulti * slide_multiplier
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority() and camera:
		if event.is_action_pressed("ui_end"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * mouse_sensitivity)
			cam.rotate_x(-event.relative.y * mouse_sensitivity)
			cam.rotation.x = clamp(cam.rotation.x, -1.2,1.2)
		if event is InputEventJoypadMotion and Input.get_joy_axis(0,JOY_AXIS_RIGHT_X) and event is InputEventJoypadMotion and Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y):
			rotate_y(-Input.get_joy_axis(0,JOY_AXIS_RIGHT_X) * (mouse_sensitivity * 100))
			cam.rotate_x(-Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y) * (mouse_sensitivity * 100))
			cam.rotation.x = clamp(cam.rotation.x, -1.2,1.2)
		if event.is_action_pressed("shoot"):
			wizard_time()
		
		

func change_stat(range : Array, value : float, operation : bool, change_value : float):
	if operation:
		#addition
		if comp.is_in_range(range,value + change_value):
			value = value + change_value
	else:
		if comp.is_in_range(range,value - change_value):
			value = value - change_value
		#subtraction

func wizard_time():
	var bulletscene = projectile.instantiate()
	get_parent().add_child(bulletscene)
	var angle = rotation.y
	var tanangle = cam.rotation.x
	bulletscene.global_position = $"Camera3D/bullet spawn".global_position
	bulletscene.dir = -Vector3(sin(angle),-tan(tanangle),cos(angle))
	bulletscene.variablesinstatiated= true
