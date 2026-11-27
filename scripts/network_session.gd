extends Node

signal session_changed(mode: String, status: String)
signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)

const DEFAULT_PORT := 2456
const MAX_CLIENTS := 32

var mode := "offline"
var status := "Offline training ready"
var is_server := false
var connected_peers: Array[int] = []

func host_game(port: int = DEFAULT_PORT) -> Error:
    leave_game()
    var peer := ENetMultiplayerPeer.new()
    var result := peer.create_server(port, MAX_CLIENTS)
    if result != OK:
        _set_status("Could not start host (error %d)" % result)
        return result
    multiplayer.multiplayer_peer = peer
    mode = "online"
    is_server = true
    connected_peers.clear()
    _set_status("Host running • waiting for players")
    return OK

func join_game(address: String, port: int = DEFAULT_PORT) -> Error:
    leave_game()
    if address.strip_edges().is_empty():
        _set_status("Enter host IP address")
        return ERR_INVALID_PARAMETER
    var peer := ENetMultiplayerPeer.new()
    var result := peer.create_client(address.strip_edges(), port)
    if result != OK:
        _set_status("Could not connect (error %d)" % result)
        return result
    multiplayer.multiplayer_peer = peer
    mode = "online"
    is_server = false
    _set_status("Connecting to %s:%d..." % [address, port])
    return OK

func leave_game() -> void:
    if multiplayer.multiplayer_peer:
        multiplayer.multiplayer_peer.close()
    multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
    mode = "offline"
    is_server = false
    connected_peers.clear()
    _set_status("Offline training ready")

func _ready() -> void:
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connected_to_server.connect(_on_connected)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_peer_connected(peer_id: int) -> void:
    if not connected_peers.has(peer_id):
        connected_peers.append(peer_id)
    peer_joined.emit(peer_id)
    _set_status("Online • %d remote player(s) connected" % connected_peers.size())

func _on_peer_disconnected(peer_id: int) -> void:
    connected_peers.erase(peer_id)
    peer_left.emit(peer_id)
    _set_status("Online • %d remote player(s) connected" % connected_peers.size())

func _on_connected() -> void:
    _set_status("Connected to host • waiting for match")

func _on_connection_failed() -> void:
    leave_game()
    _set_status("Connection failed • check host IP, port and network")

func _on_server_disconnected() -> void:
    leave_game()
    _set_status("Host disconnected")

func _set_status(value: String) -> void:
    status = value
    session_changed.emit(mode, status)
