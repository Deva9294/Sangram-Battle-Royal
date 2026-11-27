extends Node3D
@export var arena_size := 180.0
var elapsed := 0.0
var zone_radius := 82.0
var zone_shrink_rate := 0.10
@onready var player: CharacterBody3D = $Player
@onready var status: Label = $HUD/Status
func _ready() -> void:
    player.add_to_group("player")
    _make_arena()
    var mobile := CanvasLayer.new()
    mobile.set_script(load("res://scripts/mobile_hud.gd"))
    add_child(mobile)
func _process(delta: float) -> void:
    elapsed += delta
    zone_radius = maxf(16.0, zone_radius - zone_shrink_rate * delta)
    if is_instance_valid(player):
        var outside := Vector2(player.global_position.x, player.global_position.z).length() > zone_radius
        if outside and int(elapsed * 2.0) % 2 == 0:
            player.health = maxi(0, player.health - 1)
        status.text = "SANGRAM | HP %d | AMMO %d | SAFE ZONE %.0fm" % [player.health, player.ammo, zone_radius]
        if player.health <= 0:
            status.text = "ELIMINATED | RESTART TRAINING"
func _make_arena() -> void:
    var ground_mesh := PlaneMesh.new()
    ground_mesh.size = Vector2(arena_size, arena_size)
    ground_mesh.subdivide_width = 32
    ground_mesh.subdivide_depth = 32
    $Ground/Mesh.mesh = ground_mesh
    var ground_mat := StandardMaterial3D.new()
    ground_mat.albedo_color = Color(0.24, 0.29, 0.18)
    ground_mat.roughness = 1.0
    var grass_color := "res://assets/environment/grass/color.jpg"
    var grass_normal := "res://assets/environment/grass/normal-gl.jpg"
    var grass_roughness := "res://assets/environment/grass/roughness.jpg"
    if ResourceLoader.exists(grass_color):
        ground_mat.albedo_texture = load(grass_color)
    if ResourceLoader.exists(grass_normal):
        ground_mat.normal_enabled = true
        ground_mat.normal_texture = load(grass_normal)
    if ResourceLoader.exists(grass_roughness):
        ground_mat.roughness_texture = load(grass_roughness)
    $Ground/Mesh.material_override = ground_mat
    var ground_collision := BoxShape3D.new()
    ground_collision.size = Vector3(arena_size, 0.3, arena_size)
    $Ground/Collision.shape = ground_collision
    _make_building(Vector3(-24, 0, -20), Vector3(12, 5, 10), Color(0.58, 0.48, 0.34))
    _make_building(Vector3(20, 0, -26), Vector3(10, 4, 9), Color(0.62, 0.55, 0.42))
    _make_building(Vector3(28, 0, 18), Vector3(14, 6, 12), Color(0.48, 0.43, 0.34))
    _make_building(Vector3(-30, 0, 25), Vector3(9, 4, 8), Color(0.65, 0.57, 0.43))
    for i in range(36):
        var rock := MeshInstance3D.new()
        var mesh := SphereMesh.new()
        mesh.radius = randf_range(0.35, 1.2)
        mesh.height = mesh.radius * 1.3
        rock.mesh = mesh
        rock.position = Vector3(randf_range(-78, 78), mesh.radius * 0.3, randf_range(-78, 78))
        var m := StandardMaterial3D.new()
        m.albedo_color = Color(0.28, 0.3, 0.22)
        rock.material_override = m
        $Decor.add_child(rock)
func _make_building(pos: Vector3, dims: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.position = pos
    $Decor.add_child(body)

    var building_paths := [
        "res://assets/environment/buildings/building-type-a.glb",
        "res://assets/environment/buildings/building-type-b.glb",
        "res://assets/environment/buildings/building-type-c.glb",
        "res://assets/environment/buildings/building-type-d.glb"
    ]
    var model_path: String = building_paths[mini(get_child_count(), building_paths.size() - 1)]
    if ResourceLoader.exists(model_path):
        var packed := load(model_path) as PackedScene
        if packed:
            var building := packed.instantiate() as Node3D
            if building:
                building.name = "KenneySuburbanBuilding"
                body.add_child(building)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = dims
    collision.shape = shape
    collision.position.y = dims.y * 0.5
    body.add_child(collision)

    if body.get_child_count() == 1:
        var mesh := MeshInstance3D.new()
        var box := BoxMesh.new()
        box.size = dims
        mesh.mesh = box
        mesh.position.y = dims.y * 0.5
        var mat := StandardMaterial3D.new()
        mat.albedo_color = color
        mat.roughness = 0.92
        mesh.material_override = mat
        body.add_child(mesh)
