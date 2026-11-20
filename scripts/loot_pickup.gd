extends Area3D
class_name SangramLootPickup

@export_enum("ammo", "medkit", "armor") var loot_type := "ammo"
@export var amount := 30

var age := 0.0
var base_height := 0.35
var collected := false

func _ready() -> void:
    add_to_group("loot")
    monitoring = true
    monitorable = true
    collision_layer = 0
    collision_mask = 0

    var shape_node := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 1.25
    shape_node.shape = shape
    add_child(shape_node)

    var visual := MeshInstance3D.new()
    var material := StandardMaterial3D.new()
    material.roughness = 0.28
    material.metallic = 0.25
    material.emission_enabled = true
    material.emission_energy_multiplier = 0.55

    match loot_type:
        "medkit":
            var mesh := BoxMesh.new()
            mesh.size = Vector3(0.62, 0.48, 0.62)
            visual.mesh = mesh
            material.albedo_color = Color(0.9, 0.16, 0.12)
            material.emission = Color(0.55, 0.035, 0.025)
        "armor":
            var mesh := CylinderMesh.new()
            mesh.top_radius = 0.38
            mesh.bottom_radius = 0.38
            mesh.height = 0.24
            visual.mesh = mesh
            material.albedo_color = Color(0.12, 0.62, 0.92)
            material.emission = Color(0.02, 0.24, 0.55)
        _:
            var mesh := BoxMesh.new()
            mesh.size = Vector3(0.55, 0.32, 0.42)
            visual.mesh = mesh
            material.albedo_color = Color(0.9, 0.68, 0.12)
            material.emission = Color(0.4, 0.22, 0.015)

    visual.material_override = material
    visual.position.y = 0.35
    add_child(visual)
    base_height = visual.position.y

func _process(delta: float) -> void:
    if collected:
        return
    age += delta
    rotation.y += delta * 0.8
    if get_child_count() > 1:
        var visual := get_child(1) as MeshInstance3D
        if visual:
            visual.position.y = base_height + sin(age * 2.4) * 0.1

func collect(player: Node) -> void:
    if collected or not is_instance_valid(player):
        return
    if player.has_method("add_loot"):
        player.call("add_loot", loot_type, amount)
        collected = true
        queue_free()
