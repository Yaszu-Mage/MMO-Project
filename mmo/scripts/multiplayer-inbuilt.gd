extends Control
var peer = ENetMultiplayerPeer.new()
const port = 9999
var address = "localhost"
var connected_peer_ids = []
var local_player
@export var player_scene: PackedScene
var player_character_instance = preload("res://scenes/plr.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_pressed():
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	
func _add_player():
	var id = 1
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _on_join_pressed():
	peer.create_client("127.0.0.1",25565)
	multiplayer.multiplayer_peer = peer
	
		
