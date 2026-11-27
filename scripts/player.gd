extends CharacterBody3D

@export var move_speed := 5.5
@export var sprint_speed := 8.5
@export var jump_velocity := 5.0
@export var look_sensitivity := 0.003
@export var touch_look_sensitivity := 0.006
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var health := 100
var ammo := 30
var look_touch_id := -1\nvar soldier_visual: Node3D
@onready var pivot: Node3D = $CameraPivot

func _ready() -> void:
    add_to_group("player")
    var visual := Node3D.new()
    visual.name = "SoldierVisual"
    visual.set_script(load("res://scripts/soldier_visual.gd"))
    add_child(visual)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _look(event.relative, look_sensitivity)
    elif event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    elif event is InputEventScreenTouch:
        if event.pressed and event.position.x > get_viewport_rect().size.x * 0.42 and look_touch_id == -1:
            look_touch_id = event.index
        elif not event.pressed and event.index == look_touch_id:
            look_touch_id = -1
    elif event is InputEventScreenDrag and event.index == look_touch_id:
        _look(event.relative, touch_look_sensitivity)
    if event.is_action_pressed("fire"):
        fire()
    if event.is_action_pressed("reload"):
        ammo = 30

func _look(relative: Vector2, sensitivity: float) -> void:
    rotate_y(-relative.x * sensitivity)
    pivot.rotate_x(-relative.y * sensitivity)
    pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-55), deg_to_rad(35))

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    var speed := sprint_speed if Input.is_action_pressed("sprint") else move_speed
    if direction.length() > 0.01:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, speed * 5.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, speed * 5.0 * delta)
    move_and_slide()

func fire() -> void:
    if ammo <= 0:
        return
    ammo -= 1
    var camera := get_viewport().get_camera_3d()
    if camera == null:
        return
    var ray_from := camera.global_position
    var ray_to := ray_from + -camera.global_transform.basis.z * 120.0
    var query := PhysicsRayQueryParameters3D.create(ray_from, ray_to)
    query.exclude = [get_rid()]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit and hit.collider.has_method("take_damage"):
        hit.collider.take_damage(25)

func take_damage(amount: int) -> void:
    health = maxi(0, health - amount)
