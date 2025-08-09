extends Control
class_name StartUI
@onready var host: LineEdit = $"../Panel/VBox/HBox_Host/Host"
@onready var port: LineEdit = $"../Panel/VBox/HBox_Port/Port"
@onready var status_label: Label = $"../Panel/VBox/Status"

func _ready():
    host.text = Game.default_host
    port.text = str(Game.default_port)
    $"../Panel/VBox/Buttons/BtnHost".pressed.connect(_on_host_pressed)
    $"../Panel/VBox/Buttons/BtnClient".pressed.connect(_on_client_pressed)

func _on_host_pressed():
    Game.default_host = host.text.strip_edges()
    Game.default_port = int(port.text)
    Game.start_server()
    status_label.text = "Server gestartet auf Port %d" % Game.default_port

func _on_client_pressed():
    Game.default_host = host.text.strip_edges()
    Game.default_port = int(port.text)
    Game.connect_client()
    status_label.text = "Client verbindet zu %s:%d" % [Game.default_host, Game.default_port]