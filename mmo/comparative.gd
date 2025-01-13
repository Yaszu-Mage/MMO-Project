extends Node
func is_in_range(range : Array, value : float) -> bool:
	var output = false
	if value < range[0] or value > range[1]:
		output = false
	else:
		output = true
	return output
	
