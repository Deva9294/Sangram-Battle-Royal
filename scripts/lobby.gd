extends Node3D

# SANGRAM Android ARM64 debug build validation.

var selected_operator := 0
var preview_root: Node3D
var operator_names := ["VEER", "TARA", "RUDRA"]
var operator_roles := ["ASSAULT • MALWA FRONTIER", "RECON • CENTRAL INDIA", "SUPPORT • NARMADA UNIT"]
var operator_colors := [Color(0.24,0.31,0.22), Color(0.20,0.30,0.38), Color(0.38,0.27,0.18)]
var info_label: Label
var idle_time := 0.0
var matchmaking_active := false
var matchmaking_remaining := 12.0
var matchmaking_label: Label
var matchmaking_panel: PanelContainer
var matchmaking_layer: CanvasLayer
var network_address: LineEdit
var network_status: Label

func _ready():
    _build_lobby_world()
    _build_interface()
    _show_operator()

func _process(delta):
    idle_time += delta
    if preview_root and is_instance_valid(preview_root):
        preview_root.rotation.y = sin(idle_time * 0.32) * 0.12
        preview_root.position.y = sin(idle_time * 1.2) * 0.025
    if matchmaking_active:
        matchmaking_remaining = maxf(0.0, matchmaking_remaining - delta)
        if matchmaking_label:
            matchmaking_label.text = "SEARCHING FOR OPERATORS  •  OFFLINE BOT FILL\\nESTIMATED WAIT: 00:%02d\\nMATCH STARTING..." % int(ceil(matchmaking_remaining))
        if matchmaking_remaining <= 0.0:
            matchmaking_active = false
            get_tree().change_scene_to_file("res://scenes/game.tscn")

func _build_lobby_world():
    var env_node = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.42,0.50,0.62)
    env.ambient_light_energy = 0.65
    env_node.environment = env
    add_child(env_node)
    var key = DirectionalLight3D.new()
    key.rotation_degrees = Vector3(-25,-35,0)
    key.light_energy = 1.7
    key.shadow_enabled = true
    add_child(key)
    _add_box(Vector3(0,-0.25,0), Vector3(30,0.5,24), Color(0.075,0.09,0.10))
    _add_box(Vector3(0,6,-8), Vector3(30,12,0.6), Color(0.09,0.12,0.13))
    for x in [-13.0,13.0]:
        _add_box(Vector3(x,5,0), Vector3(0.6,10,20), Color(0.12,0.15,0.16))
        _add_box(Vector3(x,0.2,0), Vector3(1.0,0.4,20), Color(0.65,0.37,0.10))
    for i in range(7):
        _add_box(Vector3(-12.0 + i*4.0,10,-7.4), Vector3(0.16,0.16,0.16), Color(0.95,0.58,0.20))
    _add_box(Vector3(0,0.02,-2), Vector3(8,0.06,10), Color(0.16,0.19,0.19))
    var camera = Camera3D.new()
    camera.position = Vector3(0,2.7,8.5)
    camera.fov = 42
    add_child(camera)
    camera.look_at(Vector3(0,1.45,0), Vector3.UP)
    camera.current = true

func _add_box(pos: Vector3, size: Vector3, color: Color):
    var mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.position = pos
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = 0.22
    mat.roughness = 0.72
    mesh.material_override = mat
    add_child(mesh)

func _build_interface():
    var layer = CanvasLayer.new()
    add_child(layer)
    var shade = ColorRect.new()
    shade.color = Color(0.015,0.025,0.035,0.42)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.add_child(shade)
    var top = Label.new()
    top.text = "D E V A C O R E   S T U D I O     •     PRESENTS"
    top.position = Vector2(34,22)
    top.add_theme_font_size_override("font_size",15)
    top.add_theme_color_override("font_color",Color(0.92,0.72,0.42))
    layer.add_child(top)
    var logo = Label.new()
    logo.text = "SANGRAM"
    logo.position = Vector2(30,50)
    logo.add_theme_font_size_override("font_size",52)
    logo.add_theme_color_override("font_color",Color(1,1,1))
    logo.add_theme_color_override("font_shadow_color",Color(0,0,0,0.8))
    logo.add_theme_constant_override("shadow_offset_x",3)
    logo.add_theme_constant_override("shadow_offset_y",3)
    layer.add_child(logo)
    var subtitle = Label.new()
    subtitle.text = "BATTLE ROYALE  /  MADHYA PRADESH"
    subtitle.position = Vector2(36,112)
    subtitle.add_theme_font_size_override("font_size",15)
    subtitle.add_theme_color_override("font_color",Color(0.85,0.88,0.88))
    layer.add_child(subtitle)
    var panel = PanelContainer.new()
    panel.position = Vector2(28,180)
    panel.size = Vector2(360,560)
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.025,0.045,0.055,0.88)
    panel_style.border_color = Color(0.78,0.48,0.18,0.85)
    panel_style.set_border_width_all(1)
    panel_style.set_corner_radius_all(8)
    panel.add_theme_stylebox_override("panel",panel_style)
    layer.add_child(panel)
    var layout = VBoxContainer.new()
    layout.add_theme_constant_override("separation",12)
    layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.add_child(layout)
    var heading = Label.new()
    heading.text = "DEPLOYMENT LOBBY"
    heading.add_theme_font_size_override("font_size",21)
    heading.add_theme_color_override("font_color",Color(0.96,0.72,0.35))
    layout.add_child(heading)
    info_label = Label.new()
    info_label.custom_minimum_size = Vector2(0,62)
    info_label.add_theme_font_size_override("font_size",17)
    info_label.add_theme_color_override("font_color",Color.WHITE)
    layout.add_child(info_label)
    var choose = Label.new()
    choose.text = "SELECT YOUR OPERATOR"
    choose.add_theme_font_size_override("font_size",13)
    choose.add_theme_color_override("font_color",Color(0.65,0.75,0.78))
    layout.add_child(choose)
    for i in range(operator_names.size()):
        var b = Button.new()
        b.text = "%02d   %s" % [i+1,operator_names[i]]
        b.custom_minimum_size = Vector2(0,44)
        b.pressed.connect(_select_operator.bind(i))
        layout.add_child(b)
    var map_label = Label.new()
    map_label.text = "MAP  •  MALWA FRONTIER, MADHYA PRADESH\nMODE  •  OFFLINE SURVIVAL  •  24 ENEMIES"
    map_label.add_theme_font_size_override("font_size",13)
    map_label.add_theme_color_override("font_color",Color(0.78,0.84,0.83))
    layout.add_child(map_label)
    var deploy = Button.new()
    deploy.text = "▶   DEPLOY"
    deploy.custom_minimum_size = Vector2(0,58)
    deploy.add_theme_font_size_override("font_size",22)
    var deploy_style = StyleBoxFlat.new()
    deploy_style.bg_color = Color(0.72,0.30,0.08)
    deploy_style.set_corner_radius_all(5)
    deploy.add_theme_stylebox_override("normal",deploy_style)
    deploy.text = "▶   OFFLINE BOT BATTLE"
    deploy.pressed.connect(_deploy)
    layout.add_child(deploy)

    var online_heading := Label.new()
    online_heading.text = "ONLINE MULTIPLAYER • ENET HOST / JOIN"
    online_heading.add_theme_font_size_override("font_size", 13)
    online_heading.add_theme_color_override("font_color", Color(0.65,0.75,0.78))
    layout.add_child(online_heading)

    network_address = LineEdit.new()
    network_address.placeholder_text = "Host IP address (e.g. 192.168.1.10)"
    network_address.custom_minimum_size = Vector2(0, 40)
    layout.add_child(network_address)

    var online_row := HBoxContainer.new()
    var host_button := Button.new()
    host_button.text = "HOST MATCH"
    host_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    host_button.custom_minimum_size.y = 44
    host_button.pressed.connect(_host_online)
    online_row.add_child(host_button)
    var join_button := Button.new()
    join_button.text = "JOIN MATCH"
    join_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    join_button.custom_minimum_size.y = 44
    join_button.pressed.connect(_join_online)
    online_row.add_child(join_button)
    layout.add_child(online_row)

    network_status = Label.new()
    network_status.text = "Offline mode ready • Online requires reachable host"
    network_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    network_status.add_theme_font_size_override("font_size", 12)
    network_status.add_theme_color_override("font_color", Color(0.78,0.84,0.83))
    layout.add_child(network_status)
    NetworkSession.session_changed.connect(_on_network_status)

    var foot = Label.new()
    foot.text = "CHARACTER / TRAINING LOBBY  •  BUILD 0.2"
    foot.position = Vector2(32, get_viewport().get_visible_rect().size.y - 32)
    foot.add_theme_font_size_override("font_size",11)
    foot.add_theme_color_override("font_color",Color(0.72,0.76,0.76))
    layer.add_child(foot)

func _select_operator(index: int):
    selected_operator = index
    _show_operator()

func _show_operator():
    if preview_root and is_instance_valid(preview_root):
        preview_root.queue_free()
    preview_root = Node3D.new()
    preview_root.position = Vector3(1.9,0,0)
    add_child(preview_root)
    var model_paths := [
        "res://assets/characters/Rifleman.glb",
        "res://assets/characters/ReconScout.glb",
        "res://assets/characters/ArmySniper.glb"
    ]
    var model_path: String = model_paths[selected_operator]
    if ResourceLoader.exists(model_path):
        var model_scene := load(model_path) as PackedScene
        if model_scene:
            var model := model_scene.instantiate()
            preview_root.add_child(model)
            var animation := _find_animation_player(model)
            if animation and animation.has_animation("Idle"):
                animation.play("Idle")
            if info_label:
                info_label.text = "%s\n%s" % [operator_names[selected_operator], operator_roles[selected_operator]]
            return
    var suit = operator_colors[selected_operator]
    _part(Vector3(0,1.05,0),Vector3(0.75,0.9,0.42),suit)
    _part(Vector3(0,1.78,0),Vector3(0.44,0.48,0.42),Color(0.72,0.52,0.37),true)
    _part(Vector3(0,2.08,0),Vector3(0.56,0.28,0.52),Color(0.13,0.16,0.15))
    _part(Vector3(0,1.12,-0.26),Vector3(0.82,0.66,0.18),Color(0.12,0.15,0.14))
    _part(Vector3(-0.48,1.12,0),Vector3(0.22,0.72,0.24),suit)
    _part(Vector3(0.48,1.12,0),Vector3(0.22,0.72,0.24),suit)
    _part(Vector3(-0.2,0.42,0),Vector3(0.27,0.82,0.3),Color(0.16,0.19,0.17))
    _part(Vector3(0.2,0.42,0),Vector3(0.27,0.82,0.3),Color(0.16,0.19,0.17))
    _part(Vector3(-0.2,0.06,0.08),Vector3(0.34,0.18,0.48),Color(0.07,0.08,0.08))
    _part(Vector3(0.2,0.06,0.08),Vector3(0.34,0.18,0.48),Color(0.07,0.08,0.08))
    _part(Vector3(0,1.12,-0.38),Vector3(0.24,0.42,0.16),Color(0.22,0.24,0.21))
    _part(Vector3(0.35,1.36,-0.03),Vector3(0.12,0.52,0.12),Color(0.12,0.13,0.12))
    # Distinct rifle silhouette, chest rig, radio and utility pouches.
    _part(Vector3(0.38,1.02,-0.53),Vector3(0.12,0.92,0.12),Color(0.055,0.065,0.06))
    _part(Vector3(0.38,1.48,-0.53),Vector3(0.16,0.18,0.16),Color(0.09,0.10,0.09))
    _part(Vector3(-0.22,1.12,-0.39),Vector3(0.18,0.20,0.12),Color(0.55,0.39,0.17))
    _part(Vector3(0.0,1.12,-0.40),Vector3(0.18,0.20,0.12),Color(0.55,0.39,0.17))
    _part(Vector3(-0.34,1.40,0.08),Vector3(0.18,0.26,0.18),Color(0.12,0.14,0.13))
    if info_label:
        info_label.text = "%s\n%s" % [operator_names[selected_operator],operator_roles[selected_operator]]

func _find_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var found := _find_animation_player(child)
        if found:
            return found
    return null

func _part(pos: Vector3, size: Vector3, color: Color, sphere := false):
    var mesh = MeshInstance3D.new()
    if sphere:
        var s = SphereMesh.new()
        s.radius = 0.25
        s.height = 0.5
        mesh.mesh = s
    else:
        var box = BoxMesh.new()
        box.size = size
        mesh.mesh = box
    mesh.position = pos
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.82
    mesh.material_override = mat
    preview_root.add_child(mesh)

func _host_online() -> void:
    var result: Error = NetworkSession.host_game()
    _on_network_status(NetworkSession.mode, NetworkSession.status)
    if result == OK:
        network_status.text += "\\nShare your public IP and open UDP port 2456 to let players join."

func _join_online() -> void:
    var address := network_address.text.strip_edges()
    var result: Error = NetworkSession.join_game(address)
    _on_network_status(NetworkSession.mode, NetworkSession.status)
    if result == OK:
        network_status.text += "\\nTransport connected when host accepts; gameplay sync is a separate milestone."

func _on_network_status(mode: String, message: String) -> void:
    if network_status and is_instance_valid(network_status):
        network_status.text = ("ONLINE • " if mode == "online" else "OFFLINE • ") + message

func _deploy():
    if matchmaking_active:
        return
    matchmaking_active = true
    matchmaking_remaining = 12.0
    matchmaking_layer = CanvasLayer.new()
    matchmaking_layer.layer = 50
    get_tree().current_scene.add_child(matchmaking_layer)
    matchmaking_panel = PanelContainer.new()
    matchmaking_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    matchmaking_panel.position = Vector2(-230, -105)
    matchmaking_panel.size = Vector2(460, 210)
    matchmaking_panel.z_index = 20
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.015, 0.035, 0.045, 0.97)
    style.border_color = Color(0.95, 0.48, 0.12, 1.0)
    style.set_border_width_all(2)
    style.set_corner_radius_all(10)
    matchmaking_panel.add_theme_stylebox_override("panel", style)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 14)
    matchmaking_panel.add_child(box)
    var title := Label.new()
    title.text = "MATCHMAKING"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 26)
    title.add_theme_color_override("font_color", Color(1.0, 0.68, 0.25))
    box.add_child(title)
    matchmaking_label = Label.new()
    matchmaking_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    matchmaking_label.add_theme_font_size_override("font_size", 17)
    matchmaking_label.add_theme_color_override("font_color", Color.WHITE)
    box.add_child(matchmaking_label)
    var cancel := Button.new()
    cancel.text = "CANCEL SEARCH"
    cancel.custom_minimum_size = Vector2(0, 42)
    cancel.pressed.connect(func():
        matchmaking_active = false
        matchmaking_layer.queue_free()
    )
    box.add_child(cancel)
    matchmaking_layer.add_child(matchmaking_panel)
