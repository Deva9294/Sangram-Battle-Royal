extends CharacterBody3D
class_name SangramPlayer

@export var move_speed := 7.0
@export var mouse_sensitivity := 0.0025
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
var gun_ray: RayCast3D
var hud

func _ready():
    add_to_group("player")
    var capsule = CapsuleMesh.new()
    capsule.radius = 0.42
    capsule.height = 1.8
    var visual = MeshInstance3D.new()
    visual.mesh = capsule
    visual.position.y = 0.9
    visual.material_override = _mat(Color(0.12, 0.28, 0.68))
    add_child(visual)
    var col = CollisionShape3D.new()
    var shape = CapsuleShape3D.new()
    shape.radius = 0.42
    shape.height = 1.8
    col.shape = shape
    col.position.y = 0.9
    add_child(col)
    var pivot = Node3D.new()
    pivot.name = "CameraPivot"
    pivot.position.y = 1.55
    add_child(pivot)
    camera = Camera3D.new()
    camera.position = Vector3(0, 1.0, 5.5)
    camera.rotation.x = deg_to_rad(-10)
    camera.current = true
    pivot.add_child(camera)
    gun_ray = RayCast3D.new()
    gun_ray.target_position = Vector3(0, 0, -120)
    gun_ray.enabled = true
    camera.add_child(gun_ray)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera.rotation.x = clamp(camera.rotation.x - event.relative.y * mouse_sensitivity, deg_to_rad(-65), deg_to_rad(35))
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x > get_viewport().size.x * 0.38:
            look_touch = event.index
            look_last = event.position
        elif not event.pressed and event.index == look_touch:
            look_touch = -1
    if event is InputEventScreenDrag and event.index == look_touch:
        var delta = event.position - look_last
        rotate_y(-delta.x * 0.004)
        camera.rotation.x = clamp(camera.rotation.x - delta.y * 0.004, deg_to_rad(-65), deg_to_rad(35))
        look_last = event.position

func _physics_process(delta):
    if eliminated: return
    fire_cooldown = maxf(0.0, fire_cooldown - delta)
    if reload_time > 0:
        reload_time -= delta
        if reload_time <= 0:
            var take = mini(30 - ammo, reserve_ammo)
            ammo += take
            reserve_ammo -= take
    var keys = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction_input = keys + mobile_move
    direction_input = direction_input.limit_length(1.0)
    var direction = (transform.basis * Vector3(direction_input.x, 0, direction_input.y)).normalized()
    velocity.x = direction.x * move_speed
    velocity.z = direction.z * move_speed
    if not is_on_floor(): velocity.y -= 22.0 * delta
    elif Input.is_action_just_pressed("ui_accept"): velocity.y = 7.0
    move_and_slide()
    if Input.is_action_pressed("fire") or mobile_fire:
        shoot()

func shoot():
    if fire_cooldown > 0 or reload_time > 0 or ammo <= 0: return
    ammo -= 1
    fire_cooldown = 0.13
    gun_ray.force_raycast_update()
    if gun_ray.is_colliding():
        var target = gun_ray.get_collider()
        if target and target.has_method("take_damage"):
            target.take_damage(34.0)

func reload():
    if reload_time <= 0 and ammo < 30 and reserve_ammo > 0:
        reload_time = 1.6

func take_damage(amount):
    if eliminated: return
    health = maxf(0.0, health - amount)
    if health <= 0:
        eliminated = true
        if hud: hud.show_result(false)

func heal(amount):
    health = minf(100.0, health + amount)

func _mat(color: Color) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = color
    return m
