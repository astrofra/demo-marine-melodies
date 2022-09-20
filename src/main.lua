hg = require("harfang")
-- profiler = require("profiler")
require("scrolltext")
require("particles")
require("boids")
require("bubbles")
require("animations")
require("walkman")
require("config_gui")
require("utils")
songs_data = require("songs_data")

-- credits
-- concept & graphics : fra
-- music : Erk, Nainain, GliGli, Aceman, mAZE, Riddlemak, WillBe
-- code : fra, erk
-- 3D engine : xbarr, mooz, scorpheus, kipixelle

function draw_line(pos_a, pos_b, line_color, vid, vtx_line_layout, line_shader)
	local vtx = hg.Vertices(vtx_line_layout, 2)
	vtx:Begin(0):SetPos(pos_a):SetColor0(line_color):End()
	vtx:Begin(1):SetPos(pos_b):SetColor0(line_color):End()
	hg.DrawLines(vid, vtx, line_shader)
end

function main(cmd_arg)
	local config = {enable_aaa=true, low_aaa=false, skip_intro=true, is_opengl=true}
	local i

	if package.config:sub(1,1) == '/' then
		is_opengl=true
	end

	-- hg.SetLogLevel(hg.LL_Normal)

	hg.InputInit()
	hg.AudioInit()
	hg.WindowSystemInit()

	if IsLinux() then
		hg.AddAssetsFolder("../assetsc")
	else
		hg.AddAssetsFolder("assetsc")
	end

	-- resolution selection --------------------------------------------------------------------------------
	local win
	local config_done
	local default_res_x
	local default_res_y
	local default_fullscreen
	local full_aaa
	local low_aaa
	local no_aa

	hg.ShowCursor()
	config_done, default_res_x, default_res_y, default_fullscreen, full_aaa, low_aaa, no_aaa = config_gui(config.is_opengl)

	-- set config
	res_x, res_y = default_res_x, default_res_y

	if no_aaa then
		config.enable_aaa = false 
	else
		config.enable_aaa = true
		if low_aaa then
			config.low_aaa = true
		else
			config.low_aaa = false
		end
	end

	if config_done == 1 then 
		-- Demo start
		-- res_x, res_y = resolution_multiplier(res_x, res_x, 0.8)
		local res_vec2 = hg.Vec2(res_x, res_y)
		local font_size = math.floor((40 * res_x) / 1280)

		-- local win = hg.RenderInit('Minisub Escape', res_x, res_y, hg.RF_VSync | hg.RF_MSAA4X)
		win = hg.NewWindow("Marine Melodies^Resistance(2022)", res_x, res_y, 32, default_fullscreen) --, hg.WV_Fullscreen)
		if config.is_opengl == false then
			hg.RenderInit(win)
		else
			hg.RenderInit(win, hg.RT_OpenGL)
		end
		hg.RenderReset(res_x, res_y, hg.RF_MSAA4X | hg.RF_MaxAnisotropy)

		-- create pipeline
		local pipeline = hg.CreateForwardPipeline()
		local res = hg.PipelineResources()

		-- INTRO
		local scene_intro = hg.Scene()
		hg.LoadSceneFromAssets("logo_rse/logo_rse.scn", scene_intro, res, hg.GetForwardPipelineInfo())

		local cam_intro = scene_intro:GetNode("Camera")
		scene_intro:SetCurrentCamera(cam_intro)

		-- DEMO
		-- load the scene to draw to a texture
		local scene = hg.Scene()
		hg.LoadSceneFromAssets("main_scenery.scn", scene, res, hg.GetForwardPipelineInfo())
		local intro_anims = {"begin", "fadein", "fadeout", "title_fadein", "title_fadeout", "end"}
		local intro_current_anim = 0
		local intro_playing_anim = 0
		local intro_anim_has_started = false

		-- physics
		local physics = hg.SceneBullet3Physics()
		physics:SceneCreatePhysicsFromAssets(scene)

		local scene_clocks = hg.SceneClocks()

		-- specific scene to render the bubbles
		local bubble_scene
		if config.is_opengl == false then
			bubble_scene = hg.Scene()
		else
			bubble_scene = scene
		end

		-- create a frame buffer to draw the scene to
		local color = hg.CreateTexture(res_x, res_y, "color texture", hg.TF_RenderTarget, hg.TF_RGBA8)
		local depth =  hg.CreateTexture(res_x, res_y, "depth texture", hg.TF_RenderTarget, hg.TF_D24F)
		local frame_buffer = hg.CreateFrameBuffer(color, depth, "framebuffer")

		if config.is_opengl == false then
			local bubble_color = hg.CreateTexture(res_x, res_y, "color texture", hg.TF_RenderTarget, hg.TF_RGBA8)
			local bubble_depth =  hg.CreateTexture(res_x, res_y, "depth texture", hg.TF_RenderTarget, hg.TF_D24F)
			local bubble_frame_buffer = hg.CreateFrameBuffer(bubble_color, bubble_depth, "bubble_framebuffer")
		end

		-- create a plane model for the final rendering stage
		local vtx_layout = hg.VertexLayoutPosFloatNormUInt8TexCoord0UInt8()

		local screen_mdl = hg.CreatePlaneModel(vtx_layout, 1, res_y / res_x, 1, 1)
		local screen_ref = res:AddModel('screen', screen_mdl)

		-- create a plane model for the dirt particles
		local vtx_layout = hg.VertexLayoutPosFloatNormUInt8TexCoord0UInt8()

		local particle_intro_mdl
		particle_intro_mdl = build_random_particles_model(hg.ModelBuilder(), vtx_layout, 3, 25.0)

		local particle_dirt_mdl
		-- particle_dirt_mdl = hg.CreatePlaneModel(vtx_layout, 1, 1, 1, 1) -- generic quad
		particle_dirt_mdl = build_random_particles_model(hg.ModelBuilder(), vtx_layout, 5, 15.0)

		local particle_dirt_ref = res:AddModel('dirt_particle', particle_dirt_mdl)
		local particle_dirt_render_state = hg.ComputeRenderState(hg.BM_Alpha, hg.DT_Less, hg.FC_Disabled, false)

		-- prepare the plane shader program
		local screen_prg = hg.LoadProgramFromAssets('shaders/compositer')

		-- shader to draw some 3D lines
		local vtx_line_layout = hg.VertexLayoutPosFloatColorUInt8()
		local shader_for_line = hg.LoadProgramFromAssets("shaders/pos_rgb")
		local shader_for_particle = hg.LoadProgramFromAssets("shaders/dirt_particle")
		local dirt_particle_texture,_ = hg.LoadTextureFromAssets("maps/dirt_particle.png", 
										hg.TF_UBorder | hg.TF_VBorder | hg.TF_SamplerMinAnisotropic | hg.TF_SamplerMagAnisotropic)

		-- text rendering
		-- load font and shader program
		local font = hg.LoadFontFromAssets('fonts/Hogfish.otf', font_size)
		local font_program  = hg.LoadProgramFromAssets('core/shader/font')

		-- text uniforms and render state
		local text_uniform_values = {hg.MakeUniformSetValue('u_color', hg.Vec4(1, 1, 0, 1))}
		local text_render_state = hg.ComputeRenderState(hg.BM_Alpha, hg.DT_Always, hg.FC_Disabled)

		-- Set render camera
		local cam = scene:GetNode("Camera")
		scene:SetCurrentCamera(cam)
		local z_near = cam:GetCamera():GetZNear()
		local z_far = cam:GetCamera():GetZFar()
		local fov = cam:GetCamera():GetFov()

		if config.is_opengl == false then
			local bubble_cam = hg.CreateCamera(bubble_scene, cam:GetTransform():GetWorld(), z_near, z_far, fov)
			bubble_scene:SetCurrentCamera(bubble_cam)
		end

		-- intro particles init
		local intro_particles = {}
		local _max_particles = 100
		for i = 1, _max_particles do
			local particle_alpha = i / _max_particles -- more and more opaque (only the spatial distribution is randomized)
			local particle_age = hg.time_from_sec_f((i / _max_particles) * math.pi * 2.0)
			table.insert(intro_particles, {	-- pos=hg.Vec3(0.0, 10.0, 0.0), 
											pos=hg.Vec3(math.random(-40, 40), math.random(-20, 20), math.random(100, 200)),
											rot=hg.Vec3(0.0, 0.0, math.random() * math.pi * 2.0),
											alpha=particle_alpha, age=particle_age})
		end

		-- dirt particles init
		local dirt_particles = {}
		local _max_particles = 150
		for i = 1, _max_particles do
			local particle_alpha = i / _max_particles  -- more and more opaque (only the spatial distribution is randomized)
			local particle_age = hg.time_from_sec_f((i / _max_particles) * math.pi * 2.0)
			table.insert(dirt_particles, {	-- pos=hg.Vec3(0.0, 10.0, 0.0), 
											pos=hg.Vec3(math.random(-30, 30), math.random(0, 20), math.random(-20, 100)),
											rot=hg.Vec3(0.0, 0.0, math.random() * math.pi * 2.0),
											alpha=particle_alpha, age=particle_age})
		end

		-- bubbles init
		local bubble_particles = {emitter={spawn_timeout=hg.time_from_sec_f(0.0)}, particles={}}
		local blank_bubble
		if config.is_opengl == false then
			blank_bubble = hg.CreateInstanceFromAssets(bubble_scene, hg.TranslationMat4(hg.Vec3(0,0,0)), "bubble.scn", res, hg.GetForwardPipelineInfo()) -- , hg.LSSF_Nodes | hg.LSSF_Scene | hg.LSSF_DoNotChangeCurrentCameraIfValid)
		else
			blank_bubble = hg.CreateInstanceFromAssets(bubble_scene, hg.TranslationMat4(hg.Vec3(0,0,0)), "bubble_reflection.scn", res, hg.GetForwardPipelineInfo()) -- , hg.LSSF_Nodes | hg.LSSF_Scene | hg.LSSF_DoNotChangeCurrentCameraIfValid)
		end
		blank_bubble:Disable()

		-- fish boids init
		local fish_boids = {}
		local boids_min_max = hg.MinMax(hg.Vec3(-20, -5, -5), hg.Vec3(20, 25, 50))
		for i = 0, 25 do
			table.insert(fish_boids, {pos=hg.Vec3(math.random(boids_min_max.mn.x, boids_min_max.mx.x) * 0.1, 
													math.random(boids_min_max.mn.y, boids_min_max.mx.y) * 0.1, 
													math.random(boids_min_max.mn.z, boids_min_max.mx.z) * 0.1), 
										dir=hg.Vec3(math.random(-100, 100)/200.0, math.random(-100, 100)/200.0, math.random(-100, 100)/200.0),
										target_dir=hg.Vec3(math.random(-100, 100)/200.0, math.random(-100, 100)/200.0, math.random(-100, 100)/200.0),
										age=hg.time_from_sec_f(0.0),
										node=nil, transform=nil})
		end

		-- load models for the fish
		for i = 1, #fish_boids do
			fish_boids[i].node = hg.CreateInstanceFromAssets(scene, hg.TranslationMat4(hg.Vec3(0,0,0)), "Cartoon_Fish/fish_0.scn", res, hg.GetForwardPipelineInfo())
			fish_boids[i].transform = fish_boids[i].node:GetTransform()
		end

		-- main loop
		local angle = 0
		local frame = 0
		local clock = hg.time_from_sec_f(0.0)

		local anims = {"subanim0", "subanim1", "subanim2", "subanim3", "subanim4", "subanim5"}
		local current_anim = 0
		local playing_anim = 0
		local anim_has_started = false
		local exit = false

		-- minisub
		local minisub = scene:GetNodeEx("minisub_anim:emitter")
		local minisub_matrix = minisub:GetTransform():GetWorld()
		local minisub_prev_pos = hg.GetTranslation(minisub_matrix)

		local minisub_emitter_trigger = scene:GetNodeEx("minisub_anim/engine_thrust") -- this node has an animated attribute (enabled/disabled) that tells if we shall emit some particles or not
		minisub_emitter_trigger:RemoveObject() -- we don't need the visual clue for this node, only the enabled status will matter.

		-- mouse
		local mouse = hg.Mouse()

		-- walkman
		-- click zone found directly in the main scene
		local walkman_button_pressed = -1
		local walkman_button_pressed_timeout = hg.GetClock()
		local walkman_buttons_nodes = {}
		for i = 0, 3 do
			local nd = scene:GetNode("walkman_click_zone_" .. i)
			if nd:IsValid() then
				table.insert(walkman_buttons_nodes, nd)
			end
		end

		-- button nodes carrying the mesh, in the walkman instanciated scene
		-- list of buttons names
		local buttons = {"walkman_button_0",
						"walkman_button_1",
						"walkman_button_2",
						"walkman_button_3"}

		local song_player = {
			titles = {
				"erk_Elsewhere",
				"aceman_underwater",
				"nainain_minisub_music",
				"willbe_loops",
				"ma2e_summer_trance",
				"erk_Mountains_City",
				"gligli_underwater",
				"erk_electronics_underground",
				"riddlemak_ia",
			},
			durations = {},
			current_song_idx = 1,
			current_song_timestamp = -1,
			repeat_mode = false,
			song_ref = nil
		}

		for i=1,#song_player.titles do
			song_player.durations[i] = hg.time_from_sec_f(songs_data[song_player.titles[i]].samples / songs_data[song_player.titles[i]].frequency)
			-- print(song_player.durations[i])
		end

		-- local walkman_button_change_state = false
		local walkman_button_hover = -1
		local walkman_button_on = WALKMAN_PLAY

		-- direct reference to each button's component
		local buttons_trs = {}
		for i = 1, #buttons do
			table.insert(buttons_trs, scene:GetNode("walkman_rig"):GetInstanceSceneView():GetNode(scene, buttons[i]):GetTransform())
		end

		-- direct reference to the walkman display
		local walkman_osd = {clock_str = nil, led_rail_timer = nil, current_led = 0}
		local osd_instance_view = scene:GetNode("walkman_rig"):GetInstanceSceneView():GetNode(scene, "osd"):GetInstanceSceneView()
		walkman_osd["icon_mode_repeat"] = osd_instance_view:GetNode(scene, "icon_mode_repeat")
		walkman_osd["icon_mode_next"] = osd_instance_view:GetNode(scene, "icon_mode_next")
		walkman_osd["double_dot"] = osd_instance_view:GetNode(scene, "double_dot")
		walkman_osd["digit_0"] = osd_instance_view:GetNode(scene, "digit_0"):GetObject():GetMaterial(0)
		walkman_osd["digit_1"] = osd_instance_view:GetNode(scene, "digit_1"):GetObject():GetMaterial(0)
		walkman_osd["digit_2"] = osd_instance_view:GetNode(scene, "digit_2"):GetObject():GetMaterial(0)
		walkman_osd["digit_3"] = osd_instance_view:GetNode(scene, "digit_3"):GetObject():GetMaterial(0)
		walkman_osd["songs_titles"] = osd_instance_view:GetNode(scene, "songs_titles"):GetObject():GetMaterial(0)
		walkman_osd["dot_0"] = osd_instance_view:GetNode(scene, "dot_0"):GetObject():GetMaterial(0)
		walkman_osd["dot_1"] = osd_instance_view:GetNode(scene, "dot_1"):GetObject():GetMaterial(0)
		walkman_osd["dot_2"] = osd_instance_view:GetNode(scene, "dot_2"):GetObject():GetMaterial(0)
		walkman_osd["dot_3"] = osd_instance_view:GetNode(scene, "dot_3"):GetObject():GetMaterial(0)
		walkman_osd["dot_4"] = osd_instance_view:GetNode(scene, "dot_4"):GetObject():GetMaterial(0)

		-- static bubble emitters
		local static_bubble_particles = {}
		local max_bubble_emitter = 3
		local static_bubble_vel = hg.Vec3(0,0,0)

		for i = 0, max_bubble_emitter do
			emitter_name = "bubble_emitter_" .. tostring(i)
			emitter_node = scene:GetNode(emitter_name)
			table.insert(static_bubble_particles, {node=emitter_node, world_mat=emitter_node:GetTransform():GetWorld(), bubble_particles={emitter={spawn_timeout=hg.time_from_sec_f(0.0)}, particles={}}})
		end

		-- events
		local event_table = {}

		-- scroll text
		local scroll_x = 0
		local char_offset = 0
		local ns = 0
		local dt
		local dts

		if profiler then
			profiler.start()
		end

		play_song(song_player)

		local p_nodes = {}
		local _n = scene:GetNodes()

		for i = 0, _n:size() - 1 do
			if string.sub(_n:at(i):GetName(), 1, 3) == "col" then
				table.insert(p_nodes, _n:at(i))
				-- print(_n:at(i):GetName())
			end
		end

		-- Intro AAA pipeline config
		local pipeline_aaa_config, pipeline_aaa
		if config.enable_aaa then
			pipeline_aaa_config = hg.ForwardPipelineAAAConfig()
			pipeline_aaa = hg.CreateForwardPipelineAAAFromAssets("core", pipeline_aaa_config, hg.BR_Half, hg.BR_Half)
			if config.low_aaa then
				pipeline_aaa_config.temporal_aa_weight = 0.2
				pipeline_aaa_config.sample_count = 1
			else
				pipeline_aaa_config.temporal_aa_weight = 0.0100
				pipeline_aaa_config.sample_count = 2
			end
			pipeline_aaa_config.z_thickness = 0.2600 -- in meters
			pipeline_aaa_config.bloom_bias = 0.5
			pipeline_aaa_config.bloom_intensity	= 0.1
			pipeline_aaa_config.bloom_threshold	= 5.0
		end

		-- Intro Loop ------------------------------------------------------------------------------------------------------------------
		local intro_particle_fade
		local intro_clock = hg.time_from_sec_f(0.0)

		hg.HideCursor()

		if config.skip_intro == false then
			while not hg.ReadKeyboard():Key(hg.K_Escape) and hg.IsWindowOpen(win) and intro_current_anim < #intro_anims do

				intro_anim_has_started, intro_playing_anim, intro_current_anim = anim_player(scene_intro, intro_anims, intro_anim_has_started, intro_playing_anim, intro_current_anim)

				dt = math.min(hg.time_from_sec_f(5.0/60.0), hg.TickClock())
				intro_clock = intro_clock + dt

				scene_intro:Update(dt)

				local view_id = 0
				local pass_ids
				if config.enable_aaa then
					view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, scene_intro, hg.IntRect(0, 0, res_x, res_y), true, pipeline, res, pipeline_aaa, pipeline_aaa_config, frame)
				else
					view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, scene_intro, hg.IntRect(0, 0, res_x, res_y), true, pipeline, res)
				end

				local transparent_view_id = hg.GetSceneForwardPipelinePassViewId(pass_ids, hg.SFPP_Transparent)

				-- dirt particles
				local val_uniforms_dirt, tex_uniforms_dirt
				intro_particle_fade = clamp(map(hg.time_to_sec_f(intro_clock), 1.0, 10.0, 0.0, 1.0), 0.0, 1.0)
				intro_particle_fade = intro_particle_fade * clamp(map(hg.time_to_sec_f(intro_clock), 31.0, 34.0, 1.0, 0.0), 0.0, 1.0)

				tex_uniforms_dirt = {hg.MakeUniformSetTexture('s_tex', dirt_particle_texture, 0)}
				intro_particles = particles_update_draw_model(transparent_view_id, dt, intro_particles, 
								particle_intro_mdl, shader_for_particle, val_uniforms_dirt, tex_uniforms_dirt, particle_dirt_render_state, 2.0, intro_particle_fade)

				frame = hg.Frame()
				hg.UpdateWindow(win)

				-- prevent GC bottleneck 
				collectgarbage()
			end
		end

		-- Demo AAA pipeline config
		local pipeline_aaa_config, pipeline_aaa
		if config.enable_aaa then
			pipeline_aaa_config = hg.ForwardPipelineAAAConfig()
			pipeline_aaa = hg.CreateForwardPipelineAAAFromAssets("core", pipeline_aaa_config, hg.BR_Half, hg.BR_Half)
			if config.low_aaa then
				pipeline_aaa_config.temporal_aa_weight = 0.2
				pipeline_aaa_config.sample_count = 1
			else
				pipeline_aaa_config.temporal_aa_weight = 0.05
				pipeline_aaa_config.sample_count = 2
			end
			pipeline_aaa_config.z_thickness = 4.0 -- in meters
			pipeline_aaa_config.bloom_bias = 0.00999
			pipeline_aaa_config.bloom_intensity	= 2.19
			pipeline_aaa_config.bloom_threshold	= 4.25 * 3.0
		end

		-- Demo loop ------------------------------------------------------------------------------------------------------
		local fade = 0.0
		local fade_pow = 1.0

		local show_cursor_count = 0
		hg.ShowCursor()

		while not hg.ReadKeyboard():Key(hg.K_Escape) and hg.IsWindowOpen(win) do

			show_cursor_count = show_cursor_count + 1
			if show_cursor_count > 30 then
				show_cursor_count = 0
				hg.ShowCursor()
			end

			-- events
			if hg.ReadKeyboard():Key(hg.K_G) then
				event_table = start_event(scene, "guru_meditation_event", event_table)
			end

			event_table = update_events(scene, event_table)
			
			mouse:Update()
			
			local lines = {}
			dt = math.min(hg.time_from_sec_f(5.0/60.0), hg.TickClock())
			dts = hg.time_to_sec_f(dt)
			clock = clock + dt
			angle = angle + hg.time_to_sec_f(dt)

			minisub_matrix = minisub:GetTransform():GetWorld()
			minisub_pos = hg.GetTranslation(minisub_matrix)
			local _tmp_vec = hg.Normalize(hg.GetRow(minisub_matrix, 0)) * 0.075
			minisub_velocity = (minisub_prev_pos - minisub_pos) * 0.5 + hg.Vec3(_tmp_vec.x, _tmp_vec.y, _tmp_vec.z)
			minisub_prev_pos = minisub_pos

			-- table.insert(lines, {pos_a = minisub_pos, pos_b = minisub_pos + hg.GetRow(minisub_matrix, 0), color = hg.Color.Red})
			-- table.insert(lines, {pos_a = minisub_pos, pos_b = minisub_pos + hg.GetRow(minisub_matrix, 1), color = hg.Color.Green})
			-- table.insert(lines, {pos_a = minisub_pos, pos_b = minisub_pos + hg.GetRow(minisub_matrix, 2), color = hg.Color.Blue})

			-- minisub animations
			anim_has_started, playing_anim, current_anim = anim_player(scene, anims, anim_has_started, playing_anim, current_anim)
			-- minisub bubble emitter
			if minisub_emitter_trigger:IsEnabled() then
				spawn_minisub_bubbles = 0.25
			else
				spawn_minisub_bubbles = 0
			end
			
			bubble_particles = bubbles_update_draw(bubble_scene, res, hg.GetForwardPipelineInfo(), blank_bubble, dt, bubble_particles, minisub_matrix, minisub_velocity, spawn_minisub_bubbles)

			-- static bubble emitters
			for i = 1, max_bubble_emitter + 1 do
				spawn_interval = math.max(0.0, (0.75 + math.sin(hg.time_to_sec_f(clock) * 1.5)) * 10.0)
				-- print(spawn_interval)
				spawn_interval_random = 0.5
				static_bubble_particles[i].bubble_particles = bubbles_update_draw(bubble_scene, res, hg.GetForwardPipelineInfo(), blank_bubble, dt, static_bubble_particles[i].bubble_particles, static_bubble_particles[i].world_mat, static_bubble_vel, spawn_interval, spawn_interval_random)
			end

			-- walkman interactivity
			walkman_button_on, walkman_button_hover, walkman_button_change_state, walkman_button_pressed_timeout = walkman_interaction_update(scene, mouse, res_vec2, dts, buttons, walkman_buttons_nodes, buttons_trs, walkman_button_on, walkman_button_hover, walkman_button_change_state, walkman_button_pressed_timeout)

			-- song player
			song_player, walkman_osd, walkman_button_change_state, walkman_button_on = song_player_update(song_player, walkman_osd, walkman_button_change_state, walkman_button_on, prev_song_idx, walkman_button_pressed_timeout, config)

			for i = 1, #p_nodes do
				physics:NodeWake(p_nodes[i])
			end
			hg.SceneUpdateSystems(scene, scene_clocks, dt, physics, hg.time_from_sec_f(1 / 60), 4)
			-- physics:SyncTransformsToScene(scene)
			-- scene:Update(dt)
			if config.is_opengl == false then
				bubble_scene:Update(dt)
			end

			-- main framebuffer
			local view_id = 0
			local pass_ids
			if config.enable_aaa then
				view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, scene, hg.IntRect(0, 0, res_x, res_y), true, pipeline, res, pipeline_aaa, pipeline_aaa_config, frame, frame_buffer.handle)
			else
				view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, scene, hg.IntRect(0, 0, res_x, res_y), true, pipeline, res, frame_buffer.handle)
			end
			
			-- view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, scene, hg.IntRect(0, 0, res_x, res_y), true, pipeline, res)

			-- debug draw lines
			local opaque_view_id = hg.GetSceneForwardPipelinePassViewId(pass_ids, hg.SFPP_Opaque)
			for i=1, #lines do
				draw_line(lines[i].pos_a, lines[i].pos_b, lines[i].color, opaque_view_id, vtx_line_layout, shader_for_line)
			end

			-- dirt particles
			local transparent_view_id = hg.GetSceneForwardPipelinePassViewId(pass_ids, hg.SFPP_Transparent)
			-- dirt_particles = particles_update_draw(opaque_view_id, vtx_line_layout, dt, dirt_particles, shader_for_line)

			local val_uniforms_dirt, tex_uniforms_dirt
			-- val_uniforms_dirt = {hg.MakeUniformSetValue('color', hg.Vec4(1, 0, 1, 1))}
			tex_uniforms_dirt = {hg.MakeUniformSetTexture('s_tex', dirt_particle_texture, 0)}
			dirt_particles = particles_update_draw_model(transparent_view_id, dt, dirt_particles, 
							particle_dirt_mdl, shader_for_particle, val_uniforms_dirt, tex_uniforms_dirt, particle_dirt_render_state)

			-- fish boids
			fish_boids = boids_update_draw(opaque_view_id, vtx_line_layout, dt, fish_boids, boids_min_max, scene, physics, shader_for_line, scene:GetNode("sphere"))

			-- bubble framebuffer
			if config.is_opengl == false then
				view_id, pass_ids = hg.SubmitSceneToPipeline(view_id, bubble_scene, hg.IntRect(0, 0, res_x, res_y), true, pipeline, res, bubble_frame_buffer.handle)
			end

			-- draw the render texture on a quad
			hg.SetViewPerspective(view_id, 0, 0, res_x, res_y, hg.TranslationMat4(hg.Vec3(0, 0, -0.5)))

			-- final compositing
			fade = math.min(1.0, fade + dts * 0.35)
			fade_pow = 2.0 - EaseInOutQuick(fade);

			local val_uniforms, tex_uniforms
			val_uniforms = {hg.MakeUniformSetValue('color', hg.Vec4(1, 1, 1, 1)),
							hg.MakeUniformSetValue('fade', hg.Vec4(EaseInOutQuick(fade), fade_pow, 0.0, 0.0)),
							hg.MakeUniformSetValue('uClock', hg.Vec4(hg.time_to_sec_f(clock), 0.1, 0.0, 0.0)),
							hg.MakeUniformSetValue('uZFrustum', hg.Vec4(z_near, z_far, fov, 0))
						}
			if config.is_opengl == false then
				tex_uniforms = {hg.MakeUniformSetTexture('s_tex', color, 0), hg.MakeUniformSetTexture('s_depth', depth, 1), 
							hg.MakeUniformSetTexture('b_tex', bubble_color, 2), hg.MakeUniformSetTexture('b_depth', bubble_depth, 3)}
			else
				tex_uniforms = {hg.MakeUniformSetTexture('s_tex', color, 0)}
			end


			hg.DrawModel(view_id, screen_mdl, screen_prg, val_uniforms, tex_uniforms, 
						hg.TransformationMat4(hg.Vec3(0, 0, 0), hg.Vec3(math.pi / 2, math.pi, 0)))

			view_id = view_id + 1
			hg.SetView2D(view_id, 0, 0, res_x, res_y, -1, 1, hg.CF_None, hg.Color.Black, 1, 0)

			view_id, scroll_x, char_offset, ns = update_demo_scroll_text(dt, view_id, res_x, res_y, scroll_x, char_offset, ns, scroll_text, font, font_program, font_size, text_render_state, EaseInOutQuick(fade))

			-- Debug physics display
			if false then
				view_id = view_id + 1
				hg.SetViewClear(view_id, 0, 0, 1.0, 0)
				hg.SetViewRect(view_id, 0, 0, res_x, res_y)
				local cam_mat = cam:GetTransform():GetWorld()
				local view_matrix = hg.InverseFast(cam_mat)
				c = cam:GetCamera()
				projection_matrix = hg.ComputePerspectiveProjectionMatrix(c:GetZNear(), c:GetZFar(), hg.FovToZoomFactor(c:GetFov()), hg.Vec2(res_x / res_y, 1))
				hg.SetViewTransform(view_id, view_matrix, projection_matrix)
				local rs = hg.ComputeRenderState(hg.BM_Opaque, hg.DT_Disabled, hg.FC_Disabled)
				physics:RenderCollision(view_id, vtx_line_layout, shader_for_line, rs, 0)
			end

			--
			frame = hg.Frame()
			hg.UpdateWindow(win)

			-- prevent GC bottleneck 
			collectgarbage()
		end

		if profiler then
			profiler.stop()
			profiler.report("profiler.log")
		end

		hg.RenderShutdown()
		hg.WindowSystemShutdown()
	end
end

main(arg)

