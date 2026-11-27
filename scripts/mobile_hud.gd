extends CanvasLayer
# Touch overlay drives the same input actions as keyboard/gamepad.
func _ready() -> void:
    _make_button("FIRE", "fire", Vector2(0.86, 0.78), Vector2(88, 88))
    _make_button("JUMP", "jump", Vector2(0.91, 0.59), Vector2(68, 68))
    _make_button("SPRINT", "sprint", Vector2(0.75, 0.9), Vector2(72, 58))
    _make_button("RELOAD", "reload", Vector2(0.96, 0.9), Vector2(64, 58))
    _make_stick()
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
    add_child(label)
func _make_stick() -> void:
    var base := ColorRect.new()
    base.name = "MoveStickBase"
    base.position = Vector2(42, get_viewport().get_visible_rect().size.y - 188)
    base.size = Vector2(142, 142)
    base.color = Color(0.08, 0.1, 0.08, 0.38)
    base.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(base)
    var hint := Label.new()
    hint.text = "MOVE"
    hint.position = base.position + Vector2(44, 55)
    hint.add_theme_font_size_override("font_size", 16)
    add_child(hint)
