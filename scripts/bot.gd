extends CharacterBody3D
class_name SangramBot

var health := 100.0
var target: Node3D
var attack_timer := 0.0
var speed := 2.5
var alive := true

func _ready():
    var body = MeshInstance3D.new()
    var mesh = CapsuleMesh.new()
    mesh.radius = 0.4
    mesh.height = 1.7
    body.mesh = mesh
    body.position.y = 0.85
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.65, 0.16, 0.12)
    body.material_override = material
    add_child(body)
    var collision = CollisionShape3D.new()
    var shape = CapsuleShape3D.new()
    shape.radius = 0.4
    shape.height = 1.7
    collision.shape = shape
    collision.position.y = 0.85
    add_child(collision)

func _physics_process(delta):
    if not alive or not is_instance_valid(target): return
    attack_timer = maxf(0.0, attack_timer - delta)
    var offset = target.global_position - global_position
    offset.y = 0
    var distance = offset.length()
    if distance > 2.4:
        var dir = offset.normalized()
        velocity.x = dir.x * speed
        velocity.z = dir.z * speed
        look_at(global_position + dir, Vector3.UP)
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
        if attack_timer <= 0:
            attack_timer = 1.15
            target.take_damage(7.0)
    if not is_on_floor(): velocity.y -= 20.0 * delta
    move_and_slide()

func take_damage(amount):
    if not alive: return
    health -= amount
    if health <= 0:
        alive = false
        queue_free()
        get_tree().call_group("game_manager", "bot_eliminated")
