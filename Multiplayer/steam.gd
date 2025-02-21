extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	Steam.steamInitEx()

func _process(delta: float) -> void:
	Steam.run_callbacks()
