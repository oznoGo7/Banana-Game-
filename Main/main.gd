extends Control


var lobby_id = 0
var peer = SteamMultiplayerPeer.new()
var lobby_members = []

@onready var ms = $MultiplayerSpawner
@onready var main_menu_control: Control = $"Main Menu Control"
@onready var v_box_container: VBoxContainer = $"Main Menu Control/VBoxContainer"
@onready var host: Button = $"Main Menu Control/VBoxContainer/Host"
@onready var refresh: Button = $"Main Menu Control/VBoxContainer/Refresh"
@onready var lobbies_control: Control = $"Lobbies Control"
@onready var lobby_container: ScrollContainer = $"Lobbies Control/Lobby Container"
@onready var lobbies: VBoxContainer = $"Lobbies Control/Lobby Container/Lobbies"
@onready var multiplayer_control: Control = $"Multiplayer Control"
@onready var lobby_list: VBoxContainer = $"Multiplayer Control/Lobby List"


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
	#ms.spawn("res://Maps/Level.tscn") For starting a level implement this line
	lobby_members.append(Steam.getPersonaName())
	print(lobby_members)
	display_lobby_list()
	hide_main_menu()

func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	lobby_members.append(Steam.getPersonaName())
	display_lobby_list()
	hide_main_menu()

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
		
		$"Lobbies Control/Lobby Container/Lobbies".add_child(but)



func _on_refresh_pressed() -> void:
	if lobbies.get_child_count() > 0:
		for n in lobbies.get_children():
			n.queue_free()
			open_lobby_list()


func display_lobby_list():
	multiplayer_control.show()
	for people in lobby_members:
		var player_tag = Label.new()
		player_tag.set_text(str(Steam.getPersonaName()))
		lobby_list.add_child(player_tag)


func hide_main_menu():
	host.hide()
	lobbies.hide()
	refresh.hide()
