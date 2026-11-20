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

func _ready() -> void:
    health = max_health
    add_to_group("bots")
    _build_soldier()

func _build_soldier() -> void:
    visual_root = Node3D.new()
    add_child(visual_root)
    _part(Vector3(0, 1.0, 0), Vector3(0.62, 0.78, 0.34), Color(0.23, 0.29, 0.22))
    _part(Vector3(0, 1.53, 0), Vector3(0.38, 0.42, 0.38), Color(0.57, 0.43, 0.32), true)
    _part(Vector3(0, 1.78, 0), Vector3(0.48, 0.22, 0.46), Color(0.13, 0.17, 0.14))
    _part(Vector3(0, 1.08, 0.2), Vector3(0.66, 0.52, 0.16), Color(0.11, 0.15, 0.13))
    _part(Vector3(-0.39, 1.04, 0), Vector3(0.19, 0.62, 0.2), Color(0.23, 0.29, 0.22))
    _part(Vector3(0.39, 1.04, 0), Vector3(0.19, 0.62, 0.2), Color(0.23, 0.29, 0.22))
    _part(Vector3(-0.18, 0.39, 0), Vector3(0.23, 0.72, 0.25), Color(0.12, 0.15, 0.13))
    _part(Vector3(0.18, 0.39, 0), Vector3(0.23, 0.72, 0.25), Color(0.12, 0.15, 0.13))
    _part(Vector3(0.34, 1.16, -0.43), Vector3(0.11, 0.12, 0.78), Color(0.055, 0.065, 0.06))
    _part(Vector3(0.34, 1.16, -0.84), Vector3(0.09, 0.09, 0.34), Color(0.09, 0.10, 0.09))
    _part(Vector3(0.34, 1.16, -0.1), Vector3(0.16, 0.2, 0.16), Color(0.08, 0.09, 0.08))

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.38
    shape.height = 1.8
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

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
        get_tree().call_group("game_manager", "bot_eliminated", attacker)
        queue_free()
