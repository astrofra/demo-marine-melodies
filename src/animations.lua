function anim_player(scene, anims, anim_has_started, playing_anim, current_anim)
	if anim_has_started == false then
		-- if keyboard:Down(hg.K_F9) then
			anim_has_started = true
		-- end
	else
		if playing_anim == 0 or scene:IsPlaying(playing_anim) == false then
			current_anim = current_anim + 1
			if current_anim > #anims then
				current_anim = 1
			end
			playing_anim = scene:PlayAnim(scene:GetSceneAnim(anims[current_anim]))
		end
	end

	return anim_has_started, playing_anim, current_anim
end

function start_event(scene, node_name, event_table)
	if event_table[node_name] == nil then
		local node = scene:GetNode(node_name)
		local anim = node:GetInstanceSceneAnim("fadein")
		local anim_ref = scene:PlayAnim(anim, hg.ALM_Once)
		event_table[node_name] = {node = node, anim = anim_ref, clock = hg.GetClock(), state = "fadein"} 
	end
	return event_table
end

function update_events(scene, event_table)
	local _clock = hg.GetClock()

	for key, value in pairs(event_table) do -- for i = 1, #event_table do
		if event_table[key].state == "fadein" then
			if _clock - event_table[key].clock > hg.time_from_sec_f(5.0) then
				-- scene:StopAnim(event_table[key].anim_ref)
				local anim = event_table[key].node:GetInstanceSceneAnim("fadeout")
				local anim_ref = scene:PlayAnim(anim, hg.ALM_Once)
				event_table[key].clock = hg.GetClock()
				event_table[key].state = "fadeout"
			end
		elseif event_table[key].state == "fadeout" then
			--
			if _clock - event_table[key].clock > hg.time_from_sec_f(5.0) then
				event_table[key] = nil
			end
		end
	end

	return event_table
end