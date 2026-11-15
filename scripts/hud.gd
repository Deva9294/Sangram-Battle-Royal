extends Control

var player
var stats: Label
var result_panel: Panel
var mobile_left := false
var mobile_right := false
var mobile_forward := false
var mobile_back := false

func _ready():
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    stats = Label.new()
    stats.position = Vector2(22, 18)
    stats.add_theme_font_size_override("font_size", 23)
    stats.add_theme_color_override("font_color", Color.WHITE)
    stats.text = "SANGRAM  |  Loading..."
    add_child(stats)
    _button("FIRE", Vector2(-145, -145), Vector2(110, 72), "fire")
    _button("RELOAD", Vector2(-270, -92), Vector2(105, 55), "reload")
    _button("JUMP", Vector2(-145, -65), Vector2(95, 55), "jump")
    _button("▲", Vector2(90, -190), Vector2(65, 60), "forward")
    _button("▼", Vector2(90, -55), Vector2(65, 60), "back")
    _button("◀", Vector2(25, -122), Vector2(65, 60), "left")
    _button("▶", Vector2(155, -122), Vector2(65, 60), "right")
    var hint = Label.new()
    hint.text = "WASD: MOVE  |  MOUSE: AIM  |  CLICK: FIRE  |  R: RELOAD  |  SPACE: JUMP"
    hint.position = Vector2(22, 62)
    hint.add_theme_font_size_override("font_size", 14)
    hint.add_theme_color_override("font_color", Color(1,1,1,0.9))
    add_child(hint)

func _button(caption: String, offset: Vector2, size: Vector2, action: String):
    var b = Button.new()
    b.text = caption
    b.custom_minimum_size = size
    var is_move_button = action in ["forward", "back", "left", "right"]
    b.anchor_left = 0.0 if is_move_button else 1.0
    b.anchor_right = 0.0 if is_move_button else 1.0
    b.anchor_top = 1.0
    b.anchor_bottom = 1.0
    b.offset_left = offset.x
    b.offset_right = offset.x + size.x
    b.offset_top = offset.y
    b.offset_bottom = offset.y + size.y
    b.modulate = Color(1,1,1,0.82)
    add_child(b)
    if action == "fire":
        b.button_down.connect(func(): player.mobile_fire = true)
        b.button_up.connect(func(): player.mobile_fire = false)
    elif action == "reload":
        b.pressed.connect(func(): player.reload())
    elif action == "jump":
        b.pressed.connect(func(): player.velocity.y = 7.0)
    else:
        b.button_down.connect(func(): _move(action, true))
        b.button_up.connect(func(): _move(action, false))

func _move(action: String, pressed: bool):
    match action:
        "forward": mobile_forward = pressed
        "back": mobile_back = pressed
        "left": mobile_left = pressed
        "right": mobile_right = pressed
    player.mobile_move = Vector2(float(mobile_right) - float(mobile_left), float(mobile_back) - float(mobile_forward))

func update_stats(p, remaining: int, zone: float, time: float):
    if not is_instance_valid(p): return
    stats.text = "SANGRAM  |  HP %d  |  AMMO %d/%d  |  ENEMIES %d  |  ZONE %.0fm  |  %02d:%02d" % [int(p.health), p.ammo, p.reserve_ammo, remaining, zone, int(time) / 60, int(time) % 60]

func show_result(won: bool):
    if result_panel and is_instance_valid(result_panel):
        return
    result_panel = Panel.new()
    result_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    result_panel.position = Vector2(-230, -115)
    result_panel.size = Vector2(460, 230)
    add_child(result_panel)
    var layout = VBoxContainer.new()
    layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layout.add_theme_constant_override("separation", 18)
    result_panel.add_child(layout)
    var label = Label.new()
    label.text = "BOOYAH! CHAMPION" if won else "YOU HAVE BEEN ELIMINATED"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 25)
    layout.add_child(label)
    var subtitle = Label.new()
    subtitle.text = "All opponents eliminated" if won else "Try another drop and fight again"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    layout.add_child(subtitle)
    var restart = Button.new()
    restart.text = "PLAY AGAIN"
    restart.custom_minimum_size = Vector2(180, 54)
    restart.pressed.connect(func(): get_tree().reload_current_scene())
    layout.add_child(restart)
