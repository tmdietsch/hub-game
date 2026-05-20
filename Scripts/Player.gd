extends CharacterBody3D

var is_in_console = false
var current_game: Node3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

# fov variables
const BASE_FOV = 90.0
const ZOOM_FOV = 30.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not is_in_console:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_local_gravity() * delta
		
	# Free mouse
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if is_in_console:
		if Input.is_action_just_pressed("playgamewindow"):
			is_in_console = false
			current_game.set_pause(true)
		return
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
		
	# Handle zoom
	if Input.is_action_pressed("zoom"):
		camera.fov = ZOOM_FOV
	else:
		camera.fov = BASE_FOV

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
		
	# Raycast
	if Input.is_action_just_pressed("playgamewindow"):
		do_raycast()
	
	move_and_slide()

func do_raycast():
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - camera.global_transform.basis.z * 100)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var collision: Dictionary = space.intersect_ray(query)
	if collision:
		var collider: Area3D = collision.collider
		if collider.name != 'ConsoleTrigger':
			return
		
		current_game = collider.get_parent_node_3d().get_parent_node_3d()
		current_game.set_pause(false)
		is_in_console = true
		
func get_local_gravity():
	if is_in_console:
		return Vector3.ZERO
	else:
		return get_gravity()
