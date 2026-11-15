extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const BotScript = preload("res://scripts/bot.gd")
var player
var hud
var bot_count := 24
var elapsed := 0.0
var safe_radius := 95.0
var game_over := false
var safe_ring: MeshInstance3D

func _ready():
    add_to_group("game_manager")
    _build_world()
    _spawn_player()
    _spawn_bots()
    _build_hud()

func _process(delta):
    if game_over: return
    elapsed += delta
    safe_radius = maxf(14.0, 95.0 - elapsed * 0.23)
    if safe_ring:
        safe_ring.scale = Vector3(safe_radius / 95.0, 1, safe_radius / 95.0)
    if player and is_instance_valid(player):
        if Vector2(player.global_position.x, player.global_position.z).length() > safe_radius:
            player.take_damage(5.0 * delta)
        if player.eliminated:
            game_over = true
            return
    var remaining = get_tree().get_nodes_in_group("bots").size()
    if hud: hud.update_stats(player, remaining, safe_radius, elapsed)
    if remaining == 0 and not game_over:
        game_over = true
        hud.show_result(true)

func _build_world():
    var env = WorldEnvironment.new()
    var environment = Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.62, 0.72, 0.82)
    environment.ambient_light_energy = 0.8
    env.environment = environment
    add_child(env)
    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.2
    add_child(sun)
    _box(Vector3(0, -0.6, 0), Vector3(210, 1, 210), Color(0.22, 0.38, 0.19), true)
    # Indian village-style compounds, sheds and cover
    for i in range(22):
        var x = randf_range(-78, 78)
        var z = randf_range(-78, 78)
        if Vector2(x, z).length() < 13: continue
        var w = randf_range(5, 10)
        var d = randf_range(5, 9)
        _box(Vector3(x, 1.5, z), Vector3(w, 3, d), [Color(0.68,0.49,0.31), Color(0.72,0.66,0.48), Color(0.48,0.42,0.32)][i % 3], true)
        _box(Vector3(x, 3.25, z), Vector3(w + 0.8, 0.5, d + 0.8), Color(0.35, 0.18, 0.12), false)
    for i in range(55):
        var x = randf_range(-92, 92)
        var z = randf_range(-92, 92)
        if Vector2(x, z).length() < 10: continue
        _tree(Vector3(x, 0, z))
    safe_ring = MeshInstance3D.new()
    var ring = TorusMesh.new()
    ring.inner_radius = 0.18
    ring.outer_radius = 0.28
    ring.rings = 8
    ring.ring_segments = 96
    safe_ring.mesh = ring
    safe_ring.position.y = 0.08
    safe_ring.scale = Vector3(safe_radius / 95.0, 1, safe_radius / 95.0)
    var ring_mat = StandardMaterial3D.new()
    ring_mat.albedo_color = Color(0.1, 0.85, 1.0, 0.8)
    ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    safe_ring.material_override = ring_mat
    add_child(safe_ring)

func _box(pos: Vector3, size: Vector3, color: Color, solid: bool):
    var root = StaticBody3D.new() if solid else Node3D.new()
    root.position = pos
    var mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    mesh.material_override = mat
    root.add_child(mesh)
    if solid:
        var collision = CollisionShape3D.new()
        var shape = BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        root.add_child(collision)
    add_child(root)

func _tree(pos: Vector3):
    _box(pos + Vector3(0, 1.3, 0), Vector3(0.45, 2.6, 0.45), Color(0.28, 0.16, 0.08), true)
    var crown = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 1.8
    sphere.height = 3.4
    crown.mesh = sphere
    crown.position = pos + Vector3(0, 3.2, 0)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.12, 0.34, 0.13)
    crown.material_override = mat
    add_child(crown)

func _spawn_player():
    player = CharacterBody3D.new()
    player.set_script(PlayerScript)
    player.position = Vector3(0, 1.2, 0)
    add_child(player)

func _spawn_bots():
    for i in range(bot_count):
        var angle = TAU * float(i) / bot_count
        var radius = randf_range(24, 78)
        var bot = CharacterBody3D.new()
        bot.set_script(BotScript)
        bot.position = Vector3(cos(angle) * radius, 1.0, sin(angle) * radius)
        bot.target = player
        bot.add_to_group("bots")
        add_child(bot)

func _build_hud():
    var layer = CanvasLayer.new()
    add_child(layer)
    var script = load("res://scripts/hud.gd")
    hud = Control.new()
    hud.set_script(script)
    layer.add_child(hud)
    hud.player = player
    player.hud = hud

func bot_eliminated():
    pass
