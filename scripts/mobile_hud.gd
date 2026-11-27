extends CanvasLayer

var stick_pointer := -1
var stick_origin := Vector2.ZERO
var stick_vector := Vector2.ZERO
var look_hint: Label

func _ready() -> void:
    _make_button("FIRE", "fire", Vector2(0.86, 0.78), Vector2(88, 88))
    _make_button("JUMP", "jump", Vector2(0.91, 0.59), Vector2(68, 68))
    _make_button("SPRINT", "sprint", Vector2(0.75, 0.9), Vector2(72, 58))
    _make_button("RELOAD", "reload", Vector2(0.96, 0.9), Vector2(64, 58))
    _make_stick()
    var hint := Label.new()
    hint.text = "DRAG RIGHT SIDE TO LOOK"
    hint.position = Vector2(get_viewport().get_visible_rect().size.x * 0.58, 24)
    hint.add_theme_font_size_override("font_size", 14)
    hint.modulate = Color(1, 1, 1, 0.55)
    add_child(hint)

func _make_button(caption: String, action: String, anchor: Vector2, dims: Vector2) -> void:
    var b := TouchScreenButton.new()
    b.name = caption
    b.action = action
    b.position = get_viewport().get_visible_rect().size * anchor
    var shape := CircleShape2D.new()
    shape.radius = dims.x * 0.5
    b.shape = shape
    b.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
    add_child(b)
    var label := Label.new()
    label.text = caption
    label.position = b.position - dims * 0.5
    label.size = dims
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 13)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(label)

func _make_stick() -> void:
    var base := ColorRect.new()
    base.name = "MoveStickBase"
    base.position = Vector2(42, get_viewport().get_visible_rect().size.y - 188)
    base.size = Vector2(142, 142)
    base.color = Color(0.08, 0.1, 0.08, 0.38)
    base.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(base)
    var knob := ColorRect.new()
    knob.name = "MoveStickKnob"
    knob.position = base.position + Vector2(46, 46)
    knob.size = Vector2(50, 50)
    knob.color = Color(0.8, 0.85, 0.78, 0.65)
    knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(knob)
    var label := Label.new()
    label.text = "MOVE"
    label.position = base.position + Vector2(44, 55)
    label.add_theme_font_size_override("font_size", 15)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(label)

func _input(event: InputEvent) -> void:
    var size := get_viewport().get_visible_rect().size
    var center := Vector2(113, size.y - 117)
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x < size.x * 0.42 and event.position.distance_to(center) < 115.0 and stick_pointer == -1:
            stick_pointer = event.index
            stick_origin = center
            _update_stick(event.position)
        elif not event.pressed and event.index == stick_pointer:
            stick_pointer = -1
            stick_vector = Vector2.ZERO
            _send_move_actions()
            _reset_knob()
    elif event is InputEventScreenDrag and event.index == stick_pointer:
        _update_stick(event.position)

func _update_stick(position: Vector2) -> void:
    var delta := position - stick_origin
    if delta.length() > 55.0:
        delta = delta.normalized() * 55.0
    stick_vector = delta / 55.0
    _send_move_actions()
    var knob := get_node_or_null("MoveStickKnob") as ColorRect
    if knob:
        knob.position = stick_origin + delta - Vector2(25, 25)

func _send_move_actions() -> void:
    _set_action("move_left", stick_vector.x < -0.18)
    _set_action("move_right", stick_vector.x > 0.18)
    _set_action("move_forward", stick_vector.y < -0.18)
    _set_action("move_back", stick_vector.y > 0.18)

func _set_action(action: String, pressed: bool) -> void:
    var ev := InputEventAction.new()
    ev.action = action
    ev.pressed = pressed
    Input.parse_input_event(ev)

func _reset_knob() -> void:
    var knob := get_node_or_null("MoveStickKnob") as ColorRect
    if knob:
        knob.position = stick_origin - Vector2(25, 25)
