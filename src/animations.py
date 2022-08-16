import harfang as hg

def anim_player(scene, anims, anim_has_started, playing_anim, current_anim):
	if anim_has_started == False:
		#  if keyboard:Down(hg.K_F9):
			anim_has_started = True
		# #  end
	else:
		if playing_anim is None or scene.IsPlaying(playing_anim) == False:
			current_anim = current_anim + 1
			if current_anim >= len(anims):
				current_anim = 0
			# end
			playing_anim = scene.PlayAnim(scene.GetSceneAnim(anims[current_anim]))
	# 	end
	# end

	return anim_has_started, playing_anim, current_anim
# end


def start_event(scene, node_name, event_table):
	if event_table[node_name] == None:
		node = scene.GetNode(node_name)
		anim = node.GetInstanceSceneAnim("fadein")
		anim_ref = scene.PlayAnim(anim, hg.ALM_Once)
		event_table[node_name] = {"node": node, "anim": anim_ref, "clock": hg.GetClock(), "state": "fadein"} 
	# end
	return event_table
# end

def update_events(scene, event_table):
	_clock = hg.GetClock()

	for key in event_table: #  for i = 1, #event_table do
		if event_table[key].state == "fadein":
			if _clock - event_table[key].clock > hg.time_from_sec_f(5.0):
				#  scene.StopAnim(event_table[key].anim_ref)
				anim = event_table[key].node.GetInstanceSceneAnim("fadeout")
				anim_ref = scene.PlayAnim(anim, hg.ALM_Once)
				event_table[key].clock = hg.GetClock()
				event_table[key].state = "fadeout"
			# end
		elif event_table[key].state == "fadeout":
			# 
			if _clock - event_table[key].clock > hg.time_from_sec_f(5.0):
				event_table[key] = None
	# 		end
	# 	end
	# end

	return event_table
# end