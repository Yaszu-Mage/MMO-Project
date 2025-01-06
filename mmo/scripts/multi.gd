extends Node
var multi : MultiplayerAPI
var peer
var players = {}
var player_info = {}
var players_loaded = 0
@onready var map = preload("res://scenes/world_pregen.tscn")
# Called when the node enters the scene tree for the first time.

func server_init(port):
	peer = ENetMultiplayerPeer.new()
	var map_instance = map.instantiate()
	add_child(map_instance)
	peer.create_server(port, 40)
	multiplayer.multiplayer_peer = peer
	
func client_join(ip,port):
	peer = ENetMultiplayerPeer.new()
	var map_instance = map.instantiate()
	get_parent().add_child(map_instance)
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
