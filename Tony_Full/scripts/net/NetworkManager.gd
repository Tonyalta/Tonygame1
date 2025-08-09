extends Node
class_name NetworkManager

const DEFAULT_PORT := 24565
const MAX_PLAYERS := 16

signal server_started
signal client_connected
signal client_disconnected(id)
signal chat_message(from_id, channel, text)
signal voice_packet(from_id, bytes)

var is_server := false
var peers := {}
var team_of := {}
var my_id := 1

func _ready():
    my_id = Multiplayer.get_unique_id()

func start_server(port:int=DEFAULT_PORT):
    var peer := ENetMultiplayerPeer.new()
    var err := peer.create_server(port, MAX_PLAYERS)
    if err != OK: push_error("Failed to create server: %s" % err); return
    Multiplayer.peer = peer
    is_server = true
    Multiplayer.peer_connected.connect(_on_peer_connected)
    Multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    rpc_config("rpc_chat", MultiplayerAPI.RPC_MODE_ANY_PEER)
    rpc_config("rpc_voice", MultiplayerAPI.RPC_MODE_ANY_PEER)
    emit_signal("server_started")

func connect_to_server(host:String, port:int=DEFAULT_PORT):
    var peer := ENetMultiplayerPeer.new()
    var err := peer.create_client(host, port)
    if err != OK: push_error("Failed to connect: %s" % err); return
    Multiplayer.peer = peer
    Multiplayer.connected_to_server.connect(func(): emit_signal("client_connected"))
    Multiplayer.server_disconnected.connect(func(): emit_signal("client_disconnected", 1))
    rpc_config("rpc_chat", MultiplayerAPI.RPC_MODE_AUTHORITY)
    rpc_config("rpc_voice", MultiplayerAPI.RPC_MODE_AUTHORITY)

func _on_peer_connected(id:int): peers[id] = true
func _on_peer_disconnected(id:int): peers.erase(id); emit_signal("client_disconnected", id)

@rpc(any_peer=true, call_local=false)
func rpc_chat(channel:String, text:String, to_id:int=-1):
    if not is_server: return
    var from_id := Multiplayer.get_remote_sender_id()
    text = text.substr(0, 300)
    if text.strip_edges() == "": return
    if channel == "dm" and to_id > 0:
        rpc_id(to_id, "rpc_chat_deliver", from_id, "dm", text)
        rpc_id(from_id, "rpc_chat_deliver", from_id, "dm", text)
    elif channel == "team":
        var team := team_of.get(from_id, -1)
        for pid in peers.keys():
            if team_of.get(pid, -2) == team:
                rpc_id(pid, "rpc_chat_deliver", from_id, "team", text)
    else:
        rpc("rpc_chat_deliver", from_id, "global", text)

@rpc(any_peer=true, call_local=true)
func rpc_chat_deliver(from_id:int, channel:String, text:String):
    emit_signal("chat_message", from_id, channel, text)

@rpc(any_peer=true, call_local=false, reliable=false)
func rpc_voice(packet:PackedByteArray):
    if not is_server: return
    var from_id := Multiplayer.get_remote_sender_id()
    var team := team_of.get(from_id, -1)
    for pid in peers.keys():
        if team_of.get(pid, -2) == team:
            rpc_id(pid, "rpc_voice_deliver", from_id, packet)

@rpc(any_peer=true, call_local=true, reliable=false)
func rpc_voice_deliver(from_id:int, packet:PackedByteArray):
    emit_signal("voice_packet", from_id, packet)