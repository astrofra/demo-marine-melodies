-- organic particles laying at the bottom of the sea

function particles_update_draw(vid, vtx_line_layout, dt, particles, particle_shader, noise_amplitude)
	local noise_amplitude = noise_amplitude or 1.0

	local dts = hg.time_to_sec_f(dt)
	local i

	for i = 1, #particles do
		-- update
		particles[i].age = particles[i].age + dt
		particles[i].pos = particles[i].pos + hg.RandomVec3(-noise_amplitude, noise_amplitude) * dts

		-- draw
		-- points
		local vtx = hg.Vertices(vtx_line_layout, 2)
		vtx:Begin(0):SetPos(particles[i].pos):SetColor0(hg.Color.White):End()
		vtx:Begin(1):SetPos(particles[i].pos + hg.RandomVec3(-1/5, 1/5)):SetColor0(hg.Color.White):End()
		hg.DrawLines(vid, vtx, particle_shader)
	end

	return particles
end

function particles_update_draw_model(vid, dt, particles, particle_model, particle_shader, particle_uniforms, particle_tex_uniforms, particle_render_state, noise_amplitude, global_fade)
	local noise_amplitude = noise_amplitude or 1.0
	local global_fade = global_fade or 1.0

	local dts = hg.time_to_sec_f(dt)
	local i
	local part_color = hg.Vec4(0.25, 0.75, 1.0, 1.0)

	for i = 1, #particles do
		-- update
		particles[i].age = particles[i].age + dt
		particles[i].pos = particles[i].pos + hg.RandomVec3(-noise_amplitude, noise_amplitude) * dts

		-- draw
		part_color.w = particles[i].alpha * global_fade * map(math.sin(hg.time_to_sec_f(particles[i].age)), -1.0, 1.0, 0.1, 1.0)
		local val_uniforms_dirt = {hg.MakeUniformSetValue('color', part_color)}
		hg.DrawModel(vid, particle_model, particle_shader, val_uniforms_dirt, particle_tex_uniforms, 
					hg.TransformationMat4(particles[i].pos, particles[i].rot), particle_render_state)
	end

	return particles
end

-- hg.ModelBuilder()
function build_random_particles_model(mdl_builder, vtx_layout, particles_amount, radius)
	particles_amount = particles_amount or 1
	radius = radius or 1.0
	local i, j
	for i = 1, particles_amount do
		local a, b, c, d
		local position = hg.Vec3(0.0, 0.0, 0.0)
		for j = 1, 5 do
			position = position + hg.RandomVec3(-radius, radius)
		end
		position = position * hg.Vec3(1.0 / 5.0, 1.0 / 5.0, 1.0 / 5.0)
		local vertex0 = hg.Vertex()
		vertex0.pos = hg.Vec3(-0.5 + position.x, - 0.5 + position.y, position.z)
		vertex0.normal = hg.Vec3(0, 0, -1)
		vertex0.uv0 = hg.Vec2(0, 0)
		a = mdl_builder:AddVertex(vertex0)
		local vertex1 = hg.Vertex()
		vertex1.pos = hg.Vec3(-0.5 + position.x, 0.5 + position.y, position.z)
		vertex1.normal = hg.Vec3(0, 0, -1)
		vertex1.uv0 = hg.Vec2(0, 1)
		b = mdl_builder:AddVertex(vertex1)
		local vertex2 = hg.Vertex()
		vertex2.pos = hg.Vec3(0.5 + position.x, 0.5 + position.y, position.z)
		vertex2.normal = hg.Vec3(0, 0, -1)
		vertex2.uv0 = hg.Vec2(1, 1)
		c = mdl_builder:AddVertex(vertex2)
		local vertex3 = hg.Vertex()
		vertex3.pos = hg.Vec3(0.5 + position.x, -0.5 + position.y, position.z)
		vertex3.normal = hg.Vec3(0, 0, -1)
		vertex3.uv0 = hg.Vec2(1, 0)
		d = mdl_builder:AddVertex(vertex3)
		mdl_builder:AddQuad(d, c, b, a)
	end
	mdl_builder:EndList(0)
	local mdl = mdl_builder:MakeModel(vtx_layout)
	return mdl
end