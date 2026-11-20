extends Control

signal changed(value: Vector2)

var touch_index := -1
var knob := Vector2.ZERO
var radius := 64.0

func _ready() -> void:
    custom_minimum_size = Vector2(164, 164)
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and touch_index == -1:
            touch_index = event.index
            _update_knob(event.position)
        elif not event.pressed and event.index == touch_index:
            touch_index = -1
            knob = Vector2.ZERO
            changed.emit(Vector2.ZERO)
            queue_redraw()
        accept_event()
    elif event is InputEventScreenDrag and event.index == touch_index:
        _update_knob(event.position)
        accept_event()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            touch_index = -2
            _update_knob(event.position)
        else:
            touch_index = -1
            knob = Vector2.ZERO
            changed.emit(Vector2.ZERO)
            queue_redraw()
        accept_event()
    elif event is InputEventMouseMotion and touch_index == -2:
        _update_knob(event.position)
        accept_event()

func _update_knob(position: Vector2) -> void:
    var offset := (position - size * 0.5).limit_length(radius)
    knob = offset / radius
    changed.emit(knob)
    queue_redraw()

func _draw() -> void:
    var center := size * 0.5
    draw_circle(center, radius + 7.0, Color(0.02, 0.04, 0.05, 0.52))
    draw_arc(center, radius, 0.0, TAU, 48, Color(0.9, 0.94, 0.92, 0.72), 2.0)
    draw_circle(center + knob * radius, 25.0, Color(0.88, 0.91, 0.87, 0.62))
