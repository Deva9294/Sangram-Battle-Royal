extends CharacterBody3D
class_name SangramPlayer

@export var move_speed := 7.0
@export var sprint_speed := 10.5
@export var crouch_speed := 4.0
@export var prone_speed := 2.0
@export var mouse_sensitivity := 0.0025
@export var jump_velocity := 7.0
@export var gravity_strength := 22.0
@export var fire_interval := 0.13
@export var bullet_damage := 34.0

const STAND_HEIGHT := 1.8
const CROUCH_HEIGHT := 1.2
const PRONE_HEIGHT := 0.62
const STAND_CAMERA := Vector3(0.0, 1.0, 5.5)
const CROUCH_CAMERA := Vector3(0.0, 0.72, 4.8)
const PRONE_CAMERA := Vector3(0.0, 0.42, 3.8)
const STAND_FOV := 75.0
const ADS_FOV := 55.0

var health := 100.0
var ammo := 30
var reserve_ammo := 120
var fire_cooldown := 0.0
var reload_time := 0.0
var mobile_move := Vector2.ZERO
var mobile_fire := false
var look_touch := -1
var look_last := Vector2.ZERO
var eliminated := false
var camera: Camera3D
var camera_pivot: Node3D
var gun_ray: RayCast3D
var player_collision: CollisionShape3D
var player_visual: MeshInstance3D
var hud
var current_stance := "stand"
var target_camera_position := STAND_CAMERA
var target_fov := STAND_FOV
var recoil_pitch := 0.0
var recoil_yaw := 0.0

func _ready() -> void:
    add_to_group("player")
    player_visual = MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.42
    capsule.height = STAND_HEIGHT
    player_visual.mesh = capsule
    player_visual.position.y = STAND_HEIGHT * 0.5
    player_visual.material_override = _mat(Color(0.12, 0.28, 0.68))
    add_child(player_visual)

    player_collision = CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.42
    shape.height = STAND_HEIGHT
    player_collision.shape = shape
    player_collision.position.y = STAND_HEIGHT * 0.5
    add_child(player_collision)

    camera_pivot = Node3D.new()
    camera_pivot.name = "CameraPivot"
    camera_pivot.position.y = 1.55
    add_child(camera_pivot)

    camera = Camera3D.new()
    camera.position = STAND_CAMERA
    camera.rotation.x = deg_to_rad(-10.0)
    camera.fov = STAND_FOV
    camera.current = true
    camera_pivot.add_child(camera)

    gun_ray = RayCast3D.new()
    gun_ray.target_position = Vector3(0.0, 0.0, -120.0)
    gun_ray.enabled = true
    camera.add_child(gun_ray)

    if not OS.has_feature("mobile"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _look(event.relative, mouse_sensitivity)
    elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if not OS.has_feature("mobile") and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    elif event is InputEventScreenTouch:
        if event.pressed and event.position.x > get_viewport().size.x * 0.38:
            look_touch = event.index
            look_last = event.position
        elif not event.pressed and event.index == look_touch:
            look_touch = -1
    elif event is InputEventScreenDrag and event.index == look_touch:
        var delta := event.position - look_last
        _look(delta, 0.004)
        look_last = event.position

func _look(delta: Vector2, sensitivity: float) -> void:
    rotate_y(-delta.x * sensitivity)
    camera.rotation.x = clampf(
        camera.rotation.x - delta.y * sensitivity,
        deg_to_rad(-65.0),
        deg_to_rad(35.0)
    )

func _physics_process(delta: float) -> void:
    if eliminated:
        return

    fire_cooldown = maxf(0.0, fire_cooldown - delta)
    _update_reload(delta)
    _update_stance(delta)
    _update_camera(delta)
    _update_movement(delta)

    if Input.is_action_just_pressed("reload"):
        reload()
    if Input.is_action_pressed("fire") or mobile_fire:
        shoot()

func _update_movement(delta: float) -> void:
    var keyboard := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var input_vector := (keyboard + mobile_move).limit_length(1.0)
    var direction := (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

    var speed := move_speed
    if current_stance == "prone":
        speed = prone_speed
    elif current_stance == "crouch":
        speed = crouch_speed
    elif Input.is_action_pressed("sprint") and input_vector.y < -0.1 and not Input.is_action_pressed("aim"):
        speed = sprint_speed

    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    if not is_on_floor():
        velocity.y -= gravity_strength * delta
    elif Input.is_action_just_pressed("jump") and current_stance == "stand":
        velocity.y = jump_velocity

    move_and_slide()

func _update_stance(delta: float) -> void:
    var desired := "stand"
    if Input.is_action_pressed("prone"):
        desired = "prone"
    elif Input.is_action_pressed("crouch"):
        desired = "crouch"

    var desired_height := STAND_HEIGHT
    if desired == "crouch":
        desired_height = CROUCH_HEIGHT
    elif desired == "prone":
        desired_height = PRONE_HEIGHT

    var shape := player_collision.shape as CapsuleShape3D
    var next_height := move_toward(shape.height, desired_height, 3.5 * delta)
    if desired_height > shape.height and _has_headroom(desired_height - shape.height):
        next_height = shape.height
    shape.height = next_height
    player_collision.position.y = next_height * 0.5
    var visual_capsule := player_visual.mesh as CapsuleMesh
    visual_capsule.height = next_height
    player_visual.position.y = next_height * 0.5
    current_stance = desired

    if desired == "prone":
        target_camera_position = PRONE_CAMERA
    elif desired == "crouch":
        target_camera_position = CROUCH_CAMERA
    else:
        target_camera_position = STAND_CAMERA

func _has_headroom(extra_height: float) -> bool:
    if extra_height <= 0.01:
        return false
    return test_move(global_transform, Vector3.UP * (extra_height + 0.08))

func _update_camera(delta: float) -> void:
    var aiming := Input.is_action_pressed("aim") and current_stance != "prone"
    target_fov = ADS_FOV if aiming else STAND_FOV
    if Input.is_action_pressed("sprint") and current_stance == "stand" and not aiming:
        target_fov = 82.0
    camera.position = camera.position.lerp(target_camera_position, minf(1.0, delta * 8.0))
    camera.fov = lerpf(camera.fov, target_fov, minf(1.0, delta * 9.0))
    if recoil_pitch != 0.0 or recoil_yaw != 0.0:
        camera.rotation.x = clampf(camera.rotation.x + recoil_pitch, deg_to_rad(-65.0), deg_to_rad(35.0))
        rotate_y(recoil_yaw)
        recoil_pitch = move_toward(recoil_pitch, 0.0, delta * 1.8)
        recoil_yaw = move_toward(recoil_yaw, 0.0, delta * 1.2)

func _update_reload(delta: float) -> void:
    if reload_time <= 0.0:
        return
    reload_time = maxf(0.0, reload_time - delta)
    if reload_time == 0.0:
        var take := mini(30 - ammo, reserve_ammo)
        ammo += take
        reserve_ammo -= take

func shoot() -> void:
    if fire_cooldown > 0.0 or reload_time > 0.0 or ammo <= 0:
        return
    ammo -= 1
    fire_cooldown = fire_interval
    recoil_pitch = -0.012 if Input.is_action_pressed("aim") else -0.02
    recoil_yaw = randf_range(-0.004, 0.004)
    gun_ray.force_raycast_update()
    if gun_ray.is_colliding():
        var target = gun_ray.get_collider()
        if target and target.has_method("take_damage"):
            target.call("take_damage", bullet_damage)

func reload() -> void:
    if reload_time <= 0.0 and ammo < 30 and reserve_ammo > 0:
        reload_time = 1.6

func take_damage(amount: float) -> void:
    if eliminated:
        return
    health = maxf(0.0, health - amount)
    if health <= 0.0:
        eliminated = true
        if hud:
            hud.show_result(false)

func heal(amount: float) -> void:
    health = minf(100.0, health + amount)

func _mat(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    return material
