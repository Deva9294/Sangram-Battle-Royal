extends Node3D
@export var arena_size := 100.0
var elapsed := 0.0
var zone_radius := 48.0
var zone_shrink_rate := 0.12
@onready var player: CharacterBody3D = $Player
@onready var status: Label = $HUD/Status
func _ready() -> void:
    player.add_to_group("player")
    _make_arena()
func _process(delta: float) -> void:
    elapsed += delta
    zone_radius = maxf(12.0, zone_radius - zone_shrink_rate * delta)
    if is_instance_valid(player):
        var outside := Vector2(player.global_position.x, player.global_position.z).length() > zone_radius
        if outside and int(elapsed * 2.0) % 2 == 0:
            player.health = maxi(0, player.health - 1)
        status.text = "SANGRAM | HP %d | AMMO %d | SAFE ZONE %.0fm" % [player.health, player.ammo, zone_radius]
        if player.health <= 0:
            status.text = "YOU ARE ELIMINATED | RESTART TRAINING"
func _make_arena() -> void:
    var ground_mesh := PlaneMesh.new()
    ground_mesh.size = Vector2(arena_size, arena_size)
    $Ground/Mesh.mesh = ground_mesh
    var ground_collision := BoxShape3D.new()
    ground_collision.size = Vector3(arena_size, 0.3, arena_size)
    $Ground/Collision.shape = ground_collision
    for i in range(24):
        var prop := MeshInstance3D.new()
        var box := BoxMesh.new()
        box.size = Vector3(randf_range(1.0, 3.0), randf_range(1.0, 4.0), randf_range(1.0, 3.0))
        prop.mesh = box
        prop.position = Vector3(randf_range(-42, 42), box.size.y / 2.0, randf_range(-42, 42))
        $Decor.add_child(prop)
