extends Area3D

@export var weapon_label := "ASSAULT RIFLE"

func _ready() -> void:
    add_to_group("dropped_weapons")
    var body := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 1.1
    body.shape = shape
    add_child(body)
    var rifle := MeshInstance3D.new()
    var receiver := BoxMesh.new()
    receiver.size = Vector3(0.16, 0.16, 0.82)
    rifle.mesh = receiver
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color(0.075, 0.085, 0.07)
    metal.metallic = 0.55
    metal.roughness = 0.42
    rifle.material_override = metal
    rifle.position.y = 0.12
    add_child(rifle)
    var barrel := MeshInstance3D.new()
    var barrel_mesh := CylinderMesh.new()
    barrel_mesh.top_radius = 0.035
    barrel_mesh.bottom_radius = 0.035
    barrel_mesh.height = 0.55
    barrel.mesh = barrel_mesh
    barrel.rotation_degrees.z = 90.0
    barrel.position = Vector3(0.0, 0.12, -0.58)
    barrel.material_override = metal
    add_child(barrel)

func collect(player: Node) -> void:
    if player and player.has_method("pickup_weapon"):
        player.call("pickup_weapon", self)
