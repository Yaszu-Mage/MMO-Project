extends Node
var multi : MultiplayerAPI
var peer
var players = {}
var player_info = {}
var players_loaded = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func server_init(port):
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 40)
	multiplayer.multiplayer_peer = peer
	
func client_join(ip,port):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
