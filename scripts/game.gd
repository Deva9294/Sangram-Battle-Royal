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
    _build_hud()
    match_started = true

func _process(delta):
    if game_over or not match_started: return
    elapsed += delta
    var shrink_elapsed = maxf(0.0, elapsed - ZONE_WAIT)
    safe_radius = maxf(ZONE_MIN_RADIUS, 95.0 - shrink_elapsed * ZONE_SHRINK_RATE)
    if safe_ring:
        safe_ring.scale = Vector3(safe_radius / 95.0, 1.0, safe_radius / 95.0)
    if player and is_instance_valid(player) and not player.eliminated:
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
    environment.ambient_light_energy = 0.8
    env.environment = environment
    add_child(env)
    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_energy = 1.35
    sun.shadow_enabled = true
    add_child(sun)

    _box(Vector3(0, -0.6, 0), Vector3(210, 1, 210), Color(0.27, 0.34, 0.16), true)
    _box(Vector3(0, -0.22, -38), Vector3(205, 0.12, 10), Color(0.42, 0.34, 0.22), false)
    _box(Vector3(-34, -0.18, 0), Vector3(9, 0.15, 205), Color(0.39, 0.32, 0.22), false)
    _box(Vector3(63, -0.25, 0), Vector3(13, 0.22, 205), Color(0.10, 0.34, 0.43), false)
    _box(Vector3(63, 0.05, 22), Vector3(19, 0.55, 8), Color(0.48, 0.43, 0.34), false)

    for plot in range(8):
        var px = -82.0 + float(plot % 4) * 36.0
        var pz = -78.0 + float(plot / 4) * 118.0
        _box(Vector3(px, -0.05, pz), Vector3(25, 0.08, 42), Color(0.38, 0.39, 0.13), false)
        for row in range(9):
            _box(Vector3(px - 10.0 + row * 2.5, 0.06, pz), Vector3(0.12, 0.12, 38), Color(0.53, 0.46, 0.18), false)

    for cluster in range(3):
        var cx = [-48.0, 8.0, 35.0][cluster]
        var cz = [-12.0, 42.0, -58.0][cluster]
        for i in range(8):
            var x = cx + randf_range(-18, 18)
            var z = cz + randf_range(-15, 15)
            var w = randf_range(5.5, 9.0)
            var d = randf_range(5.5, 8.5)
            var wall_color = [Color(0.67,0.52,0.35), Color(0.72,0.66,0.52), Color(0.53,0.46,0.35)][i % 3]
            _box(Vector3(x, 1.55, z), Vector3(w, 3.1, d), wall_color, true)
            _box(Vector3(x, 3.22, z), Vector3(w + 0.8, 0.45, d + 0.8), Color(0.25, 0.20, 0.17), false)
            _box(Vector3(x, 1.0, z + d * 0.51), Vector3(1.2, 2.0, 0.18), Color(0.20,0.13,0.08), false)

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
        var radius = randf_range(32, 82)
        var bot = CharacterBody3D.new()
        bot.set_script(BotScript)
        bot.position = Vector3(cos(angle) * radius, 1.0, sin(angle) * radius)
        bot.target = player
        bot.add_to_group("bots")
        add_child(bot)

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
