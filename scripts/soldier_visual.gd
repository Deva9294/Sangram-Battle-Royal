extends Node3D
# Temporary modular soldier blockout. Replace meshes/materials with licensed rigged PBR assets before release.
func _ready() -> void:
    _build_soldier()
func _mat(color: Color, roughness := 0.82) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    return m
func _part(parent: Node3D, name: String, mesh: PrimitiveMesh, pos: Vector3, material: Material, rot := Vector3.ZERO) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = name
    n.mesh = mesh
    n.position = pos
    n.rotation_degrees = rot
    n.material_override = material
    parent.add_child(n)
    return n
func _build_soldier() -> void:
    var uniform := _mat(Color(0.19, 0.25, 0.17))
    var vest := _mat(Color(0.12, 0.14, 0.12))
    var boots := _mat(Color(0.055, 0.06, 0.05))
    var skin := _mat(Color(0.48, 0.31, 0.21))
    var helmet := _mat(Color(0.16, 0.21, 0.15))
    var head := SphereMesh.new()
    head.radius = 0.14
    head.height = 0.28
    _part(self, "Head", head, Vector3(0, 1.67, 0), skin)
    var helm := SphereMesh.new()
    helm.radius = 0.17
    helm.height = 0.2
    _part(self, "CombatHelmet", helm, Vector3(0, 1.79, 0), helmet)
    var torso := BoxMesh.new()
    torso.size = Vector3(0.48, 0.58, 0.27)
    _part(self, "Torso", torso, Vector3(0, 1.25, 0), uniform)
    var plate := BoxMesh.new()
    plate.size = Vector3(0.43, 0.42, 0.08)
    _part(self, "TacticalVest", plate, Vector3(0, 1.28, -0.17), vest)
    var pouch := BoxMesh.new()
    pouch.size = Vector3(0.12, 0.13, 0.09)
    for x in [-0.14, 0.0, 0.14]:
        _part(self, "MagazinePouch", pouch, Vector3(x, 1.18, -0.23), vest)
    var limb := CylinderMesh.new()
    limb.top_radius = 0.075
    limb.bottom_radius = 0.095
    limb.height = 0.64
    for side in [-1.0, 1.0]:
        _part(self, "UpperLeg", limb, Vector3(side * 0.13, 0.69, 0), uniform)
        var boot := BoxMesh.new()
        boot.size = Vector3(0.17, 0.13, 0.29)
        _part(self, "CombatBoot", boot, Vector3(side * 0.13, 0.12, -0.045), boots)
        var arm := CylinderMesh.new()
        arm.top_radius = 0.055
        arm.bottom_radius = 0.07
        arm.height = 0.56
        _part(self, "Arm", arm, Vector3(side * 0.31, 1.29, -0.02), uniform, Vector3(0, 0, side * -10.0))
    var rifle := Node3D.new()
    rifle.name = "Rifle"
    rifle.position = Vector3(0.34, 1.16, -0.28)
    add_child(rifle)
    var receiver := BoxMesh.new()
    receiver.size = Vector3(0.11, 0.12, 0.58)
    _part(rifle, "Receiver", receiver, Vector3(0, 0, -0.22), _mat(Color(0.045, 0.05, 0.045)))
    var barrel := CylinderMesh.new()
    barrel.top_radius = 0.018
    barrel.bottom_radius = 0.018
    barrel.height = 0.48
    _part(rifle, "Barrel", barrel, Vector3(0, 0.01, -0.7), _mat(Color(0.025, 0.03, 0.03)), Vector3(90, 0, 0))
    var stock := BoxMesh.new()
    stock.size = Vector3(0.08, 0.09, 0.24)
    _part(rifle, "Stock", stock, Vector3(0, 0, 0.16), vest)
