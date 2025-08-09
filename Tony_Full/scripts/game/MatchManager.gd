extends Node
class_name MatchManager

signal duel_started(duel_index:int, fighters:Array)
signal duel_result(duel_index:int, placements:Array)
signal match_over(scores:Array)

const TEAMS := 4
const TEAM_SIZE := 4
const DUEL_INTERVAL := 180.0
const DUELS_TOTAL := 5

var timer := 0.0
var current_duel := -1
var scores := [0,0,0,0]

var intermission_time := 40.0
var in_intermission := true

func _process(delta:float):
    timer += delta
    if in_intermission and timer >= intermission_time:
        _start_duel()
    elif not in_intermission and timer >= DUEL_INTERVAL:
        _start_intermission()

func _start_intermission():
    in_intermission = true
    timer = 0.0
    # Notify UI/Managers to run minigames, draft, shop
    var im := get_node_or_null("/root/IntermissionManager")
    if im: im.start_intermission()

func _start_duel():
    in_intermission = false
    timer = 0.0
    current_duel += 1
    if current_duel >= DUELS_TOTAL:
        emit_signal("match_over", scores)
        return
    var fighters := []
    for t in range(TEAMS):
        fighters.append(_pick_fighter_for_team(t))
    emit_signal("duel_started", current_duel, fighters)

func _pick_fighter_for_team(team:int) -> int:
    # placeholder; integrate with team manager/bots
    return -1

func report_duel_result(placements:Array):
    if placements.size() != 4: return
    var points := [3,2,1,0]
    var net := get_tree().root.get_node("Main/NetworkManager/NetworkManagerScript")
    for i in range(4):
        var pid := placements[i]
        var team := net.team_of.get(pid, -1) if net else -1
        if team >= 0: scores[team] += points[i]
    emit_signal("duel_result", current_duel, placements)
    _start_intermission()