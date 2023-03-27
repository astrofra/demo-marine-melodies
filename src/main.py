import harfang as hg
from utils import *
from scrolltext import *
from particles import *
from boids import *
from bubbles import *
from animations import *
from walkman import *
from config_gui import *
from songs_data import songs_data
from math import pi, sin

# credits
# concept & graphics : fra
# music : Erk, Nainain, GliGli, Aceman, mAZE, Riddlemak, WillBe
# code : fra, erk
# 3D engine : xbarr, mooz, scorpheus, kipixelle


def draw_line(pos_a, pos_b, line_color, vid, vtx_line_layout, line_shader):
	vtx = hg.Vertices(vtx_line_layout, 2)
	vtx.Begin(0).SetPos(pos_a).SetColor0(line_color).End()
	vtx.Begin(1).SetPos(pos_b).SetColor0(line_color).End()
	hg.DrawLines(vid, vtx, line_shader)


def main():
	# {}
	config = {"enable_aaa":True, "low_aaa":False, "skip_intro":True}

	# hg.SetLogLevel(hg.LL_Normal)

	hg.InputInit()
	hg.AudioInit()
	hg.WindowSystemInit()

	hg.AddAssetsFolder("assetsc")

	# resolution selection ########################################
	# win
	# config_done
	# default_res_x
	# default_res_y
	# default_fullscreen
	# full_aaa
	# low_aaa
	# no_aa

	hg.ShowCursor()
	# config_done, default_res_x, default_res_y, default_fullscreen, full_aaa, low_aaa, no_aaa = config_gui()
	config_done = 1
	default_res_x = 720
	default_res_y = 576
	default_fullscreen = hg.WV_Undecorated
	full_aaa = True
	low_aaa = no_aaa = False
	widescreen = False

	# set config
	res_x, res_y = default_res_x, default_res_y

	if no_aaa:
		config["enable_aaa"] = False 
	else:
		config["enable_aaa"] = True
		if low_aaa:
			config["low_aaa"] = True
		else:
			config["low_aaa"] = False
		# end
	# end

	if config_done == 1: 
		# Demo start
		# res_x, res_y = resolution_multiplier(res_x, res_x, 0.8)
		res_vec2 = hg.Vec2(res_x, res_y)
		font_size = int((40 * res_x) / 1280)

		# win = hg.RenderInit('Minisub Escape', res_x, res_y, hg.RF_VSync | hg.RF_MSAA4X)
		win = hg.NewWindow("Marine Melodies^Resistance(2022)", res_x, res_y, 32, default_fullscreen) #, hg.WV_Fullscreen)
		hg.RenderInit(win)
		hg.RenderReset(res_x, res_y, hg.RF_MSAA4X | hg.RF_MaxAnisotropy)
		# hg.SetWindowPos(win, hg.iVec2(-720,0))

		# create pipeline
		pipeline = hg.CreateForwardPipeline()
		res = hg.PipelineResources()

		# INTRO
		scene_intro = hg.Scene()
		hg.LoadSceneFromAssets("logo_rse/logo_rse.scn", scene_intro, res, hg.GetForwardPipelineInfo())

		cam_intro = scene_intro.GetNode("Camera")
		scene_intro.SetCurrentCamera(cam_intro)

		# DEMO
		# load the scene to draw to a texture
		scene = hg.Scene()
		if widescreen:
			hg.LoadSceneFromAssets("main_scenery.scn", scene, res, hg.GetForwardPipelineInfo())
		else:
			hg.LoadSceneFromAssets("main_scenery_4-3.scn", scene, res, hg.GetForwardPipelineInfo())

		intro_anims = ["begin", "fadein", "fadeout", "title_fadein", "title_fadeout", "# end"]
		intro_current_anim = 0
		intro_playing_anim = None
		intro_anim_has_started = False

		# physics
		physics = hg.SceneBullet3Physics()
		physics.SceneCreatePhysicsFromAssets(scene)

		scene_clocks = hg.SceneClocks()

		# specific scene to render the bubbles
		bubble_scene = hg.Scene()

		# create a frame buffer to draw the scene to
		color = hg.CreateTexture(res_x, res_y, "color texture", hg.TF_RenderTarget, hg.TF_RGBA8)
		depth =  hg.CreateTexture(res_x, res_y, "depth texture", hg.TF_RenderTarget, hg.TF_D32F)
		frame_buffer = hg.CreateFrameBuffer(color, depth, "framebuffer")

		bubble_color = hg.CreateTexture(res_x, res_y, "color texture", hg.TF_RenderTarget, hg.TF_RGBA8)
		bubble_depth =  hg.CreateTexture(res_x, res_y, "depth texture", hg.TF_RenderTarget, hg.TF_D32F)
		bubble_frame_buffer = hg.CreateFrameBuffer(bubble_color, bubble_depth, "bubble_framebuffer")

		# create a plane model for the final rendering stage
		vtx_layout = hg.VertexLayoutPosFloatNormUInt8TexCoord0UInt8()

		screen_mdl = hg.CreatePlaneModel(vtx_layout, 1, res_y / res_x, 1, 1)
		screen_ref = res.AddModel('screen', screen_mdl)

		# create a plane model for the dirt particles
		vtx_layout = hg.VertexLayoutPosFloatNormUInt8TexCoord0UInt8()

		particle_intro_mdl = build_random_particles_model(hg.ModelBuilder(), vtx_layout, 3, 25.0)

		# particle_dirt_mdl = hg.CreatePlaneModel(vtx_layout, 1, 1, 1, 1) # generic quad
		particle_dirt_mdl = build_random_particles_model(hg.ModelBuilder(), vtx_layout, 5, 15.0)

		particle_dirt_ref = res.AddModel('dirt_particle', particle_dirt_mdl)
		particle_dirt_render_state = hg.ComputeRenderState(hg.BM_Alpha, hg.DT_Less, hg.FC_Disabled, False)

		# prepare the plane shader program
		screen_prg = hg.LoadProgramFromAssets('shaders/compositer')

		# shader to draw some 3D lines
		vtx_line_layout = hg.VertexLayoutPosFloatColorUInt8()
		shader_for_line = hg.LoadProgramFromAssets("shaders/pos_rgb")
		shader_for_particle = hg.LoadProgramFromAssets("shaders/dirt_particle")
		dirt_particle_texture,_ = hg.LoadTextureFromAssets("maps/dirt_particle.png", 
										hg.TF_UBorder | hg.TF_VBorder | hg.TF_SamplerMinAnisotropic | hg.TF_SamplerMagAnisotropic)

		# text rendering
		# load font and shader program
		font = hg.LoadFontFromAssets('fonts/Hogfish.otf', font_size)
		font_program  = hg.LoadProgramFromAssets('core/shader/font')

		# text uniforms and render state
		text_uniform_values = [hg.MakeUniformSetValue('u_color', hg.Vec4(1, 1, 0, 1))]
		text_render_state = hg.ComputeRenderState(hg.BM_Alpha, hg.DT_Always, hg.FC_Disabled)

		# Set render camera
		cam = scene.GetNode("Camera")
		scene.SetCurrentCamera(cam)
		z_near = cam.GetCamera().GetZNear()
		z_far = cam.GetCamera().GetZFar()
		fov = cam.GetCamera().GetFov()

		bubble_cam = hg.CreateCamera(bubble_scene, cam.GetTransform().GetWorld(), z_near, z_far, fov)
		bubble_scene.SetCurrentCamera(bubble_cam)

		# intro particles init
		intro_particles = []
		_max_particles = 100
		for i in range(_max_particles):
			particle_alpha = i / _max_particles # more and more opaque (only the spatial distribution is randomized)
			particle_age = hg.time_from_sec_f((i / _max_particles) * pi * 2.0)
			intro_particles.append({"pos":hg.Vec3(lua_rand(-40, 40), lua_rand(-20, 20), lua_rand(100, 200)),
											"rot":hg.Vec3(0.0, 0.0, lua_rand() * pi * 2.0),
											"alpha":particle_alpha, "age":particle_age})
		# end

		# dirt particles init
		dirt_particles = []
		_max_particles = 150
		for i in range(_max_particles):
			particle_alpha = i / _max_particles  # more and more opaque (only the spatial distribution is randomized)
			particle_age = hg.time_from_sec_f((i / _max_particles) * pi * 2.0)
			dirt_particles.append({"pos":hg.Vec3(lua_rand(-30, 30), lua_rand(0, 20), lua_rand(-20, 100)),
											"rot":hg.Vec3(0.0, 0.0, lua_rand() * pi * 2.0),
											"alpha":particle_alpha, "age":particle_age})
		# end

		# bubbles init
		bubble_particles = {"emitter":{"spawn_timeout":hg.time_from_sec_f(0.0)}, "particles":[]}
		blank_bubble,_ = hg.CreateInstanceFromAssets(bubble_scene, hg.TranslationMat4(hg.Vec3(0,0,0)), "bubble.scn", res, hg.GetForwardPipelineInfo()) # , hg.LSSF_Nodes | hg.LSSF_Scene | hg.LSSF_DoNotChangeCurrentCameraIfValid)
		blank_bubble.Disable()

		# fish boids init
		fish_boids = []
		boids_min_max = hg.MinMax(hg.Vec3(-20, -5, -5), hg.Vec3(20, 25, 50))
		for i in range(25):
			fish_boids.append({"pos":hg.Vec3(lua_rand(boids_min_max.mn.x, boids_min_max.mx.x) * 0.1, 
									lua_rand(boids_min_max.mn.y, boids_min_max.mx.y) * 0.1, 
									lua_rand(boids_min_max.mn.z, boids_min_max.mx.z) * 0.1), 
									"dir":hg.Vec3(lua_rand(-100, 100)/200.0, lua_rand(-100, 100)/200.0, lua_rand(-100, 100)/200.0),
									"target_dir":hg.Vec3(lua_rand(-100, 100)/200.0, lua_rand(-100, 100)/200.0, lua_rand(-100, 100)/200.0),
									"age":hg.time_from_sec_f(0.0), "node":None, "transform":None})
		# end

		# load models for the fish
		for i in range(len(fish_boids)):
			fish_boids[i]["node"],_ = hg.CreateInstanceFromAssets(scene, hg.TranslationMat4(hg.Vec3(0,0,0)), "Cartoon_Fish/fish_0.scn", res, hg.GetForwardPipelineInfo())
			fish_boids[i]["transform"] = fish_boids[i]["node"].GetTransform()
		# end

		# main loop
		angle = 0
		frame = 0
		clock = hg.time_from_sec_f(0.0)

		anims = ["subanim0", "subanim1", "subanim2", "subanim3", "subanim4", "subanim5"]
		current_anim = 0
		playing_anim = None
		anim_has_started = False
		exit = False

		# minisubnd
		minisub = scene.GetNodeEx("minisub_anim:emitter")
		minisub_matrix = minisub.GetTransform().GetWorld()
		minisub_prev_pos = hg.GetTranslation(minisub_matrix)

		minisub_emitter_trigger = scene.GetNodeEx("minisub_anim/engine_thrust") # this node has an animated attribute (enabled/disabled) that tells if we shall emit some particles or not
		minisub_emitter_trigger.RemoveObject() # we don't need the visual clue for this node, only the enabled status will matter.

		# mouse
		mouse = hg.Mouse()

		# walkman
		# click zone found directly in the main scene
		walkman_button_pressed = -1
		walkman_button_pressed_timeout = hg.GetClock()
		walkman_buttons_nodes = []
		for i in range(4):
			nd = scene.GetNode("walkman_click_zone_" + str(i))
			if nd.IsValid():
				walkman_buttons_nodes.append(nd)
			# end
		# end

		# button nodes carrying the mesh, in the walkman instanciated scene
		# list of buttons names
		buttons = ["walkman_button_0",
						"walkman_button_1",
						"walkman_button_2",
						"walkman_button_3"]

		song_player = {
			"titles":[
				"erk_Elsewhere",
				"aceman_underwater",
				"nainain_minisub_music",
				"willbe_loops",
				"ma2e_summer_trance",
				"erk_Mountains_City",
				"gligli_underwater",
				"erk_electronics_underground",
				"riddlemak_ia",
			],
			"durations":[],
			"current_song_idx":0,
			"current_song_timestamp":-1,
			"repeat_mode":False,
			"song_ref":None
		}

		prev_song_idx = -1

		for i in range(len(song_player["titles"])):
			song_player["durations"].append(hg.time_from_sec_f(songs_data[song_player["titles"][i]]["samples"] / songs_data[song_player["titles"][i]]["frequency"]))
			# print(song_player["durations"][i])
		# end

		walkman_button_change_state = True
		walkman_button_hover = -1
		walkman_button_on = WALKMAN_PLAY

		# direct reference to each button's component
		buttons_trs = []
		for i in range(len(buttons)):
			buttons_trs.append(scene.GetNode("walkman_rig").GetInstanceSceneView().GetNode(scene, buttons[i]).GetTransform())
		# end

		# direct reference to the walkman display	
		osd_instance_view = scene.GetNode("walkman_rig").GetInstanceSceneView().GetNode(scene, "osd").GetInstanceSceneView()
		walkman_osd = {"clock_str":None, "led_rail_timer":None, "current_led":0}
		# walkman_osd = {clock_str=None, led_rail_timer=None, current_led=0,
		# 				icon_mode_repeat=None, icon_mode_next=None, double_dot=None,
		# 				digit_0=None, digit_1=None, digit_2=None, digit_3=None,
		# 				songs_titles=None,
		# 				dot_0=None, dot_1=None, dot_2=None, dot_3=None, dot_4=None}
		walkman_osd["icon_mode_repeat"] = osd_instance_view.GetNode(scene, "icon_mode_repeat")
		walkman_osd["icon_mode_next"] = osd_instance_view.GetNode(scene, "icon_mode_next")
		walkman_osd["double_dot"] = osd_instance_view.GetNode(scene, "double_dot")
		walkman_osd["digit_0"] = osd_instance_view.GetNode(scene, "digit_0").GetObject().GetMaterial(0)
		walkman_osd["digit_1"] = osd_instance_view.GetNode(scene, "digit_1").GetObject().GetMaterial(0)
		walkman_osd["digit_2"] = osd_instance_view.GetNode(scene, "digit_2").GetObject().GetMaterial(0)
		walkman_osd["digit_3"] = osd_instance_view.GetNode(scene, "digit_3").GetObject().GetMaterial(0)
		walkman_osd["songs_titles"] = osd_instance_view.GetNode(scene, "songs_titles").GetObject().GetMaterial(0)
		walkman_osd["dot_0"] = osd_instance_view.GetNode(scene, "dot_0").GetObject().GetMaterial(0)
		walkman_osd["dot_1"] = osd_instance_view.GetNode(scene, "dot_1").GetObject().GetMaterial(0)
		walkman_osd["dot_2"] = osd_instance_view.GetNode(scene, "dot_2").GetObject().GetMaterial(0)
		walkman_osd["dot_3"] = osd_instance_view.GetNode(scene, "dot_3").GetObject().GetMaterial(0)
		walkman_osd["dot_4"] = osd_instance_view.GetNode(scene, "dot_4").GetObject().GetMaterial(0)

		# static bubble emitters
		static_bubble_particles = []
		max_bubble_emitter = 3
		static_bubble_vel = hg.Vec3(0,0,0)

		for i in range(max_bubble_emitter):
			emitter_name = "bubble_emitter_" + str(i)
			emitter_node = scene.GetNode(emitter_name)
			static_bubble_particles.append(
				{"node":emitter_node, "world_mat":emitter_node.GetTransform().GetWorld(), "bubble_particles":{
					"emitter":{"spawn_timeout":hg.time_from_sec_f(0.0)}, "particles":[]}
					}
				)
		# end

		# events
		event_table = {}

		# scroll text
		scroll_x = 0
		char_offset = 0
		ns = 0

		# if profiler:
		# 	profiler.start()
		# # end

		play_song(song_player)

		p_nodes = []
		_n = scene.GetNodes()

		for i in range(_n.size()):
			if _n.at(i).GetName()[0:2] == "col":
				p_nodes.append(_n.at(i))
				# print(_n:at(i):GetName())
			# end
		# end

		# Intro AAA pipeline config
		if config["enable_aaa"]:
			pipeline_aaa_config = hg.ForwardPipelineAAAConfig()
			pipeline_aaa = hg.CreateForwardPipelineAAAFromAssets("core", pipeline_aaa_config, hg.BR_Half, hg.BR_Half)
			if config["low_aaa"]:
				pipeline_aaa_config.temporal_aa_weight = 0.2
				pipeline_aaa_config.sample_count = 1
			else:
				pipeline_aaa_config.temporal_aa_weight = 0.0100
				pipeline_aaa_config.sample_count = 2
			# end
			pipeline_aaa_config.z_thickness = 0.2600 # in meters
			pipeline_aaa_config.bloom_bias = 0.5
			pipeline_aaa_config.bloom_intensity	= 0.1
			pipeline_aaa_config.bloom_threshold	= 5.0
		# end

		# Intro Loop #########################################################
		intro_clock = hg.time_from_sec_f(0.0)

		hg.HideCursor()

		if not config["skip_intro"]:
			while not hg.ReadKeyboard().Key(hg.K_Escape) and hg.IsWindowOpen(win) and intro_current_anim < len(intro_anims) - 1:

				intro_anim_has_started, intro_playing_anim, intro_current_anim = anim_player(scene_intro, intro_anims, intro_anim_has_started, intro_playing_anim, intro_current_anim)

				dt = min(hg.time_from_sec_f(5.0/60.0), hg.TickClock())
				intro_clock = intro_clock + dt

				scene_intro.Update(dt)

				view_id = 0
				if config["enable_aaa"]:
					view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, scene_intro, hg.IntRect(0, 0, res_x, res_y), True, pipeline, res, pipeline_aaa, pipeline_aaa_config, frame)
				else:
					view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, scene_intro, hg.IntRect(0, 0, res_x, res_y), True, pipeline, res)
				# end

				transparent_view_id = hg.GetSceneForwardPipelinePassViewId(pass_ids, hg.SFPP_Transparent)

				# dirt particles
				# val_uniforms_dirt, tex_uniforms_dirt
				intro_particle_fade = clamp(remap(hg.time_to_sec_f(intro_clock), 1.0, 10.0, 0.0, 1.0), 0.0, 1.0)
				intro_particle_fade = intro_particle_fade * clamp(remap(hg.time_to_sec_f(intro_clock), 31.0, 34.0, 1.0, 0.0), 0.0, 1.0)

				tex_uniforms_dirt = [hg.MakeUniformSetTexture('s_tex', dirt_particle_texture, 0)]
				intro_particles = particles_update_draw_model(transparent_view_id, dt, intro_particles, 
								particle_intro_mdl, shader_for_particle, [] , tex_uniforms_dirt, particle_dirt_render_state, 2.0, intro_particle_fade)

				frame = hg.Frame()
				hg.UpdateWindow(win)

			# end
		# end

		# Demo AAA pipeline config
		# pipeline_aaa_config, pipeline_aaa
		if config["enable_aaa"]:
			pipeline_aaa_config = hg.ForwardPipelineAAAConfig()
			pipeline_aaa = hg.CreateForwardPipelineAAAFromAssets("core", pipeline_aaa_config, hg.BR_Half, hg.BR_Half)
			if config["low_aaa"]:
				pipeline_aaa_config.temporal_aa_weight = 0.2
				pipeline_aaa_config.sample_count = 1
			else:
				pipeline_aaa_config.temporal_aa_weight = 0.05
				pipeline_aaa_config.sample_count = 2
			# end
			pipeline_aaa_config.z_thickness = 4.0 # in meters
			pipeline_aaa_config.bloom_bias = 0.00999
			pipeline_aaa_config.bloom_intensity	= 2.19
			pipeline_aaa_config.bloom_threshold	= 4.25 * 3.0
		# end

		# Demo loop ###################################################
		fade = 0.0
		fade_pow = 1.0

		show_cursor_count = 0
		hg.ShowCursor()

		while not hg.ReadKeyboard().Key(hg.K_Escape) & hg.IsWindowOpen(win):

			show_cursor_count += 1
			if show_cursor_count > 30:
				show_cursor_count = 0
				hg.ShowCursor()
			# end

			# events
			if hg.ReadKeyboard().Key(hg.K_G):
				event_table = start_event(scene, "guru_meditation_event", event_table)
			# end

			event_table = update_events(scene, event_table)
			
			mouse.Update()
			
			lines = []
			dt = min(hg.time_from_sec_f(5.0/60.0), hg.TickClock())
			dts = hg.time_to_sec_f(dt)
			clock = clock + dt
			angle = angle + hg.time_to_sec_f(dt)

			minisub_matrix = minisub.GetTransform().GetWorld()
			minisub_pos = hg.GetTranslation(minisub_matrix)
			_tmp_vec = hg.Normalize(hg.GetRow(minisub_matrix, 0)) * 0.075
			minisub_velocity = (minisub_prev_pos - minisub_pos) * 0.5 + hg.Vec3(_tmp_vec.x, _tmp_vec.y, _tmp_vec.z)
			minisub_prev_pos = minisub_pos

			# table.insert(lines, {pos_a = minisub_pos, pos_b = minisub_pos + hg.GetRow(minisub_matrix, 0), color = hg.Color.Red})
			# table.insert(lines, {pos_a = minisub_pos, pos_b = minisub_pos + hg.GetRow(minisub_matrix, 1), color = hg.Color.Green})
			# table.insert(lines, {pos_a = minisub_pos, pos_b = minisub_pos + hg.GetRow(minisub_matrix, 2), color = hg.Color.Blue})

			# minisub animations
			anim_has_started, playing_anim, current_anim = anim_player(scene, anims, anim_has_started, playing_anim, current_anim)
			# minisub bubble emitter
			if minisub_emitter_trigger.IsEnabled():
				spawn_minisub_bubbles = 0.25
			else:
				spawn_minisub_bubbles = 0
			# end
			
			bubble_particles = bubbles_update_draw(bubble_scene, res, hg.GetForwardPipelineInfo(), blank_bubble, dt, bubble_particles, minisub_matrix, minisub_velocity, spawn_minisub_bubbles)

			# static bubble emitters
			for i in range(max_bubble_emitter):
				spawn_interval = max(0.0, (0.75 + sin(hg.time_to_sec_f(clock) * 1.5)) * 10.0)
				# print(spawn_interval)
				spawn_interval_random = 0.5
				static_bubble_particles[i]["bubble_particles"] = bubbles_update_draw(bubble_scene, res, hg.GetForwardPipelineInfo(), blank_bubble, dt, static_bubble_particles[i]["bubble_particles"], static_bubble_particles[i]["world_mat"], static_bubble_vel, spawn_interval, spawn_interval_random)
			# end

			# walkman interactivity
			walkman_button_on, walkman_button_hover, walkman_button_change_state, walkman_button_pressed_timeout = walkman_interaction_update(scene, mouse, res_vec2, dts, buttons, walkman_buttons_nodes, buttons_trs, walkman_button_on, walkman_button_hover, walkman_button_change_state, walkman_button_pressed_timeout)

			# song player
			song_player, walkman_osd, walkman_button_change_state, walkman_button_on = song_player_update(song_player, walkman_osd, walkman_button_change_state, walkman_button_on, prev_song_idx, walkman_button_pressed_timeout, config)

			for i in range(len(p_nodes)):
				physics.NodeWake(p_nodes[i])
			# end
			hg.SceneUpdateSystems(scene, scene_clocks, dt, physics, hg.time_from_sec_f(1 / 60), 4)
			# physics.SyncTransformsToScene(scene)
			# scene.Update(dt)
			bubble_scene.Update(dt)

			# main framebuffer
			view_id = 0
			if config["enable_aaa"]:
				view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, scene, hg.IntRect(0, 0, res_x, res_y), True, pipeline, res, pipeline_aaa, pipeline_aaa_config, frame, frame_buffer.handle)
			else:
				view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, scene, hg.IntRect(0, 0, res_x, res_y), True, pipeline, res, frame_buffer.handle)
			# end

			# debug draw lines
			opaque_view_id = hg.GetSceneForwardPipelinePassViewId(pass_ids, hg.SFPP_Opaque)
			for i in range(len(lines)):
				draw_line(lines[i]["pos_a"], lines[i]["pos_b"], lines[i]["color"], opaque_view_id, vtx_line_layout, shader_for_line)
			# end

			# dirt particles
			transparent_view_id = hg.GetSceneForwardPipelinePassViewId(pass_ids, hg.SFPP_Transparent)
			# dirt_particles = particles_update_draw(opaque_view_id, vtx_line_layout, dt, dirt_particles, shader_for_line)

			# val_uniforms_dirt = {hg.MakeUniformSetValue('color', hg.Vec4(1, 0, 1, 1))}
			val_uniforms_dirt = []
			tex_uniforms_dirt = [hg.MakeUniformSetTexture('s_tex', dirt_particle_texture, 0)]
			dirt_particles = particles_update_draw_model(transparent_view_id, dt, dirt_particles, 
							particle_dirt_mdl, shader_for_particle, val_uniforms_dirt, tex_uniforms_dirt, particle_dirt_render_state)

			# fish boids
			fish_boids = boids_update_draw(opaque_view_id, vtx_line_layout, dt, fish_boids, boids_min_max, scene, physics, shader_for_line, scene.GetNode("sphere"))

			# bubble framebuffer
			view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, bubble_scene, hg.IntRect(0, 0, res_x, res_y), True, pipeline, res, bubble_frame_buffer.handle)

			# draw the render texture on a quad
			hg.SetViewPerspective(view_id, 0, 0, res_x, res_y, hg.TranslationMat4(hg.Vec3(0, 0, -0.5)))

			# final compositing
			fade = min(1.0, fade + dts * 0.35)
			fade_pow = 2.0 - EaseInOutQuick(fade)

			# val_uniforms, tex_uniforms
			val_uniforms = [hg.MakeUniformSetValue('color', hg.Vec4(1, 1, 1, 1)),
							hg.MakeUniformSetValue('fade', hg.Vec4(EaseInOutQuick(fade), fade_pow, 0.0, 0.0)),
							hg.MakeUniformSetValue('uClock', hg.Vec4(hg.time_to_sec_f(clock), 0.1, 0.0, 0.0)),
							hg.MakeUniformSetValue('uZFrustum', hg.Vec4(z_near, z_far, fov, 0))
						]
			tex_uniforms = [hg.MakeUniformSetTexture('s_tex', color, 0), hg.MakeUniformSetTexture('s_depth', depth, 1), 
							hg.MakeUniformSetTexture('b_tex', bubble_color, 2), hg.MakeUniformSetTexture('b_depth', bubble_depth, 3)]

			_screen_pos = hg.Vec3(0, 0, 0)
			if widescreen == False:
				_screen_pos.z = 0.1725

			hg.DrawModel(view_id, screen_mdl, screen_prg, val_uniforms, tex_uniforms, 
						hg.TransformationMat4(_screen_pos, hg.Vec3(pi / 2, pi, 0)))

			view_id = view_id + 1
			hg.SetView2D(view_id, 0, 0, res_x, res_y, -1, 1, hg.CF_None, hg.Color.Black, 1, 0)

			if widescreen == False:
				view_id, scroll_x, char_offset, ns = update_demo_scroll_text(dt, view_id, res_x, res_y, scroll_x, char_offset, ns, scroll_text, font, font_program, font_size, text_render_state, EaseInOutQuick(fade), -40.0)
			else:
				view_id, scroll_x, char_offset, ns = update_demo_scroll_text(dt, view_id, res_x, res_y, scroll_x, char_offset, ns, scroll_text, font, font_program, font_size, text_render_state, EaseInOutQuick(fade))

			# Debug physics display
			if False:
				view_id = view_id + 1
				hg.SetViewClear(view_id, 0, 0, 1.0, 0)
				hg.SetViewRect(view_id, 0, 0, res_x, res_y)
				cam_mat = cam.GetTransform().GetWorld()
				view_matrix = hg.InverseFast(cam_mat)
				c = cam.GetCamera()
				projection_matrix = hg.ComputePerspectiveProjectionMatrix(c.GetZNear(), c.GetZFar(), hg.FovToZoomFactor(c.GetFov()), hg.Vec2(res_x / res_y, 1))
				hg.SetViewTransform(view_id, view_matrix, projection_matrix)
				rs = hg.ComputeRenderState(hg.BM_Opaque, hg.DT_Disabled, hg.FC_Disabled)
				physics.RenderCollision(view_id, vtx_line_layout, shader_for_line, rs, 0)
			# end

			#
			frame = hg.Frame()
			hg.UpdateWindow(win)

		# end

		# if profiler:
		# 	profiler.stop()
		# 	profiler.report("profiler.log")
		# # end

		hg.RenderShutdown()
		hg.WindowSystemShutdown()
	# end
# end

main()

