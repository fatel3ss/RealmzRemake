var has_on_time_pass : bool = false

func _on_time_pass(s : int) :
	print("campaign_global_script noticed "+String(s)+" seconds passed")

func get_string_to_save() -> String :
	var dict_to_save : Dictionary = {}
	return  JSON.print(dict_to_save)