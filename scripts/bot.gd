extends CharacterBody3D
class_name SangramBot

@export var max_health := 100.0
@export var move_speed := 3.2
@export var detection_range := 48.0
@export var weapon_range := 34.0
@export var fire_interval := 1.15
@export var damage_per_shot := 8.0

var health := 100.0
var target: Node3D
var attack_timer := 0.0
var alive := true
var visual_root: Node3D
var visual_animation: AnimationPlayer
var visual_animation_name := ""

func _ready() -> void:
    health = max_health
    add_to_group("bots")
    _build_soldier()

func _build_soldier() -> void:
    visual_root = Node3D.new()
    add_child(visual_root)
    var model_paths := [
        "res://assets/characters/Rifleman.glb",
        "res://assets/characters/ReconScout.glb",
        "res://assets/characters/ArmySniper.glb",
        "res://assets/characters/CombatMedic.glb"
    ]
    var model_path: String = model_paths[randi_range(0, model_paths.size() - 1)]
    if ResourceLoader.exists(model_path):
        var model_scene := load(model_path) as PackedScene
        if model_scene:
            var model := model_scene.instantiate()
            model.rotation.y = PI
            visual_root.add_child(model)
            visual_animation = _find_animation_player(model)
            _play_visual_animation("Idle")
    if visual_animation == null:
        _build_procedural_soldier()

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.38
    shape.height = 1.8
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

func _build_procedural_soldier() -> void:
    _part(Vector3(0, 1.0, 0), Vector3(0.62, 0.78, 0.34), Color(0.23, 0.29, 0.22))
    _part(Vector3(0, 1.53, 0), Vector3(0.38, 0.42, 0.38), Color(0.57, 0.43, 0.32), true)
    _part(Vector3(0, 1.78, 0), Vector3(0.48, 0.22, 0.46), Color(0.13, 0.17, 0.14))
    _part(Vector3(0, 1.08, 0.2), Vector3(0.66, 0.52, 0.16), Color(0.11, 0.15, 0.13))
    _part(Vector3(-0.39, 1.04, 0), Vector3(0.19, 0.62, 0.2), Color(0.23, 0.29, 0.22))
    _part(Vector3(0.39, 1.04, 0), Vector3(0.19, 0.62, 0.2), Color(0.23, 0.29, 0.22))
    _part(Vector3(-0.18, 0.39, 0), Vector3(0.23, 0.72, 0.25), Color(0.12, 0.15, 0.13))
    _part(Vector3(0.18, 0.39, 0), Vector3(0.23, 0.72, 0.25), Color(0.12, 0.15, 0.13))
    _part(Vector3(0.34, 1.16, -0.43), Vector3(0.11, 0.12, 0.78), Color(0.055, 0.065, 0.06))

func _find_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var found := _find_animation_player(child)
        if found:
            return found
    return null

func _play_visual_animation(animation_name: String) -> void:
    if visual_animation and visual_animation.has_animation(animation_name) and visual_animation_name != animation_name:
        visual_animation.play(animation_name)
        visual_animation_name = animation_name

func _update_visual_animation() -> void:
    if visual_animation == null or not alive:
        return
    var horizontal_speed := Vector2(velocity.x, velocity.z).length()
    var next_animation := "Idle"
    if horizontal_speed > 0.2:
        next_animation = "Run" if horizontal_speed > move_speed * 0.85 else "Walk"
    _play_visual_animation(next_animation)

func _part(pos: Vector3, size: Vector3, color: Color, sphere := false) -> void:
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
    material.roughness = 0.84
    mesh.material_override = material
    visual_root.add_child(mesh)

func _physics_process(delta: float) -> void:
    if not alive or not is_instance_valid(target):
        return
    attack_timer = maxf(0.0, attack_timer - delta)
    var offset := target.global_position - global_position
    offset.y = 0.0
    var distance := offset.length()
    if distance > detection_range:
        velocity.x = move_toward(velocity.x, 0.0, move_speed * delta * 2.0)
        velocity.z = move_toward(velocity.z, 0.0, move_speed * delta * 2.0)
    elif distance > 11.0:
        var direction := offset.normalized()
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
        look_at(global_position + direction, Vector3.UP)
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed * delta * 2.0)
        velocity.z = move_toward(velocity.z, 0.0, move_speed * delta * 2.0)
        if distance > 0.1:
            look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)

    if distance <= weapon_range and attack_timer <= 0.0 and _has_line_of_sight():
        attack_timer = fire_interval
        if target.has_method("take_damage"):
            target.call("take_damage", damage_per_shot)

    if not is_on_floor():
        velocity.y -= 22.0 * delta
    move_and_slide()
    _update_visual_animation()

func _has_line_of_sight() -> bool:
    if not is_instance_valid(target):
        return false
    var origin := global_position + Vector3.UP * 1.35
    var destination := target.global_position + Vector3.UP * 1.1
    var query := PhysicsRayQueryParameters3D.create(origin, destination, 1, [get_rid()])
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    return hit.is_empty() or hit.get("collider") == target

func take_damage(amount: float, attacker: Node = null) -> void:
    if not alive:
        return
    health = maxf(0.0, health - amount)
    if health <= 0.0:
        alive = false
        velocity = Vector3.ZERO
        set_physics_process(false)
        _play_visual_animation("Death")
        get_tree().call_group("game_manager", "bot_eliminated", attacker)
        get_tree().create_timer(2.0).timeout.connect(queue_free)
