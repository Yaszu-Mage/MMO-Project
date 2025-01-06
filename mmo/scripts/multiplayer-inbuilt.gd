extends Control
var multiplayer_peer = ENetMultiplayerPeer.new()
const port = 9999
var address = "localhost"
var connected_peer_ids = []
var local_player
var player_character_instance = preload("res://scenes/plr.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_pressed():
	self.visible = false
	multiplayer_peer.create_server(port,40)
	multiplayer.multiplayer_peer = multiplayer_peer
	add_player_character(1)
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			rpc("add_newly_connected_player_character", new_peer_id)
			rpc_id(new_peer_id,"add_previously_connected_player_characters",connected_peer_ids)
			add_player_character(new_peer_id)
	)
	


func _on_join_pressed():
	self.visible = false
	multiplayer_peer.create_client(address,port)
	multiplayer.multiplayer_peer = multiplayer_peer

func add_player_character(peer_id):
	connected_peer_ids.append(peer_id)
	var instance = player_character_instance.instantiate()
	instance.set_multiplayer_authority(peer_id)
	get_parent().add_child(instance)
	if peer_id == multiplayer.get_unique_id():
		local_player = instance
		local_player.camera = true
		
		
@rpc
func add_newly_connected_player_character(new_peer_id):
	add_player_character(new_peer_id)

@rpc
func add_previously_connected_player_characters(peer_ids):
	for peer_id in peer_ids:
		add_player_character(peer_id)
