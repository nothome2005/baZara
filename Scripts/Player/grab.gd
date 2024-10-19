extends RayCast3D

@export var max_grab_distance: float = 5.0
@export var grabbed_object: RigidBody3D = null
@export var move_speed: float = 10.0  # Speed at which the object will move

var last_position: Vector3
var is_server: bool

func _ready() -> void:
	is_server = multiplayer.is_server()

func _process(_delta: float) -> void:
	pass

func try_grab_object() -> void:
	force_raycast_update()  # Update the state of RayCast3D
	if is_colliding():
		var collider = get_collider()
		if collider is RigidBody3D and get_collision_point().distance_to(global_transform.origin) <= max_grab_distance:
			grabbed_object = collider  # Grab the object
			last_position = grabbed_object.global_position  # Remember current position
			print("Object grabbed:", grabbed_object.name)
			if is_server:
				rpc("sync_grab_object", grabbed_object.name)

func release_object() -> void:
	if grabbed_object:
		if is_server:
			rpc("sync_release_object", grabbed_object.name)
		grabbed_object = null
		print("Object released")

@rpc("any_peer", "reliable")
func sync_grab_object(object_name: String) -> void:
	if has_node(object_name):
		grabbed_object = get_node(object_name) as RigidBody3D

@rpc("any_peer", "reliable")
func sync_release_object(object_name: String) -> void:
	if grabbed_object and grabbed_object.name == object_name:
		grabbed_object = null

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("LCM"):
		if grabbed_object == null:
			try_grab_object()
		else:
			release_object()
	
	if grabbed_object:
		# Smoothly move the object to the target marker
		var target_position = $Marker3D.global_position
		var direction = target_position - grabbed_object.global_position
		# Move object with speed limitation
		var movement = direction.normalized() * move_speed * _delta
		# Check for small distance to avoid jitter
		if direction.length() > movement.length():
			grabbed_object.global_transform.origin += movement
		else:
			grabbed_object.global_transform.origin = target_position  # Snap to target if close
			if is_server:
				rpc("sync_object_position", grabbed_object.name, grabbed_object.global_transform.origin)

@rpc("any_peer", "reliable")
func sync_object_position(object_name: String, position: Vector3) -> void:
	if has_node(object_name):
		var obj = get_node(object_name) as RigidBody3D
		obj.global_transform.origin = position
