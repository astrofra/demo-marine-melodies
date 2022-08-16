from utils import *

# song lists
# erk : "Electronics Underground"
# erk : "Elsewhere"
# erk : "Mountains City"
# mAZE : "6502 Fathoms"
# willBe : "Coral Pillows"
# nainain : "Sweet Mermaids"
# aceman : "Of Lobsters and Men"
# gligli "Underwater"
# riddlemak "AI"

# button index -> walkman def (play, stop, ...)
WALKMAN_PREV = 0
WALKMAN_PLAY = 1
WALKMAN_NEXT = 2
WALKMAN_MODE = 3

# map the song title to the vertical position
# in the songs titles textures
songs_titles_idx = {
	"nainain_minisub_music": 6,
	"willbe_loops": 5,
	"aceman_underwater": 7,
	"erk_Elsewhere": 3,
	"ma2e_summer_trance": 4,
	"erk_Mountains_City": 2,
	"riddlemak_ia": 8,
	"gligli_underwater": 0,
	"erk_electronics_underground": 1,
}

song_end_pause = hg.time_from_sec_f(0.5)

# walkman button hover & clicks
def get_screen_position(camera, point, resolution):
	cam = camera.GetCamera()
	view_state = hg.ComputePerspectiveViewState(camera.GetTransform().GetWorld(), cam.GetFov(), cam.GetZNear(), cam.GetZFar(), hg.ComputeAspectRatioX(resolution.x, resolution.y))
	flag, pos2d = hg.ProjectToScreenSpace(view_state.proj, view_state.view * point, resolution)
	if flag:
		return hg.Vec2(pos2d.x, pos2d.y)
	else:
		return None
	# end
# end

def hover_objects_test(objects_list, camera, resolution, mouse_position, object_radius, debug_draw_lines):
	camera_pos = camera.GetTransform().GetPos()
	cam_aY = hg.GetY(camera.GetTransform().GetWorld())
	# i, object
	for i, object in enumerate(objects_list):
		object_position = hg.GetT(object.GetTransform().GetWorld())
		object_screen_position = get_screen_position(camera, object_position, resolution)
		if object_screen_position is not None:
			object_bound_position = object_position + cam_aY * object_radius
			object_bound_screen_position = get_screen_position(camera, object_bound_position, resolution)
			if object_bound_screen_position is not None:
				object_screen_radius = hg.Len(object_bound_screen_position - object_screen_position)
				if hg.Len(mouse_position - object_screen_position) < object_screen_radius:
					return i, object, debug_draw_lines
				# end
			# end
		# end
	# end
	return -1, None, debug_draw_lines
# end

def get_hovered_button(scene, buttons, mouse_pos, resolution, lines=[]):
	idx, button_hover, lines = hover_objects_test(buttons, scene.GetCurrentCamera(), resolution, mouse_pos, 0.4, lines)
	if button_hover is not None:
		# print("button " + str(idx))
		return idx, lines
	# end

	return -1, lines
# end

def walkman_interaction_update(scene, mouse, res_vec2, dts, buttons, walkman_buttons_nodes, buttons_trs, walkman_button_on, walkman_button_hover, 
									walkman_button_change_state, walkman_button_pressed_timeout):
	# walkman interactivity
	walkman_button_hover_idx,_ = get_hovered_button(scene, walkman_buttons_nodes, hg.Vec2(mouse.X(), mouse.Y()), res_vec2)

	# 	if mouse.Pressed(hg.MB_0) then # not mouse.Pressed(hg.MB_0) and mouse.Released(hg.MB_0) then

	# change button state (hover or pressed)
	if walkman_button_hover_idx > -1:
		if mouse.Pressed(hg.MB_0): # not mouse.Pressed(hg.MB_0) and mouse.Released(hg.MB_0) then
			walkman_button_on = walkman_button_hover_idx
			walkman_button_hover = -1
			walkman_button_change_state = True
			walkman_button_pressed_timeout = hg.GetClock()
		else:
			if walkman_button_hover_idx != walkman_button_on:
				walkman_button_hover = walkman_button_hover_idx
			# end
		# end
	else:
		walkman_button_hover = -1
	# end

	# button_idx, _pos

	# move buttons according to their states
	for button_idx in range(len(buttons)):
		_pos = buttons_trs[button_idx].GetPos()
		# _y_target
		if button_idx == walkman_button_hover:
			_y_target = 1.85
		elif button_idx == walkman_button_on:
			_y_target = 1.65
		else:
			_y_target = 2.0
		# end
		
		_pos = buttons_trs[button_idx].GetPos()
		_pos.y = dtAwareDamp(_pos.y, _y_target, 0.005, dts)
		buttons_trs[button_idx].SetPos(_pos)
	# end

	return walkman_button_on, walkman_button_hover, walkman_button_change_state, walkman_button_pressed_timeout
# end

def play_song(_player):
	if not(_player["song_ref"] == None):
		hg.StopSource(_player["song_ref"])
	# end
	_player["song_ref"] = hg.StreamOGGAssetStereo("audio\\" + _player["titles"][_player["current_song_idx"]] + ".ogg", hg.StereoSourceState(1, hg.SR_Loop))
	_player["current_song_timestamp"] = hg.GetClock()
	print("song: " + _player["titles"][_player["current_song_idx"]])
	# # print(hg.GetSourceDuration(_player["song_ref"]))
	# print(hg.time_to_sec_f(get_ogg_duration(_player["titles"][_player["current_song_idx"]])))
# end

def walkman_osd_update(song_player, walkman_osd, config):
	_clock = hg.GetClock()

	# mode icon (repeat/next song)
	if song_player["repeat_mode"]:
		walkman_osd["icon_mode_repeat"].Enable()
		walkman_osd["icon_mode_next"].Disable()
	else:
		walkman_osd["icon_mode_repeat"].Disable()
		walkman_osd["icon_mode_next"].Enable()
	# end

	# clock
	# double dot blinking
	_clock_s = hg.time_to_sec_f(_clock)
	if _clock_s%2.0 < 1.0:
		walkman_osd["double_dot"].Enable()
	else:
		walkman_osd["double_dot"].Disable()
	# end

	# isolate minute/second
	song_time = _clock - song_player["current_song_timestamp"] # elapsed time for the current song
	song_time = song_player["durations"][song_player["current_song_idx"]] - song_time # remaining time
	song_time = hg.time_to_sec_f(song_time) # in seconds, float
	song_time = max(0.0, song_time)
	time_min = int(song_time / 60) # extract the minutes
	time_sec = int(song_time - (time_min * 60)) # extract the seconds

	# isolate each digit
	min_ten =  int(time_min / 10)
	min_unit = int(time_min - (min_ten * 10))
	sec_ten =  int(time_sec / 10)
	sec_unit = int(time_sec - (sec_ten * 10))

	new_clock_str = str(min_ten) + "," + str(min_unit) + "," + str(sec_ten) + "," + str(sec_unit)

	# if the clock value has changed
	if walkman_osd["clock_str"] != new_clock_str:
		# send the values to the shader
		hg.SetMaterialValue(walkman_osd["digit_0"], "uParam", hg.Vec4(min_ten, 10.0, 0.0, 0.0))
		hg.SetMaterialValue(walkman_osd["digit_1"], "uParam", hg.Vec4(min_unit, 10.0, 0.0, 0.0))
		hg.SetMaterialValue(walkman_osd["digit_2"], "uParam", hg.Vec4(sec_ten, 10.0, 0.0, 0.0))
		hg.SetMaterialValue(walkman_osd["digit_3"], "uParam", hg.Vec4(sec_unit, 10.0, 0.0, 0.0))
		walkman_osd["clock_str"] = new_clock_str
	# end

	# led rail
	if walkman_osd["led_rail_timer"] == None or (_clock - walkman_osd["led_rail_timer"] > hg.time_from_sec_f(0.5)):
		walkman_osd["led_rail_timer"] = _clock
		walkman_osd["current_led"] = walkman_osd["current_led"] + 1
		if walkman_osd["current_led"] > 4:
			walkman_osd["current_led"] = 0
		# end
# print(walkman_osd["current_led"])`
		darken_led_factor = 0.2
		if config["enable_aaa"]:
			darken_led_factor = 0.001
		# end
		# i, led_key
		for i in range(4):
			led_key = "dot_" + str(i)
			hg.SetMaterialValue(walkman_osd[led_key], "uSelfColor", hg.Vec4(20/255, 1.0, 0.0, 0.0) * darken_led_factor)
		# end

		hg.SetMaterialValue(walkman_osd["dot_" + str(walkman_osd["current_led"])], "uSelfColor", hg.Vec4(20/255, 1.0, 0.0, 0.0))
	# end

	# song title
	_song_tex_idx = songs_titles_idx[song_player["titles"][song_player["current_song_idx"]]]
	hg.SetMaterialValue(walkman_osd["songs_titles"], "uParam", hg.Vec4(_song_tex_idx, len(song_player["titles"]), 0.0, 0.0))

	return walkman_osd
# end

# song player
def song_player_update(song_player, walkman_osd, walkman_button_change_state, walkman_button_on, prev_song_idx, walkman_button_pressed_timeout, config):
	prev_song_idx = song_player["current_song_idx"]
	_clock = hg.GetClock()

	# buttons were pressed
	if walkman_button_change_state == True:
		# prev_song_idx = song_player["current_song_idx"]
		if walkman_button_on == WALKMAN_NEXT:
			song_player["current_song_idx"] = song_player["current_song_idx"] + 1
		elif walkman_button_on == WALKMAN_PREV:
			song_player["current_song_idx"] = song_player["current_song_idx"] - 1
		elif walkman_button_on == WALKMAN_MODE:
			song_player["repeat_mode"] = not song_player["repeat_mode"]
		# end

		walkman_button_change_state = False
	else:
		# monitor song length
		if _clock - song_player["current_song_timestamp"] > song_player["durations"][song_player["current_song_idx"]] + song_end_pause:
			if song_player["repeat_mode"]:
				prev_song_idx = -1 # replay the same song again
			else:
				song_player["current_song_idx"] = song_player["current_song_idx"] + 1 # next song
			# end
		# end
	# end

	# wrap around the music index
	if song_player["current_song_idx"] > len(song_player["titles"]) - 1:
		song_player["current_song_idx"] = 0
	elif song_player["current_song_idx"] < 0:
			song_player["current_song_idx"] = len(song_player["titles"]) - 1
	# end

	# autopress PLAY if PREV/NEXT where pressed
	if _clock - walkman_button_pressed_timeout > hg.time_from_sec_f(1.0):
		if walkman_button_on == WALKMAN_NEXT or walkman_button_on == WALKMAN_PREV:
			walkman_button_on = WALKMAN_PLAY
		elif walkman_button_on == WALKMAN_MODE:
			walkman_button_on = WALKMAN_PLAY
		# end
	# end

	# if the song has changed
	if not(prev_song_idx == song_player["current_song_idx"]):
		play_song(song_player)
	# end

	# update the walkman display
	walkman_osd = walkman_osd_update(song_player, walkman_osd, config)
	
	return song_player, walkman_osd, walkman_button_change_state, walkman_button_on
# end
