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
const PRONE_HEIGHT := 0.90
const STAND_CAMERA := Vector3(0.34, 0.16, 1.72)
const CROUCH_CAMERA := Vector3(0.32, 0.10, 1.62)
const PRONE_CAMERA := Vector3(0.28, 0.10, 1.42)
const STAND_FOV := 58.0
const ADS_FOV := 48.0

var health := 100.0
var armor := 0.0
var medkits := 0
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
var visual_root: Node3D
var muzzle_flash: OmniLight3D
var visual_animation: AnimationPlayer
var visual_animation_name := ""
var hud
var current_stance := "stand"
var target_camera_position := STAND_CAMERA
var target_fov := STAND_FOV
var recoil_pitch := 0.0
var recoil_yaw := 0.0
var spawn_protection := 10.0
var parachuting := false
var parachute_visual: Node3D

func _ready() -> void:
    add_to_group("player")
    player_visual = MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.42
    capsule.height = STAND_HEIGHT
    player_visual.mesh = capsule
    player_visual.position.y = STAND_HEIGHT * 0.5
    player_visual.visible = false
    add_child(player_visual)
    _build_player_visual()

    player_collision = CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.42
    shape.height = STAND_HEIGHT
    player_collision.shape = shape
    player_collision.position.y = STAND_HEIGHT * 0.5
    add_child(player_collision)

    camera_pivot = Node3D.new()
    camera_pivot.name = "CameraPivot"
    camera_pivot.position.y = 1.48
    add_child(camera_pivot)

    camera = Camera3D.new()
    camera.position = STAND_CAMERA
    camera.rotation.x = deg_to_rad(-7.0)
    camera.fov = STAND_FOV
    camera.current = true
    camera_pivot.add_child(camera)

    gun_ray = RayCast3D.new()
    gun_ray.target_position = Vector3(0.0, 0.0, -120.0)
    gun_ray.enabled = true
    camera.add_child(gun_ray)

    if not OS.has_feature("mobile"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_player_visual() -> void:
    visual_root = Node3D.new()
    add_child(visual_root)
    var model_path := "res://assets/characters/InfantrySoldier.glb"
    var imported_model_loaded := false
    if ResourceLoader.exists(model_path):
        var model_scene := load(model_path) as PackedScene
        if model_scene:
            var model := model_scene.instantiate() as Node3D
            if model:
                model.rotation.y = PI
                visual_root.add_child(model)
                _fit_character_model(model, 1.82)
                model.visible = true
                _set_model_meshes_visible(model)
                imported_model_loaded = _contains_renderable_mesh(model)
                if imported_model_loaded:
                    visual_animation = _find_animation_player(model)
                    _play_visual_animation("idle")
                else:
                    model.queue_free()
    # Keep a valid imported soldier even when its animation node is absent.
    if not imported_model_loaded:
        _build_procedural_soldier()
    _attach_rifle_model()

    muzzle_flash = OmniLight3D.new()
    muzzle_flash.position = Vector3(0.35, 1.23, -1.12)
    muzzle_flash.light_color = Color(1.0, 0.62, 0.18)
    muzzle_flash.light_energy = 0.0
    muzzle_flash.omni_range = 4.0
    visual_root.add_child(muzzle_flash)

func _attach_rifle_model() -> void:
    var weapon_path := "res://assets/weapons/Rifle_Assault_West.glb"
    if not ResourceLoader.exists(weapon_path):
        return
    var packed := load(weapon_path) as PackedScene
    if packed == null:
        return
    var weapon := packed.instantiate() as Node3D
    if weapon == null:
        return
    var weapon_mount := Node3D.new()
    weapon_mount.position = Vector3(0.34, 1.22, -0.34)
    weapon_mount.rotation_degrees = Vector3(0.0, 90.0, 0.0)
    weapon_mount.scale = Vector3.ONE * 0.55
    visual_root.add_child(weapon_mount)
    weapon_mount.add_child(weapon)

func _fit_character_model(model: Node3D, target_height: float) -> void:
    # Imported GLB assets use inconsistent units/origin; normalize to human scale.
    var combined := AABB()
    var found := false
    var model_inverse := model.global_transform.affine_inverse()
    var stack: Array[Node] = [model]
    while not stack.is_empty():
        var node: Node = stack.pop_back()
        if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
            var mesh_instance := node as MeshInstance3D
            var mesh_bounds: AABB = model_inverse * mesh_instance.global_transform * mesh_instance.get_aabb()
            combined = mesh_bounds if not found else combined.merge(mesh_bounds)
            found = true
        for child in node.get_children():
            stack.append(child)
    if found and combined.size.y > 0.01:
        var scale_factor := target_height / combined.size.y
        model.scale *= scale_factor
        model.position.y -= combined.position.y * scale_factor

func _build_procedural_soldier() -> void:
    _soldier_part(Vector3(0, 1.05, 0), Vector3(0.62, 0.78, 0.36), Color(0.17, 0.25, 0.18))
    _soldier_part(Vector3(0, 1.58, 0), Vector3(0.36, 0.42, 0.36), Color(0.62, 0.45, 0.34), true)
    _soldier_part(Vector3(0, 1.82, 0), Vector3(0.48, 0.22, 0.46), Color(0.10, 0.15, 0.12))
    _soldier_part(Vector3(0, 1.12, 0.20), Vector3(0.68, 0.56, 0.16), Color(0.08, 0.12, 0.10))
    _soldier_part(Vector3(-0.39, 1.08, 0), Vector3(0.19, 0.62, 0.20), Color(0.17, 0.25, 0.18))
    _soldier_part(Vector3(0.39, 1.08, 0), Vector3(0.19, 0.62, 0.20), Color(0.17, 0.25, 0.18))
    _soldier_part(Vector3(-0.18, 0.39, 0), Vector3(0.23, 0.72, 0.25), Color(0.10, 0.13, 0.11))
    _soldier_part(Vector3(0.18, 0.39, 0), Vector3(0.23, 0.72, 0.25), Color(0.10, 0.13, 0.11))
    _soldier_part(Vector3(-0.18, 0.06, 0.08), Vector3(0.32, 0.16, 0.44), Color(0.045, 0.05, 0.045))
    _soldier_part(Vector3(0.18, 0.06, 0.08), Vector3(0.32, 0.16, 0.44), Color(0.045, 0.05, 0.045))
    _soldier_part(Vector3(-0.2, 1.12, -0.12), Vector3(0.16, 0.22, 0.14), Color(0.62, 0.43, 0.18))
    _soldier_part(Vector3(0.0, 1.12, -0.12), Vector3(0.16, 0.22, 0.14), Color(0.62, 0.43, 0.18))

func _set_model_meshes_visible(node: Node) -> void:
    if node is VisualInstance3D:
        node.visible = true
    for child in node.get_children():
        _set_model_meshes_visible(child)

func _contains_renderable_mesh(node: Node) -> bool:
    if node is MeshInstance3D and node.mesh != null:
        return true
    for child in node.get_children():
        if _contains_renderable_mesh(child):
            return true
    return false

func _find_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var found := _find_animation_player(child)
        if found:
            return found
    return null

func _play_visual_animation(animation_name: String) -> void:
    if visual_animation == null:
        return
    var wanted := animation_name.to_lower()
    var selected := ""
    for candidate in visual_animation.get_animation_list():
        var candidate_lower := candidate.to_lower()
        if candidate_lower == wanted:
            selected = candidate
            break
        if selected == "" and candidate_lower.contains(wanted):
            selected = candidate
    if selected != "" and visual_animation_name != selected:
        visual_animation.play(selected)
        visual_animation_name = selected

func _update_visual_animation() -> void:
    if visual_animation == null:
        return
    var horizontal_speed := Vector2(velocity.x, velocity.z).length()
    var next_animation := "Idle"
    if horizontal_speed > 0.2:
        next_animation = "Run" if horizontal_speed > move_speed * 0.88 else "Walk"
    _play_visual_animation(next_animation)

func _soldier_part(pos: Vector3, size: Vector3, color: Color, sphere := false) -> void:
    var mesh := MeshInstance3D.new()
    if sphere:
        var sphere_mesh := SphereMesh.new()
        sphere_mesh.radius = size.x * 0.5
        sphere_mesh.height = size.y
        mesh.mesh = sphere_mesh
    else:
        var box := BoxMesh.new()
        box.size = size
        mesh.mesh = box
    mesh.position = pos
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.82
    mesh.material_override = material
    visual_root.add_child(mesh)

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
        var drag_event := event as InputEventScreenDrag
        var look_delta: Vector2 = drag_event.position - look_last
        _look(look_delta, 0.004)
        look_last = drag_event.position

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

    spawn_protection = maxf(0.0, spawn_protection - delta)
    fire_cooldown = maxf(0.0, fire_cooldown - delta)
    _update_reload(delta)
    _update_stance(delta)
    _update_camera(delta)
    _update_movement(delta)
    _update_visual_animation()

    if Input.is_action_just_pressed("reload"):
        reload()
    if Input.is_action_just_pressed("interact"):
        interact()
    if Input.is_action_just_pressed("use_medkit"):
        use_medkit()
    if Input.is_action_pressed("fire") or mobile_fire:
        shoot()

func _update_movement(delta: float) -> void:
    var keyboard := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var input_vector := (keyboard + mobile_move).limit_length(1.0)
    var direction := (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

    var speed := move_speed
    if parachuting:
        speed = 4.2
    elif current_stance == "prone":
        speed = prone_speed
    elif current_stance == "crouch":
        speed = crouch_speed
    elif Input.is_action_pressed("sprint") and input_vector.y < -0.1 and not Input.is_action_pressed("aim"):
        speed = sprint_speed

    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    if parachuting:
        velocity.y = -5.2
    elif not is_on_floor():
        velocity.y -= gravity_strength * delta
    elif Input.is_action_just_pressed("jump") and current_stance == "stand":
        velocity.y = jump_velocity

    move_and_slide()
    if parachuting and is_on_floor():
        parachuting = false
        if parachute_visual and is_instance_valid(parachute_visual):
            parachute_visual.queue_free()
        if hud:
            hud.show_message("LANDING COMPLETE  •  FIND WEAPONS")

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
        target_fov = 72.0

    # Smooth shoulder camera with a physics ray so it never clips through walls.
    var wanted_position := target_camera_position
    var ray_start := camera_pivot.global_position
    var ray_end := camera_pivot.to_global(wanted_position)
    var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end, 1, [get_rid()])
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty():
        var safe_point: Vector3 = hit.position + hit.normal * 0.16
        wanted_position = camera_pivot.to_local(safe_point)
        wanted_position.z = maxf(wanted_position.z, 0.28)

    camera.position = camera.position.lerp(wanted_position, minf(1.0, delta * 12.0))
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
    if muzzle_flash:
        muzzle_flash.light_energy = 2.2
        get_tree().create_timer(0.055).timeout.connect(func():
            if is_instance_valid(muzzle_flash):
                muzzle_flash.light_energy = 0.0
        )
    gun_ray.force_raycast_update()
    if gun_ray.is_colliding():
        var target = gun_ray.get_collider()
        if target and target.has_method("take_damage"):
            target.call("take_damage", bullet_damage, self)

func reload() -> void:
    if reload_time <= 0.0 and ammo < 30 and reserve_ammo > 0:
        reload_time = 1.6

func take_damage(amount: float) -> void:
    if eliminated or spawn_protection > 0.0:
        return
    var absorbed := minf(armor, amount * 0.65)
    armor -= absorbed
    health = maxf(0.0, health - (amount - absorbed))
    if hud:
        hud.show_damage()
    if health <= 0.0:
        eliminated = true
        _play_visual_animation("Death")
        if hud:
            hud.show_result(false)
        get_tree().call_group("game_manager", "player_eliminated")

func heal(amount: float) -> void:
    health = minf(100.0, health + amount)

func add_loot(loot_type: String, amount: int) -> void:
    match loot_type:
        "ammo":
            var before := reserve_ammo
            reserve_ammo = mini(240, reserve_ammo + amount)
            if hud:
                hud.show_message("AMMO +%d" % (reserve_ammo - before))
        "medkit":
            medkits += 1
            if hud:
                hud.show_message("MEDKIT COLLECTED")
        "armor":
            var before := armor
            armor = minf(100.0, armor + float(amount))
            if hud:
                hud.show_message("ARMOR +%d" % int(armor - before))

func interact() -> void:
    var nearest: Node = null
    var nearest_distance := 3.0
    for pickup in get_tree().get_nodes_in_group("loot"):
        if not is_instance_valid(pickup):
            continue
        var distance := global_position.distance_to(pickup.global_position)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest = pickup
    if nearest and nearest.has_method("collect"):
        nearest.call("collect", self)
    elif hud:
        hud.show_message("NO LOOT NEARBY")

func use_medkit() -> void:
    if medkits <= 0 or health >= 100.0:
        if hud:
            hud.show_message("NO MEDKIT OR HEALTH FULL")
        return
    medkits -= 1
    heal(45.0)
    if hud:
        hud.show_message("MEDKIT USED  +45 HP")

func _mat(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    return material
