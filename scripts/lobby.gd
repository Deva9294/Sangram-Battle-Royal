extends Node3D

# SANGRAM Android ARM64 debug build validation.

var selected_operator := 0
var preview_root: Node3D
var operator_names := ["VEER", "TARA", "RUDRA"]
var operator_roles := ["ASSAULT • MALWA FRONTIER", "RECON • CENTRAL INDIA", "SUPPORT • NARMADA UNIT"]
var operator_colors := [Color(0.24,0.31,0.22), Color(0.20,0.30,0.38), Color(0.38,0.27,0.18)]
var info_label: Label
var idle_time := 0.0

func _ready():
    _build_lobby_world()
    _build_interface()
    _show_operator()

func _process(delta):
    idle_time += delta
    if preview_root and is_instance_valid(preview_root):
        preview_root.rotation.y = sin(idle_time * 0.32) * 0.12
        preview_root.position.y = sin(idle_time * 1.2) * 0.025

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
    var layer := CanvasLayer.new()
    layer.layer = 5
    add_child(layer)

    var screen := ColorRect.new()
    screen.color = Color(0.012, 0.022, 0.03, 0.28)
    screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(screen)

    # Header / brand strip
    var brand := Label.new()
    brand.text = "SANGRAM"
    brand.position = Vector2(28, 16)
    brand.add_theme_font_size_override("font_size", 34)
    brand.add_theme_color_override("font_color", Color(0.98, 0.96, 0.88))
    brand.add_theme_constant_override("outline_size", 4)
    brand.add_theme_color_override("font_outline_color", Color(0.04, 0.07, 0.08))
    layer.add_child(brand)

    var tagline := Label.new()
    tagline.text = "INDIA'S BATTLEFIELD  •  DEVA CORE STUDIO"
    tagline.position = Vector2(31, 54)
    tagline.add_theme_font_size_override("font_size", 10)
    tagline.add_theme_color_override("font_color", Color(0.85, 0.66, 0.34))
    layer.add_child(tagline)

    var status := _lobby_label("●  OFFLINE BOT MATCH  |  24 ENEMIES", 12, Color(0.60, 0.92, 0.70))
    status.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    status.position = Vector2(-260, 22)
    status.size = Vector2(240, 28)
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    layer.add_child(status)

    # Left operator selection card
    var left := _lobby_panel(layer, Vector2(24, 104), Vector2(238, 222))
    var left_layout := VBoxContainer.new()
    left_layout.add_theme_constant_override("separation", 7)
    left.add_child(left_layout)
    left_layout.add_child(_lobby_label("YOUR OPERATOR", 12, Color(0.94, 0.68, 0.32)))
    info_label = _lobby_label("VEER\nASSAULT • MALWA FRONTIER", 18, Color(0.97, 0.97, 0.91))
    info_label.custom_minimum_size = Vector2(0, 52)
    left_layout.add_child(info_label)
    left_layout.add_child(_lobby_label("SELECT SOLDIER", 10, Color(0.62, 0.72, 0.74)))
    for i in range(operator_names.size()):
        var b := _lobby_button("%02d   %s" % [i + 1, operator_names[i]], false)
        b.custom_minimum_size = Vector2(0, 34)
        b.pressed.connect(_select_operator.bind(i))
        left_layout.add_child(b)

    # Right mission / map card
    var right := _lobby_panel(layer, Vector2(-252, 104), Vector2(228, 222), true)
    var right_layout := VBoxContainer.new()
    right_layout.add_theme_constant_override("separation", 8)
    right.add_child(right_layout)
    right_layout.add_child(_lobby_label("MISSION BRIEF", 12, Color(0.94, 0.68, 0.32)))
    right_layout.add_child(_lobby_label("MALWA FRONTIER", 17, Color(0.98, 0.97, 0.90)))
    right_layout.add_child(_lobby_label("MADHYA PRADESH  /  INDIA", 10, Color(0.68, 0.78, 0.78)))
    right_layout.add_child(_lobby_label("MODE     SOLO SURVIVAL", 11, Color(0.91, 0.92, 0.86)))
    right_layout.add_child(_lobby_label("ENEMIES  24 AI SOLDIERS", 11, Color(0.91, 0.92, 0.86)))
    right_layout.add_child(_lobby_label("MAP STATUS  •  TRAINING BUILD", 9, Color(0.63, 0.76, 0.68)))
    var briefing := _lobby_label("LOOT  •  SAFE ZONE  •  LAST SURVIVOR WINS", 9, Color(0.84, 0.78, 0.62))
    briefing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    right_layout.add_child(briefing)

    # Bottom navigation and deployment bar
    var footer := _lobby_panel(layer, Vector2(24, -72), Vector2(-48, 54), false, true)
    var footer_row := HBoxContainer.new()
    footer_row.add_theme_constant_override("separation", 10)
    footer.add_child(footer_row)
    var tabs := ["LOADOUT", "MISSIONS", "REWARDS"]
    for tab in tabs:
        var tab_button := _lobby_button(tab, false)
        tab_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        tab_button.custom_minimum_size = Vector2(0, 38)
        footer_row.add_child(tab_button)
        tab_button.pressed.connect(func(): _show_lobby_notice(tab + "  •  COMING IN A FUTURE UPDATE"))
    var deploy := _lobby_button("▶   DEPLOY NOW", true)
    deploy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    deploy.custom_minimum_size = Vector2(0, 42)
    footer_row.add_child(deploy)
    deploy.pressed.connect(_deploy)

    var bottom_note := _lobby_label("BUILD 0.3  •  OFFLINE SURVIVAL  •  CENTRAL INDIA MAP", 9, Color(0.75, 0.80, 0.78))
    bottom_note.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    bottom_note.position = Vector2(28, -18)
    bottom_note.size = Vector2(320, 16)
    layer.add_child(bottom_note)

    var vignette := ColorRect.new()
    vignette.color = Color(0.01, 0.02, 0.025, 0.10)
    vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(vignette)
    vignette.z_index = -1

func _lobby_panel(parent: Control, offset: Vector2, panel_size: Vector2, right_side := false, bottom := false) -> PanelContainer:
    var panel := PanelContainer.new()
    if bottom:
        panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
        panel.offset_left = offset.x
        panel.offset_top = offset.y
        panel.offset_right = offset.y
        panel.offset_bottom = 0
    elif right_side:
        panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
        panel.position = offset
        panel.size = panel_size
    else:
        panel.position = offset
        panel.size = panel_size
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.025, 0.045, 0.052, 0.88)
    style.border_color = Color(0.72, 0.43, 0.17, 0.92)
    style.set_border_width_all(1)
    style.set_corner_radius_all(7)
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    panel.add_theme_stylebox_override("panel", style)
    parent.add_child(panel)
    return panel

func _lobby_label(value: String, font_size: int, tint: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", tint)
    label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    return label

func _lobby_button(value: String, primary: bool) -> Button:
    var button := Button.new()
    button.text = value
    button.add_theme_font_size_override("font_size", 12 if not primary else 16)
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.12, 0.17, 0.17, 0.96) if not primary else Color(0.70, 0.29, 0.075, 1.0)
    normal.border_color = Color(0.48, 0.54, 0.48) if not primary else Color(1.0, 0.69, 0.30)
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(4)
    normal.content_margin_left = 8
    normal.content_margin_right = 8
    normal.content_margin_top = 5
    normal.content_margin_bottom = 5
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color(0.22, 0.29, 0.25) if not primary else Color(0.86, 0.39, 0.10)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)
    button.add_theme_color_override("font_color", Color(0.96, 0.96, 0.90))
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    return button

func _show_lobby_notice(message: String) -> void:
    var popup := AcceptDialog.new()
    popup.title = "SANGRAM COMMAND"
    popup.dialog_text = message
    add_child(popup)
    popup.popup_centered()

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

func _deploy():
    get_tree().change_scene_to_file("res://scenes/game.tscn")
