require("utils")

-- song lists
-- erk : "Electronics Underground"
-- erk : "Elsewhere"
-- erk : "Mountains City"
-- mAZE : "6502 Fathoms"
-- willBe : "Coral Pillows"
-- nainain : "Sweet Mermaids"
-- aceman : "Of Lobsters and Men"
-- gligli "Underwater"
-- riddlemak "AI"

-- button index -> walkman function (play, stop, ...)
WALKMAN_PREV = 1
WALKMAN_PLAY = 2
WALKMAN_NEXT = 3
WALKMAN_MODE = 4

-- map the song title to the vertical position
-- in the songs titles textures
local songs_titles_idx = {
	nainain_minisub_music = 6,
	willbe_loops = 5,
	aceman_underwater = 7,
	erk_Elsewhere  = 3,
	ma2e_summer_trance = 4,
	erk_Mountains_City = 2,
	riddlemak_ia = 8,
	gligli_underwater = 0,
	erk_electronics_underground = 1,
}

local song_end_pause = hg.time_from_sec_f(0.5)

-- walkman button hover & clicks
function get_screen_position(camera, point, resolution)
	local cam = camera:GetCamera()
	local view_state = hg.ComputePerspectiveViewState(camera:GetTransform():GetWorld(), cam:GetFov(), cam:GetZNear(), cam:GetZFar(), hg.ComputeAspectRatioX(resolution.x, resolution.y))
	local flag, pos2d = hg.ProjectToScreenSpace(view_state.proj, view_state.view * point, resolution)
	if flag then
		return hg.Vec2(pos2d.x, pos2d.y)
	else
		return nil
	end
end

function hover_objects_test(objects_list, camera, resolution, mouse_position, object_radius, debug_draw_lines)
	local camera_pos = camera:GetTransform():GetPos()
	local cam_aY = hg.GetY(camera:GetTransform():GetWorld())
	local i, object
	for i, object in ipairs(objects_list) do
		local object_position = hg.GetT(object:GetTransform():GetWorld())
		local object_screen_position = get_screen_position(camera, object_position, resolution)
		if object_screen_position ~= nil then
			local object_bound_position = object_position + cam_aY * object_radius
			local object_bound_screen_position = get_screen_position(camera, object_bound_position, resolution)
			if object_bound_screen_position ~= nil then
				local object_screen_radius = hg.Len(object_bound_screen_position - object_screen_position)
				if hg.Len(mouse_position - object_screen_position) < object_screen_radius then
					return i, object, debug_draw_lines
				end
			end
		end
	end
	return -1, nil, debug_draw_lines
end

function get_hovered_button(scene, buttons, mouse_pos, resolution, lines)
	local idx, button_hover, lines = hover_objects_test(buttons, scene:GetCurrentCamera(), resolution, mouse_pos, 0.4, lines)
	if button_hover ~= nil then
		-- print("button " .. idx)
		return idx, lines
	end

	return -1, lines
end

function walkman_interaction_update(scene, mouse, res_vec2, dts, buttons, walkman_buttons_nodes, buttons_trs, walkman_button_on, walkman_button_hover, 
									walkman_button_change_state, walkman_button_pressed_timeout)
	-- walkman interactivity
	local walkman_button_hover_idx,_ = get_hovered_button(scene, walkman_buttons_nodes, hg.Vec2(mouse:X(), mouse:Y()), res_vec2)

	-- 	if mouse:Pressed(hg.MB_0) then -- not mouse:Pressed(hg.MB_0) and mouse:Released(hg.MB_0) then

	-- change button state (hover or pressed)
	if walkman_button_hover_idx > -1 then
		if mouse:Pressed(hg.MB_0) then -- not mouse:Pressed(hg.MB_0) and mouse:Released(hg.MB_0) then
			walkman_button_on = walkman_button_hover_idx
			walkman_button_hover = -1
			walkman_button_change_state = true
			walkman_button_pressed_timeout = hg.GetClock()
		else
			if walkman_button_hover_idx ~= walkman_button_on then
				walkman_button_hover = walkman_button_hover_idx
			end
		end
	else
		walkman_button_hover = -1
	end

	local button_idx, _pos

	-- move buttons according to their states
	for button_idx = 1, #buttons do
		_pos = buttons_trs[button_idx]:GetPos()
		local _y_target
		if button_idx == walkman_button_hover then
			_y_target = 1.85
		elseif button_idx == walkman_button_on then
			_y_target = 1.65
		else
			_y_target = 2.0
		end
		
		_pos = buttons_trs[button_idx]:GetPos()
		_pos.y = dtAwareDamp(_pos.y, _y_target, 0.005, dts)
		buttons_trs[button_idx]:SetPos(_pos)
	end

	return walkman_button_on, walkman_button_hover, walkman_button_change_state, walkman_button_pressed_timeout
end

function play_song(_player)
	if not(_player.song_ref == nil) then
		hg.StopSource(_player.song_ref)
	end
	_player.song_ref = hg.StreamOGGAssetStereo("audio\\" .. _player.titles[_player.current_song_idx] .. ".ogg", hg.StereoSourceState(1, hg.SR_Loop))
	_player.current_song_timestamp = hg.GetClock()
	print("song: " .. _player.titles[_player.current_song_idx])
	-- -- print(hg.GetSourceDuration(_player.song_ref))
	-- print(hg.time_to_sec_f(get_ogg_duration(_player.titles[_player.current_song_idx])))
end

function walkman_osd_update(scene, song_player, walkman_osd, config)
	local _clock = hg.GetClock()

	-- mode icon (repeat/next song)
	if song_player.repeat_mode then
		walkman_osd.icon_mode_repeat:Enable()
		walkman_osd.icon_mode_next:Disable()
	else
		walkman_osd.icon_mode_repeat:Disable()
		walkman_osd.icon_mode_next:Enable()
	end

	-- clock
	-- double dot blinking
	local _clock_s = hg.time_to_sec_f(_clock)
	if math.fmod(_clock_s, 2.0) < 1.0 then
		walkman_osd.double_dot:Enable()
	else
		walkman_osd.double_dot:Disable()
	end

	-- isolate minute/second
	local song_time = _clock - song_player.current_song_timestamp --elapsed time for the current song
	song_time = song_player.durations[song_player.current_song_idx] - song_time -- remaining time
	song_time = hg.time_to_sec_f(song_time) -- in seconds, float
	song_time = math.max(0.0, song_time)
	local time_min = math.floor(song_time / 60) -- extract the minutes
	local time_sec = math.floor(song_time - (time_min * 60)) -- extract the seconds

	-- isolate each digit
	local min_ten =  math.floor(time_min / 10)
	local min_unit = math.floor(time_min - (min_ten * 10))
	local sec_ten =  math.floor(time_sec / 10)
	local sec_unit = math.floor(time_sec - (sec_ten * 10))

	local new_clock_str = min_ten .. "," .. min_unit .. "," .. sec_ten .. "," .. sec_unit

	-- if the clock value has changed
	if not(walkman_osd.clock_str == new_clock_str) then
		-- send the values to the shader
		hg.SetMaterialValue(walkman_osd.digit_0, "uParam", hg.Vec4(min_ten, 10.0, 0.0, 0.0))
		hg.SetMaterialValue(walkman_osd.digit_1, "uParam", hg.Vec4(min_unit, 10.0, 0.0, 0.0))
		hg.SetMaterialValue(walkman_osd.digit_2, "uParam", hg.Vec4(sec_ten, 10.0, 0.0, 0.0))
		hg.SetMaterialValue(walkman_osd.digit_3, "uParam", hg.Vec4(sec_unit, 10.0, 0.0, 0.0))
		walkman_osd.clock_str = new_clock_str
	end

	-- led rail
	if walkman_osd.led_rail_timer == nil or (_clock - walkman_osd.led_rail_timer > hg.time_from_sec_f(0.5)) then
		walkman_osd.led_rail_timer = _clock
		walkman_osd.current_led = walkman_osd.current_led + 1
		if walkman_osd.current_led > 4 then
			walkman_osd.current_led = 0
		end
-- print(walkman_osd.current_led)`
		local darken_led_factor = 0.2
		if config.enable_aaa then
			darken_led_factor = 0.001
		end
		local i, led_key
		for i = 0, 4 do
			led_key = "dot_" .. i
			hg.SetMaterialValue(walkman_osd[led_key], "uSelfColor", hg.Vec4(20/255, 1.0, 0.0, 0.0) * darken_led_factor)
		end

		hg.SetMaterialValue(walkman_osd["dot_" .. walkman_osd.current_led], "uSelfColor", hg.Vec4(20/255, 1.0, 0.0, 0.0))
	end

	-- song title
	local _song_tex_idx = songs_titles_idx[song_player.titles[song_player.current_song_idx]]
	hg.SetMaterialValue(walkman_osd.songs_titles, "uParam", hg.Vec4(_song_tex_idx, #song_player.titles, 0.0, 0.0))

	return walkman_osd
end

-- song player
function song_player_update(song_player, walkman_osd, walkman_button_change_state, walkman_button_on, prev_song_idx, walkman_button_pressed_timeout, config)
	local prev_song_idx = song_player.current_song_idx
	local _clock = hg.GetClock()

	-- buttons were pressed
	if walkman_button_change_state == true then
		-- local prev_song_idx = song_player.current_song_idx
		if walkman_button_on == WALKMAN_NEXT then
			song_player.current_song_idx = song_player.current_song_idx + 1
		elseif walkman_button_on == WALKMAN_PREV then
			song_player.current_song_idx = song_player.current_song_idx - 1
		elseif walkman_button_on == WALKMAN_MODE then
			song_player.repeat_mode = not song_player.repeat_mode
		end

		walkman_button_change_state = false
	else
		-- monitor song length
		if _clock - song_player.current_song_timestamp > song_player.durations[song_player.current_song_idx] + song_end_pause then
			if song_player.repeat_mode then
				prev_song_idx = -1 -- replay the same song again
			else
				song_player.current_song_idx = song_player.current_song_idx + 1 -- next song
			end
		end
	end

	-- wrap around the music index
	if song_player.current_song_idx > #song_player.titles then
		song_player.current_song_idx = 1
	elseif song_player.current_song_idx < 1 then
			song_player.current_song_idx = #song_player.titles
	end

	-- autopress PLAY if PREV/NEXT where pressed
	if _clock - walkman_button_pressed_timeout > hg.time_from_sec_f(1.0) then
		if walkman_button_on == WALKMAN_NEXT or walkman_button_on == WALKMAN_PREV then
			walkman_button_on = WALKMAN_PLAY
		elseif walkman_button_on == WALKMAN_MODE then
			walkman_button_on = WALKMAN_PLAY
		end
	end

	-- if the song has changed
	if not(prev_song_idx == song_player.current_song_idx) then
		play_song(song_player)
	end

	-- update the walkman display
	walkman_osd = walkman_osd_update(scene, song_player, walkman_osd, config)
	
	return song_player, walkman_osd, walkman_button_change_state, walkman_button_on
end
