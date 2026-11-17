extends CharacterBody3D
@export var health := 100
@export var move_speed := 2.2
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var target: Node3D
func _ready() -> void:
    target = get_tree().get_first_node_in_group("player")
    if target == null:
        target = get_parent().get_node_or_null("Player")
func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    if is_instance_valid(target):
        var offset := target.global_position - global_position
        offset.y = 0
        if offset.length() > 2.0:
            velocity.x = offset.normalized().x * move_speed
            velocity.z = offset.normalized().z * move_speed
            look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
        else:
            velocity.x = move_toward(velocity.x, 0, move_speed)
            velocity.z = move_toward(velocity.z, 0, move_speed)
    move_and_slide()
func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        queue_free()
