extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const BotScript = preload("res://scripts/bot.gd")
const LootScript = preload("res://scripts/loot_pickup.gd")
var player
var hud
var bot_count := 8
var elapsed := 0.0
var battle_start_grace := 12.0
var safe_radius := 95.0
var game_over := false
var safe_ring: MeshInstance3D
var kills := 0
var match_started := false
const ZONE_WAIT := 20.0
const ZONE_SHRINK_RATE := 0.42
const ZONE_MIN_RADIUS := 14.0

func _ready():
    randomize()
    add_to_group("game_manager")
    _build_world()
    _spawn_player()
    _spawn_bots()
    _spawn_loot()
    _build_hud()
    match_started = true

func _process(delta):
    if game_over or not match_started: return
    elapsed += delta
    battle_start_grace = maxf(0.0, battle_start_grace - delta)
    var shrink_elapsed = maxf(0.0, elapsed - ZONE_WAIT)
    safe_radius = maxf(ZONE_MIN_RADIUS, 95.0 - shrink_elapsed * ZONE_SHRINK_RATE)
    if safe_ring:
        safe_ring.scale = Vector3(safe_radius / 95.0, 1.0, safe_radius / 95.0)
    if player and is_instance_valid(player) and not player.eliminated and battle_start_grace <= 0.0:
        var player_distance = Vector2(player.global_position.x, player.global_position.z).length()
        if player_distance > safe_radius:
            player.take_damage(5.5 * delta)
    for enemy in get_tree().get_nodes_in_group("bots"):
        if not is_instance_valid(enemy) or not enemy.alive: continue
        var enemy_distance = Vector2(enemy.global_position.x, enemy.global_position.z).length()
        if enemy_distance > safe_radius:
            enemy.take_damage(4.0 * delta, self)
    var remaining = get_tree().get_nodes_in_group("bots").size()
    var zone_countdown = maxf(0.0, ZONE_WAIT - elapsed)
    if hud: hud.update_stats(player, remaining, safe_radius, elapsed, kills, zone_countdown)
    if remaining == 0 and not game_over:
        game_over = true
        if hud: hud.show_result(true, kills)

func _build_world():
    var env = WorldEnvironment.new()
    var environment = Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.62, 0.72, 0.82)
    environment.ambient_light_energy = 0.85
    var sky_material := ProceduralSkyMaterial.new()
    sky_material.sky_top_color = Color(0.12, 0.25, 0.39)
    sky_material.sky_horizon_color = Color(0.72, 0.66, 0.51)
    sky_material.ground_bottom_color = Color(0.12, 0.14, 0.10)
    sky_material.ground_horizon_color = Color(0.42, 0.40, 0.30)
    environment.sky.sky_material = sky_material
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.fog_enabled = true
    environment.fog_light_color = Color(0.66, 0.68, 0.60)
    environment.fog_density = 0.0018
    env.environment = environment
    add_child(env)
    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_energy = 1.35
    sun.shadow_enabled = true
    add_child(sun)

    _build_textured_terrain()
    _box(Vector3(0, -0.22, -38), Vector3(205, 0.12, 12), Color(0.20, 0.22, 0.21), false)
    _box(Vector3(-34, -0.18, 0), Vector3(11, 0.15, 205), Color(0.20, 0.22, 0.21), false)
    _box(Vector3(63, -0.25, 0), Vector3(13, 0.22, 205), Color(0.10, 0.34, 0.43), false)
    _box(Vector3(63, 0.05, 22), Vector3(19, 0.55, 8), Color(0.48, 0.43, 0.34), false)

    for plot in range(8):
        var px = -82.0 + float(plot % 4) * 36.0
        var pz = -78.0 + float(plot / 4) * 118.0
        _box(Vector3(px, -0.05, pz), Vector3(25, 0.08, 42), Color(0.38, 0.39, 0.13), false)
        for row in range(9):
            _box(Vector3(px - 10.0 + row * 2.5, 0.06, pz), Vector3(0.12, 0.12, 38), Color(0.53, 0.46, 0.18), false)

    # Main road markings and cross-country tracks
    for mark in range(18):
        _box(Vector3(-94.0 + mark * 11.0, -0.12, -38.0), Vector3(4.5, 0.025, 0.22), Color(0.78, 0.72, 0.52), false)
        _box(Vector3(-34.0, -0.10, -94.0 + mark * 11.0), Vector3(0.22, 0.025, 4.5), Color(0.78, 0.72, 0.52), false)
    _build_battle_landmarks()
    _build_environment_details()

    _spawn_asset_buildings()

    for i in range(90):
        var x = randf_range(-98, 98)
        var z = randf_range(-98, 98)
        if Vector2(x, z).length() < 12 or absf(x - 63.0) < 9: continue
        _tree(Vector3(x, 0, z))

    safe_ring = MeshInstance3D.new()
    var ring = TorusMesh.new()
    ring.inner_radius = 94.5
    ring.outer_radius = 95.0
    ring.rings = 8
    ring.ring_segments = 96
    safe_ring.mesh = ring
    safe_ring.position.y = 0.08
    var ring_mat = StandardMaterial3D.new()
    ring_mat.albedo_color = Color(0.1, 0.85, 1.0, 0.8)
    ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    ring_mat.emission_enabled = true
    ring_mat.emission = Color(0.04, 0.42, 0.7)
    safe_ring.material_override = ring_mat
    add_child(safe_ring)

func _build_battle_landmarks() -> void:
    # Distinct combat locations so the arena reads like a small battleground.

    # Industrial cover: shipping containers, crates and sandbag lines.
    for i in range(4):
        var container_color: Color = [Color(0.48, 0.16, 0.12), Color(0.13, 0.29, 0.34), Color(0.39, 0.40, 0.31), Color(0.56, 0.42, 0.20)][i]
        _box(Vector3(-60 + i * 12, 1.25, 45), Vector3(10.5, 2.5, 3.2), container_color, true)
        _box(Vector3(-60 + i * 12, 1.25, 48.4), Vector3(10.5, 2.5, 0.12), Color(0.10, 0.12, 0.12), false)
    for i in range(8):
        _box(Vector3(73 + i * 1.35, 0.45, -48), Vector3(1.3, 0.9, 0.75), Color(0.62, 0.54, 0.39), true)
        _box(Vector3(-88 + i * 1.35, 0.42, -56), Vector3(1.25, 0.84, 0.7), Color(0.58, 0.49, 0.35), true)

    # A visible elevated lookout tower with climbable-looking silhouette.
    for side in [-1.0, 1.0]:
        for depth in [-1.0, 1.0]:
            _box(Vector3(42 + side * 2.8, 3.0, 54 + depth * 2.8), Vector3(0.32, 6.0, 0.32), Color(0.27, 0.23, 0.18), true)
    _box(Vector3(42, 6.1, 54), Vector3(7.2, 0.45, 7.2), Color(0.34, 0.29, 0.22), true)
    _box(Vector3(42, 8.3, 54), Vector3(8.0, 0.35, 8.0), Color(0.22, 0.19, 0.16), true)
    _box(Vector3(42, 7.0, 54), Vector3(6.8, 1.35, 0.18), Color(0.16, 0.18, 0.15), true)

func _build_environment_details() -> void:
    # Lightweight procedural scrub, boulders and roadside fence dressing.
    for i in range(54):
        var x := randf_range(-98.0, 98.0)
        var z := randf_range(-98.0, 98.0)
        if Vector2(x, z).length() < 18.0 or absf(x - 63.0) < 10.0:
            continue
        var shrub := MeshInstance3D.new()
        var shrub_mesh := SphereMesh.new()
        shrub_mesh.radius = randf_range(0.35, 0.75)
        shrub_mesh.height = randf_range(0.55, 1.15)
        shrub.mesh = shrub_mesh
        shrub.position = Vector3(x, shrub_mesh.height * 0.42, z)
        shrub.scale = Vector3(1.25, 0.72, 1.0)
        var shrub_mat := StandardMaterial3D.new()
        shrub_mat.albedo_color = [Color(0.16, 0.25, 0.10), Color(0.24, 0.29, 0.12), Color(0.31, 0.30, 0.15)][i % 3]
        shrub_mat.roughness = 1.0
        shrub.material_override = shrub_mat
        add_child(shrub)

    for i in range(24):
        var x := randf_range(-92.0, 92.0)
        var z := randf_range(-92.0, 92.0)
        if Vector2(x, z).length() < 22.0:
            continue
        var rock := MeshInstance3D.new()
        var rock_mesh := SphereMesh.new()
        rock_mesh.radius = randf_range(0.35, 1.0)
        rock_mesh.height = randf_range(0.45, 1.1)
        rock.mesh = rock_mesh
        rock.position = Vector3(x, rock_mesh.height * 0.30, z)
        rock.rotation = Vector3(randf_range(-0.3, 0.3), randf_range(0.0, TAU), randf_range(-0.2, 0.2))
        rock.scale = Vector3(1.4, 0.75, 1.0)
        var rock_mat := StandardMaterial3D.new()
        rock_mat.albedo_color = Color(0.34, 0.32, 0.27)
        rock_mat.roughness = 1.0
        rock.material_override = rock_mat
        add_child(rock)

    for i in range(18):
        var x := -92.0 + float(i) * 10.5
        _box(Vector3(x, 0.62, -31.0), Vector3(0.16, 1.24, 0.16), Color(0.35, 0.27, 0.17), true)

func _box(pos: Vector3, size: Vector3, color: Color, solid: bool):
    var root = StaticBody3D.new() if solid else Node3D.new()
    root.position = pos
    var mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.92
    mesh.material_override = mat
    root.add_child(mesh)
    if solid:
        var collision = CollisionShape3D.new()
        var shape = BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        root.add_child(collision)
    add_child(root)

func _build_textured_terrain() -> void:
    var ground := StaticBody3D.new()
    ground.position = Vector3(0.0, -0.6, 0.0)
    var mesh := MeshInstance3D.new()
    var slab := BoxMesh.new()
    slab.size = Vector3(210.0, 1.0, 210.0)
    mesh.mesh = slab
    var material := StandardMaterial3D.new()
    var color_path := "res://assets/environment/textures/ground037/Ground037_Color.jpg"
    var normal_path := "res://assets/environment/textures/ground037/Ground037_NormalGL.jpg"
    var rough_path := "res://assets/environment/textures/ground037/Ground037_Roughness.jpg"
    if ResourceLoader.exists(color_path):
        material.albedo_texture = load(color_path)
    if ResourceLoader.exists(normal_path):
        material.normal_texture = load(normal_path)
        material.normal_enabled = true
    if ResourceLoader.exists(rough_path):
        material.roughness_texture = load(rough_path)
    material.roughness = 1.0
    material.uv1_scale = Vector3(34.0, 34.0, 1.0)
    mesh.material_override = material
    ground.add_child(mesh)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = slab.size
    collision.shape = shape
    ground.add_child(collision)
    add_child(ground)

func _spawn_asset_buildings() -> void:
    var positions := [
        Vector3(-76, 0, 28), Vector3(18, 0, 72), Vector3(78, 0, -68),
        Vector3(-78, 0, -70), Vector3(-48, 0, -12), Vector3(8, 0, 42),
        Vector3(35, 0, -58), Vector3(54, 0, 12), Vector3(-18, 0, 68),
        Vector3(-58, 0, 76), Vector3(76, 0, 42), Vector3(4, 0, -82)
    ]
    var models := [
        "res://assets/environment/buildings/building-type-a.glb",
        "res://assets/environment/buildings/building-type-b.glb",
        "res://assets/environment/buildings/building-type-d.glb",
        "res://assets/environment/buildings/building-type-h.glb"
    ]
    for i in range(positions.size()):
        var model_path: String = models[i % models.size()]
        if not ResourceLoader.exists(model_path):
            _box(positions[i] + Vector3(0, 1.8, 0), Vector3(10, 3.6, 9), Color(0.52, 0.48, 0.39), true)
            continue
        var packed := load(model_path) as PackedScene
        if packed == null:
            continue
        var root := StaticBody3D.new()
        root.position = positions[i]
        root.rotation.y = randf_range(0.0, TAU)
        var model := packed.instantiate() as Node3D
        if model == null:
            root.queue_free()
            continue
        model.scale = Vector3(1.7, 1.7, 1.7)
        root.add_child(model)
        var collision := CollisionShape3D.new()
        var collision_shape := BoxShape3D.new()
        collision_shape.size = Vector3(13.0, 5.5, 12.0)
        collision.position.y = 2.75
        collision.shape = collision_shape
        root.add_child(collision)
        add_child(root)

func _tree(pos: Vector3):
    var tree_path := "res://assets/environment/buildings/tree-large.glb" if randf() > 0.35 else "res://assets/environment/buildings/tree-small.glb"
    if ResourceLoader.exists(tree_path):
        var packed := load(tree_path) as PackedScene
        if packed:
            var tree_root := StaticBody3D.new()
            tree_root.position = pos
            tree_root.rotation.y = randf_range(0.0, TAU)
            var tree_model := packed.instantiate() as Node3D
            tree_model.scale = Vector3.ONE * randf_range(1.25, 2.0)
            tree_root.add_child(tree_model)
            var trunk := CollisionShape3D.new()
            var trunk_shape := CylinderShape3D.new()
            trunk_shape.radius = 0.45
            trunk_shape.height = 3.2
            trunk.position.y = 1.6
            trunk.shape = trunk_shape
            tree_root.add_child(trunk)
            add_child(tree_root)
            return
    _box(pos + Vector3(0, 1.3, 0), Vector3(0.45, 2.6, 0.45), Color(0.28, 0.16, 0.08), true)
    var crown := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 1.8
    sphere.height = 3.4
    crown.mesh = sphere
    crown.position = pos + Vector3(0, 3.2, 0)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.12, 0.34, 0.13)
    crown.material_override = mat
    add_child(crown)

func _spawn_player():
    player = CharacterBody3D.new()
    player.set_script(PlayerScript)
    player.position = Vector3(-12.0, 32.0, 8.0)
    player.parachuting = true
    add_child(player)
    var canopy_script = load("res://scripts/parachute_visual.gd")
    if canopy_script:
        player.parachute_visual = Node3D.new()
        player.parachute_visual.set_script(canopy_script)
        player.add_child(player.parachute_visual)

func _spawn_bots():
    for i in range(bot_count):
        var angle = TAU * float(i) / bot_count
        var radius = randf_range(32, 82)
        var bot = CharacterBody3D.new()
        bot.set_script(BotScript)
        bot.position = Vector3(cos(angle) * radius, 1.0, sin(angle) * radius)
        bot.target = player
        bot.add_to_group("bots")
        add_child(bot)

func _spawn_loot() -> void:
    for i in range(30):
        var pickup := Area3D.new()
        pickup.set_script(LootScript)
        var roll := i % 3
        if roll == 0:
            pickup.set("loot_type", "ammo")
            pickup.set("amount", 45)
        elif roll == 1:
            pickup.set("loot_type", "medkit")
            pickup.set("amount", 1)
        else:
            pickup.set("loot_type", "armor")
            pickup.set("amount", 30)
        var x := randf_range(-86.0, 86.0)
        var z := randf_range(-86.0, 86.0)
        if Vector2(x, z).length() < 16.0:
            x += 24.0
        pickup.position = Vector3(x, 0.0, z)
        add_child(pickup)

func _build_hud():
    var layer = CanvasLayer.new()
    add_child(layer)
    hud = Control.new()
    hud.set_script(load("res://scripts/hud.gd"))
    layer.add_child(hud)
    hud.player = player
    player.hud = hud

func bot_eliminated(attacker = null):
    if attacker == player:
        kills += 1
        if hud: hud.show_message("ENEMY ELIMINATED  +1")

func player_eliminated():
    game_over = true
    for enemy in get_tree().get_nodes_in_group("bots"):
        if is_instance_valid(enemy):
            enemy.set_physics_process(false)
