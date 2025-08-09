extends Node
class_name Game
var default_port:int = 24565
var default_host:String = "127.0.0.1"
var is_host := false
var data := {}

func _ready():
    # Load gameplay data
    var f := FileAccess.open("res://data/tony_gameplay_data.json", FileAccess.READ)
    if f:
        data = JSON.parse_string(f.get_as_text())
        f.close()

func _get_net() -> Node:
    var n := get_tree().root.get_node_or_null("Main/NetworkManager/NetworkManagerScript")
    if n == null: n = get_tree().root.get_node_or_null("Main/NetworkManager")
    return n

func start_server():
    var net = _get_net()
    if net and net.has_method("start_server"):
        net.start_server(default_port)
        is_host = true
        print("Server started on port %d" % default_port)

func connect_client():
    var net = _get_net()
    if net and net.has_method("connect_to_server"):
        net.connect_to_server(default_host, default_port)
        is_host = false
        print("Client connecting to %s:%d" % [default_host, default_port])