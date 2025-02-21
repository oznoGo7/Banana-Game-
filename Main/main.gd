extends Control


var lobby_id = 0
var peer = SteamMultiplayerPeer.new()


@onready var ms = $MultiplayerSpawner

func _ready() -> void:
	ms.spawn_function = spawnLevel
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	open_lobby_list()

func spawnLevel(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

func _on_host_pressed() -> void:
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	ms.spawn("res://Maps/Level.tscn")
	$Host.hide()
	$"Control/Lobby Container/Lobbies".hide()
	$Refresh.hide()

func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	$Host.hide()
	$"Control/Lobby Container/Lobbies".hide()
	$Refresh.hide()

func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName() + "'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		print("Lobby ID: " + str(lobby_id))


func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()


func _on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var mem_count = Steam.getNumLobbyMembers(lobby)
		
		var but = Button.new()
		but.set_text(str(lobby_name, " | Player Count: ", mem_count))
		but.set_size(Vector2(100,5))
		but.connect("pressed",Callable(self, "join_lobby").bind(lobby))
		
		$"Control/Lobby Container/Lobbies".add_child(but)



func _on_refresh_pressed() -> void:
	if $"Control/Lobby Container/Lobbies".get_child_count() > 0:
		for n in $"Control/Lobby Container/Lobbies".get_children():
			n.queue_free()
			open_lobby_list()
