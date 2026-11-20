extends Control

const VirtualJoystick = preload("res://scripts/virtual_joystick.gd")

var player
var stats: Label
var message_label: Label
var result_panel: Panel
var damage_overlay: ColorRect
var message_time := 0.0
var damage_time := 0.0
var radar_timer := 0.0
var mobile_left := false
var mobile_right := false
var mobile_forward := false
var mobile_back := false

func _ready():
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    stats = Label.new()
    stats.position = Vector2(22, 18)
    stats.add_theme_font_size_override("font_size", 20)
    stats.add_theme_color_override("font_color", Color.WHITE)
    stats.text = "SANGRAM  |  DEPLOYING..."
    add_child(stats)
    message_label = Label.new()
    message_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
    message_label.position = Vector2(-180, 82)
    message_label.size = Vector2(360, 42)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.add_theme_font_size_override("font_size", 23)
    message_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.25))
    add_child(message_label)
    message_label.visible = false
    damage_overlay = ColorRect.new()
    damage_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    damage_overlay.color = Color(0.9, 0.02, 0.02, 0.0)
    damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(damage_overlay)
    _button("FIRE", Vector2(-150, -158), Vector2(118, 82), "fire")
    _button("RELOAD", Vector2(-278, -95), Vector2(110, 56), "reload")
    _button("JUMP", Vector2(-150, -66), Vector2(100, 56), "jump")
    _button("AIM", Vector2(-278, -160), Vector2(86, 46), "aim")
    _button("SPRINT", Vector2(-278, -215), Vector2(86, 46), "sprint")
    _button("CROUCH", Vector2(-180, -225), Vector2(86, 46), "crouch")
    _button("PRONE", Vector2(-82, -225), Vector2(76, 46), "prone")
    _button("PICKUP", Vector2(-278, -280), Vector2(86, 46), "interact")
    _button("MEDKIT", Vector2(-180, -280), Vector2(86, 46), "use_medkit")
    _add_virtual_stick()
    var hint = Label.new()
    hint.text = "WASD MOVE  •  AIM  •  SPRINT  •  CROUCH  •  PRONE  •  FIRE"
    hint.position = Vector2(22, 62)
    hint.add_theme_font_size_override("font_size", 13)
    hint.add_theme_color_override("font_color", Color(1,1,1,0.9))
    add_child(hint)

func _add_virtual_stick() -> void:
    var stick = VirtualJoystick.new()
    stick.anchor_left = 0.0
    stick.anchor_right = 0.0
    stick.anchor_top = 1.0
    stick.anchor_bottom = 1.0
    stick.offset_left = 28.0
    stick.offset_right = 192.0
    stick.offset_top = -194.0
    stick.offset_bottom = -30.0
    stick.changed.connect(func(value: Vector2): player.mobile_move = value)
    add_child(stick)

func _process(delta):
    radar_timer += delta
    message_time = maxf(0.0, message_time - delta)
    damage_time = maxf(0.0, damage_time - delta)
    if message_time <= 0.0: message_label.visible = false
    damage_overlay.color.a = 0.24 * (damage_time / 0.22)
    if radar_timer >= 0.12:
        radar_timer = 0.0
        queue_redraw()

func _draw():
    var size = get_viewport_rect().size
    var center = Vector2(size.x - 112, 145)
    var radius = 68.0
    draw_circle(center, radius + 7.0, Color(0.015,0.025,0.03,0.76))
    draw_arc(center, radius, 0, TAU, 64, Color(0.78,0.88,0.86,0.95), 2.0)
    draw_arc(center, radius * 0.5, 0, TAU, 48, Color(0.55,0.65,0.62,0.38), 1.0)
    draw_line(center + Vector2(-radius,0), center + Vector2(radius,0), Color(0.55,0.65,0.62,0.28), 1.0)
    draw_line(center + Vector2(0,-radius), center + Vector2(0,radius), Color(0.55,0.65,0.62,0.28), 1.0)
    if player and is_instance_valid(player):
        for enemy in get_tree().get_nodes_in_group("bots"):
            if not is_instance_valid(enemy): continue
            var offset = Vector2(enemy.global_position.x - player.global_position.x, enemy.global_position.z - player.global_position.z)
            var point = center + Vector2(offset.x, offset.y) * 0.55
            if point.distance_to(center) <= radius - 4:
                draw_circle(point, 3.2, Color(1.0,0.25,0.16))
    draw_circle(center, 5.0, Color(0.25,0.95,0.68))
    draw_string(ThemeDB.fallback_font, center + Vector2(-19, radius + 22), "RADAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.88,0.92,0.88))
    var cross = size * 0.5
    draw_line(cross + Vector2(-10,0), cross + Vector2(-3,0), Color(1,1,1,0.95), 2.0)
    draw_line(cross + Vector2(3,0), cross + Vector2(10,0), Color(1,1,1,0.95), 2.0)
    draw_line(cross + Vector2(0,-10), cross + Vector2(0,-3), Color(1,1,1,0.95), 2.0)
    draw_line(cross + Vector2(0,3), cross + Vector2(0,10), Color(1,1,1,0.95), 2.0)

func _button(caption: String, offset: Vector2, size: Vector2, action: String):
    var b = Button.new()
    b.text = caption
    b.custom_minimum_size = size
    b.add_theme_font_size_override("font_size", 18 if action != "fire" else 21)
    var is_move_button = action in ["forward", "back", "left", "right"]
    b.anchor_left = 0.0 if is_move_button else 1.0
    b.anchor_right = 0.0 if is_move_button else 1.0
    b.anchor_top = 1.0
    b.anchor_bottom = 1.0
    b.offset_left = offset.x
    b.offset_right = offset.x + size.x
    b.offset_top = offset.y
    b.offset_bottom = offset.y + size.y
    b.modulate = Color(1,1,1,0.88)
    add_child(b)
    if action == "fire":
        b.button_down.connect(func(): player.mobile_fire = true)
        b.button_up.connect(func(): player.mobile_fire = false)
    elif action in ["aim", "crouch", "prone"]:
        b.toggle_mode = true
        b.toggled.connect(func(enabled: bool): _set_mobile_action(action, enabled))
    elif action == "sprint":
        b.button_down.connect(func(): _set_mobile_action("sprint", true))
        b.button_up.connect(func(): _set_mobile_action("sprint", false))
    elif action == "reload":
        b.pressed.connect(func(): player.reload())
    elif action == "interact":
        b.pressed.connect(func(): player.interact())
    elif action == "use_medkit":
        b.pressed.connect(func(): player.use_medkit())
    elif action == "jump":
        b.pressed.connect(func(): player.velocity.y = 7.0)
    else:
        b.button_down.connect(func(): _move(action, true))
        b.button_up.connect(func(): _move(action, false))

func _set_mobile_action(action: String, enabled: bool) -> void:
    if enabled:
        Input.action_press(action)
    else:
        Input.action_release(action)

func _move(action: String, pressed: bool):
    match action:
        "forward": mobile_forward = pressed
        "back": mobile_back = pressed
        "left": mobile_left = pressed
        "right": mobile_right = pressed
    player.mobile_move = Vector2(float(mobile_right) - float(mobile_left), float(mobile_back) - float(mobile_forward))

func update_stats(p, remaining: int, zone: float, time: float, kills: int, zone_countdown: float):
    if not is_instance_valid(p): return
    var zone_text = "ZONE IN %02d" % int(ceil(zone_countdown)) if zone_countdown > 0.0 else "ZONE %dm" % int(zone)
    stats.text = "SANGRAM  |  HP %d  |  ARM %d  |  KIT %d  |  AMMO %d/%d  |  ALIVE %d  |  KILLS %d  |  %s  |  %02d:%02d" % [int(p.health), int(p.armor), p.medkits, p.ammo, p.reserve_ammo, remaining + 1, kills, zone_text, int(time) / 60, int(time) % 60]

func show_message(message: String):
    message_label.text = message
    message_label.visible = true
    message_time = 1.5

func show_damage():
    damage_time = 0.22

func show_result(won: bool, final_kills := 0):
    if result_panel and is_instance_valid(result_panel): return
    result_panel = Panel.new()
    result_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    result_panel.position = Vector2(-240, -135)
    result_panel.size = Vector2(480, 270)
    add_child(result_panel)
    var layout = VBoxContainer.new()
    layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layout.add_theme_constant_override("separation", 14)
    layout.add_theme_constant_override("margin_left", 20)
    layout.add_theme_constant_override("margin_right", 20)
    layout.add_theme_constant_override("margin_top", 20)
    layout.add_theme_constant_override("margin_bottom", 20)
    result_panel.add_child(layout)
    var label = Label.new()
    label.text = "WINNER WINNER!" if won else "YOU ARE ELIMINATED"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 30)
    label.add_theme_color_override("font_color", Color(0.95, 0.72, 0.16) if won else Color(0.9, 0.25, 0.2))
    layout.add_child(label)
    var subtitle = Label.new()
    subtitle.text = "You survived the Malwa battlefield" if won else "The battlefield has claimed you. Drop again!"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    layout.add_child(subtitle)
    var score = Label.new()
    score.text = "ELIMINATIONS: %d" % final_kills
    score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    score.add_theme_font_size_override("font_size", 20)
    layout.add_child(score)
    var restart = Button.new()
    restart.text = "PLAY AGAIN"
    restart.custom_minimum_size = Vector2(190, 54)
    restart.pressed.connect(func(): get_tree().reload_current_scene())
    layout.add_child(restart)
