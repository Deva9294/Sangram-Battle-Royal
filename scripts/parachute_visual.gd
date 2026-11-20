extends Node3D

var canopy: MeshInstance3D
var elapsed := 0.0

func _ready() -> void:
    _build_canopy()

func _process(delta: float) -> void:
    elapsed += delta
    rotation.z = sin(elapsed * 0.8) * 0.035
    rotation.y = sin(elapsed * 0.35) * 0.08

func _build_canopy() -> void:
    canopy = MeshInstance3D.new()
    var dome := SphereMesh.new()
    dome.radius = 2.6
    dome.height = 1.65
    dome.radial_segments = 24
    dome.rings = 12
    canopy.mesh = dome
    canopy.position = Vector3(0, 5.1, 0)
    canopy.scale = Vector3(1.25, 0.48, 0.92)
    var fabric := StandardMaterial3D.new()
    fabric.albedo_color = Color(0.78, 0.16, 0.075)
    fabric.roughness = 0.78
    fabric.cull_mode = BaseMaterial3D.CULL_DISABLED
    canopy.material_override = fabric
    add_child(canopy)

    var harness := MeshInstance3D.new()
    var lines := ImmediateMesh.new()
    var rope_material := StandardMaterial3D.new()
    rope_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    rope_material.albedo_color = Color(0.92, 0.86, 0.68)
    lines.surface_begin(Mesh.PRIMITIVE_LINES, rope_material)
    for side in [-1.0, 1.0]:
        for front in [-1.0, 1.0]:
            lines.surface_add_vertex(Vector3(side * 2.25, 4.75, front * 1.55))
            lines.surface_add_vertex(Vector3(side * 0.30, 1.45, front * 0.18))
    lines.surface_end()
    harness.mesh = lines
    add_child(harness)
