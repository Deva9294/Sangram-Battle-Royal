extends Area3D
class_name SangramWeaponPickup

@export var weapon_type := "Assault Rifle"
@export var ammo_amount := 30

var age := 0.0
var collected := false

func _ready() -> void:
    add_to_group("weapon_pickups")
    collision_layer = 0
    collision_mask = 0
    var collision := CollisionShape3D.new()
    var sphere := SphereShape3D.new()
    sphere.radius = 1.6
    collision.shape = sphere
    add_child(collision)

    var body := Node3D.new()
    body.name = "WeaponVisual"
    add_child(body)
    var receiver := MeshInstance3D.new()
    var receiver_mesh := BoxMesh.new()
    receiver_mesh.size = Vector3(0.82, 0.12, 0.16)
    receiver.mesh = receiver_mesh
    receiver.position.y = 0.32
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color(0.12, 0.15, 0.13)
    metal.metallic = 0.68
    metal.roughness = 0.38
    receiver.material_override = metal
    body.add_child(receiver)

    var barrel := MeshInstance3D.new()
    var barrel_mesh := CylinderMesh.new()
    barrel_mesh.top_radius = 0.035
    barrel_mesh.bottom_radius = 0.035
    barrel_mesh.height = 0.62
    barrel.mesh = barrel_mesh
    barrel.rotation.z = PI * 0.5
    barrel.position = Vector3(0.48, 0.32, 0.0)
    barrel.material_override = metal
    body.add_child(barrel)

    var label := Label3D.new()
    label.text = "%s  •  %d" % [weapon_type, ammo_amount]
    label.position.y = 0.85
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.font_size = 28
    body.add_child(label)

func _process(delta: float) -> void:
    if collected:
        return
    age += delta
    rotation.y += delta * 0.65
    position.y = 0.12 + sin(age * 2.0) * 0.06

func collect(player: Node) -> void:
    if collected or not is_instance_valid(player):
        return
    if player.has_method("equip_weapon"):
        player.call("equip_weapon", weapon_type, ammo_amount)
        collected = true
        queue_free()
