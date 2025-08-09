extends Node
class_name IntermissionManager
# Autoload recommended in a larger project, kept as scene node for MVP.

var data = {}
var active_minigame := null

func _ready():
    if Game.data.has("minigames"):
        data = Game.data

func start_intermission():
    # Pick one minigame
    if data.has("minigames"):
        var pool = data["minigames"]
        if pool.size() > 0:
            active_minigame = pool[randi() % pool.size()]
            print("Starting minigame: %s" % active_minigame["name"])