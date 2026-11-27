extends CharacterBody3D

@export var health := 100
@export var move_speed := 2.2
@export var attack_range := 13.0
@export var attack_damage := 8
@export var attack_interval := 1.2
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var target: Node3D
var attack_clock := 0.0
var visual: Node3D

func _ready() -> void:
    target = get_tree().get_first_node_in_group("player")
    visual = Node3D.new()
    visual.name = "EnemySoldierVisual"
    visual.set_script(load("res://scripts/soldier_visual.gd"))
    add_child(visual)
    var old_body := get_node_or_null("Body")
    if old_body:
        old_body.visible = false

func _physics_process(delta: float) -> void:
    attack_clock += delta
    if not is_on_floor():
        velocity.y -= gravity * delta
    if is_instance_valid(target):
        var offset := target.global_position - global_position
        offset.y = 0
        var distance := offset.length()
        if distance > 2.2:
            velocity.x = offset.normalized().x * move_speed
            velocity.z = offset.normalized().z * move_speed
            look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
        else:
            velocity.x = move_toward(velocity.x, 0.0, move_speed * delta)
            velocity.z = move_toward(velocity.z, 0.0, move_speed * delta)
        if distance <= attack_range and attack_clock >= attack_interval and target.has_method("take_damage"):
            target.take_damage(attack_damage)
            attack_clock = 0.0
    move_and_slide()
    if visual and visual.has_method("play_locomotion"):
        visual.play_locomotion(Vector2(velocity.x, velocity.z).length() > 0.2)

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        queue_free()
