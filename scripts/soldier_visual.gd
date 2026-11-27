extends Node3D
## Loads the licensed rigged character when installed; procedural blockout is fallback only.
const RIGGED_MODEL := "res://assets/characters/soldier/soldier.glb"
var animation_player: AnimationPlayer

func _ready() -> void:
    if ResourceLoader.exists(RIGGED_MODEL):
        var packed := load(RIGGED_MODEL) as PackedScene
        if packed:
            var model := packed.instantiate()
            model.name = "RiggedSoldier"
            add_child(model)
            animation_player = _find_animation_player(model)
            _play_first(["Idle", "idle", "Breathing Idle", "Idle_01"])
            return
    _build_blockout()

func play_locomotion(moving: bool, sprinting: bool = false) -> void:
    if animation_player == null:
        return
    var choices: Array[String] = []
    if sprinting:
        choices = ["Sprint", "sprint", "Run", "run"]
    elif moving:
        choices = ["Walk", "walk", "Run", "run"]
    else:
        choices = ["Idle", "idle", "Breathing Idle"]
    _play_first(choices)

func _find_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node
    for child in node.get_children():
        var found := _find_animation_player(child)
        if found:
            return found
    return null

func _play_first(names: Array[String]) -> void:
    if animation_player == null:
        return
    for clip in names:
        if animation_player.has_animation(clip):
            if animation_player.current_animation != clip:
                animation_player.play(clip)
            return

func _mat(color: Color, roughness := 0.82) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    return m

func _part(parent: Node3D, part_name: String, mesh: PrimitiveMesh, pos: Vector3, material: Material, rot := Vector3.ZERO) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = part_name
    n.mesh = mesh
    n.position = pos
    n.rotation_degrees = rot
    n.material_override = material
    parent.add_child(n)
    return n

func _build_blockout() -> void:
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
    for side in [-1.0, 1.0]:
        var leg := CylinderMesh.new()
        leg.top_radius = 0.075
        leg.bottom_radius = 0.095
        leg.height = 0.64
        _part(self, "Leg", leg, Vector3(side * 0.13, 0.69, 0), uniform)
        var boot := BoxMesh.new()
        boot.size = Vector3(0.17, 0.13, 0.29)
        _part(self, "CombatBoot", boot, Vector3(side * 0.13, 0.12, -0.045), boots)
        var arm := CylinderMesh.new()
        arm.top_radius = 0.055
        arm.bottom_radius = 0.07
        arm.height = 0.56
        _part(self, "Arm", arm, Vector3(side * 0.31, 1.29, -0.02), uniform)
    var rifle := Node3D.new()
    rifle.name = "RifleBlockout"
    rifle.position = Vector3(0.34, 1.16, -0.28)
    add_child(rifle)
    var receiver := BoxMesh.new()
    receiver.size = Vector3(0.11, 0.12, 0.58)
    _part(rifle, "Receiver", receiver, Vector3(0, 0, -0.22), _mat(Color(0.045, 0.05, 0.045)))
