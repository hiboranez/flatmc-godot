extends Node

var bgm_audio_player = AudioStreamPlayer.new()

var music_dict: Dictionary
var sound_dict: Dictionary
var random_audio_type_dict: Dictionary
var random_audio_list_dict: Dictionary

var bgm_volume: float = 1
var sound_volume: float = 1

func _ready() -> void:
	add_child(bgm_audio_player)

func get_resource_amount() -> int:
	var amount: int = 0
	var music_type_list = DirAccess.get_directories_at("res://assets/audios/music")
	for music_type in music_type_list:
		var music_name_list = DirAccess.get_files_at("res://assets/audios/music/"+music_type)
		for music_file_name in music_name_list:
			if OS.is_debug_build() and music_file_name.contains(".import"):
				continue
			amount += 1
	
	var sound_type_list = DirAccess.get_directories_at("res://assets/audios/sound")
	for sound_type in sound_type_list:
		var sound_name_list = DirAccess.get_files_at("res://assets/audios/sound/"+sound_type)
		for sound_file_name in sound_name_list:
			if OS.is_debug_build() and sound_file_name.contains(".import"):
				continue
			amount += 1
	return amount

func update_resource() -> void:
	random_audio_type_dict = ResourceManager.load_json_file("res://assets/data/random_audios.json", {})
	for type in random_audio_type_dict.keys():
		random_audio_list_dict[type] = {}
	var music_type_list = []
	var music_dir = DirAccess.open("res://assets/audios/music")
	if music_dir:
		music_type_list = music_dir.get_directories()
	for music_type in music_type_list:
		var music_dict_tmp = {}
		var music_name_list = []
		var music_sub_dir = DirAccess.open("res://assets/audios/music/"+music_type)
		if music_sub_dir:
			music_name_list = music_sub_dir.get_files()
		for music_file_name in music_name_list:
			if OS.is_debug_build() and music_file_name.contains(".import"):
				continue
			music_file_name = music_file_name.replace(".import", "")
			var splits = music_file_name.split(".")
			var music_name = splits[0]
			ResourceLoadingMenu.call_deferred("set_loading_info", "res://assets/audios/music/"+music_type+"/"+music_file_name)
			music_dict_tmp[music_name] = load("res://assets/audios/music/"+music_type+"/"+music_file_name) as AudioStream
			if random_audio_type_dict["music"].has(music_type):
				for public_name in random_audio_type_dict["sound"][music_type]:
					if music_name.contains(public_name):
						if not random_audio_list_dict["music"].has(music_type):
							random_audio_list_dict["music"][music_type] = {}
						if not random_audio_list_dict["music"][music_type].has(public_name):
							random_audio_list_dict["music"][music_type][public_name] = [music_dict_tmp[music_name]]
						elif random_audio_list_dict["music"][music_type][public_name] is Array:
							random_audio_list_dict["music"][music_type][public_name].append(music_dict_tmp[music_name])
			ResourceLoadingMenu.call_deferred("add_loaded_amount")
		music_dict[music_type.to_lower()] = music_dict_tmp
	var sound_type_list = []
	var sound_dir = DirAccess.open("res://assets/audios/sound")
	if sound_dir:
		sound_type_list = sound_dir.get_directories()
	for sound_type in sound_type_list:
		var sound_dict_tmp = {}
		var sound_name_list = []
		var sound_sub_dir = DirAccess.open("res://assets/audios/sound/"+sound_type)
		if sound_sub_dir:
			sound_name_list = sound_sub_dir.get_files()
		for sound_file_name in sound_name_list:
			if OS.is_debug_build() and sound_file_name.contains(".import"):
				continue
			sound_file_name = sound_file_name.replace(".import", "")
			var splits = sound_file_name.split(".")
			var sound_name = splits[0]
			ResourceLoadingMenu.call_deferred("set_loading_info", "res://assets/audios/sound/"+sound_type+"/"+sound_file_name)
			sound_dict_tmp[sound_name] = load("res://assets/audios/sound/"+sound_type+"/"+sound_file_name) as AudioStream
			if random_audio_type_dict["sound"].has(sound_type):
				for public_name in random_audio_type_dict["sound"][sound_type]:
					if sound_name.contains(public_name):
						if not random_audio_list_dict["sound"].has(sound_type):
							random_audio_list_dict["sound"][sound_type] = {}
						if not random_audio_list_dict["sound"][sound_type].has(public_name):
							random_audio_list_dict["sound"][sound_type][public_name] = [sound_dict_tmp[sound_name]]
						elif random_audio_list_dict["sound"][sound_type][public_name] is Array:
							random_audio_list_dict["sound"][sound_type][public_name].append(sound_dict_tmp[sound_name])
			ResourceLoadingMenu.call_deferred("add_loaded_amount")
		sound_dict[sound_type.to_lower()] = sound_dict_tmp

func stop_bgm():
	if bgm_audio_player.playing:
		bgm_audio_player.stop()

func refresh_bgm():
	stop_bgm()
	play_random_bgm()

func play_random_bgm() -> void:
	var bgm_list = music_dict["classic_game"]
	if StaticLoad.is_in_game:
		if SettingsManager.get_current_setting("new_music") == "on":
			var new_game_music_list = music_dict["classic_game"].values()
			new_game_music_list.append_array(music_dict["new_game_menu"].values())
			bgm_list = new_game_music_list
		else:
			bgm_list = music_dict["classic_game"].values()
	else:
		if SettingsManager.get_current_setting("new_music") == "on":
			var new_game_music_list = music_dict["classic_menu"].values()
			new_game_music_list.append_array(music_dict["new_game_menu"].values())
			bgm_list = new_game_music_list
		else:
			bgm_list = music_dict["classic_menu"].values()
	if bgm_list.is_empty():
		return
	bgm_audio_player.stream = bgm_list[randi() % bgm_list.size()]
	bgm_audio_player.play()

func play_static_audio(path):
	if sound_volume == 0:
		return
	var audio_player = AudioStreamPlayer.new()
	var audio_dict = null
	var splits = path.split("/")
	if splits[0] == "music":
		audio_dict = music_dict
	elif splits[0] == "sound":
		audio_dict = sound_dict
	if audio_dict == null:
		return
	audio_player.volume_db = linear_to_db(sound_volume)
	audio_player.stream = audio_dict[splits[1]][splits[2]]
	audio_player.connect("finished", _on_audio_finished.bind(audio_player))
	add_child(audio_player)
	audio_player.play()

func play_random_audio_at_position(path: String, sound_position: Vector2, pitch_scale: float) -> void:
	if sound_volume == 0:
		return
	var splits = path.split("/")
	if splits.size() < 3:
		return
	var is_random = false
	if random_audio_list_dict.has(splits[0]):
		if random_audio_list_dict[splits[0]].has(splits[1]):
			if random_audio_list_dict[splits[0]][splits[1]].has(splits[2]):
				is_random = true
	if not is_random:
		play_audio_at_position(path, sound_position, pitch_scale)
		return
	var audio_player = AudioStreamPlayer2D.new()
	var sound_list = random_audio_list_dict[splits[0]][splits[1]][splits[2]]
	if not (sound_list is Array and not sound_list.is_empty()):
		return
	var sound = sound_list[randi() % sound_list.size()]
	audio_player.pitch_scale = pitch_scale
	audio_player.stream = sound
	audio_player.position = sound_position
	audio_player.panning_strength = 3
	audio_player.volume_db = linear_to_db(sound_volume)
	audio_player.connect("finished", _on_audio_finished.bind(audio_player))
	add_child(audio_player)
	audio_player.play()

func play_audio_at_position(path: String ,sound_position: Vector2, pitch_scale: float) -> void:
	if sound_volume == 0:
		return
	var audio_player = AudioStreamPlayer2D.new()
	var audio_dict = null
	var splits = path.split("/")
	if splits[0] == "music":
		audio_dict = music_dict
	elif splits[0] == "sound":
		audio_dict = sound_dict
	if audio_dict == null:
		return	
	audio_player.pitch_scale = pitch_scale
	audio_player.stream = audio_dict[splits[1]][splits[2]]
	audio_player.position = sound_position
	audio_player.panning_strength = 3
	audio_player.volume_db = linear_to_db(sound_volume)
	audio_player.connect("finished", _on_audio_finished.bind(audio_player))
	add_child(audio_player)
	audio_player.play()

func set_bgm_volume(got_volume) -> void:
	if got_volume == 0 and bgm_audio_player.playing:
		stop_bgm()
	elif got_volume > 0 and not bgm_audio_player.playing:
		play_random_bgm()
	bgm_audio_player.volume_db = linear_to_db(got_volume)
	bgm_volume = got_volume

func set_sound_volume(got_volume) -> void:
	sound_volume = got_volume

func _on_bgm_audio_player_finished() -> void:
	play_random_bgm()

func _on_audio_finished(audio_player) -> void:
	audio_player.queue_free()
