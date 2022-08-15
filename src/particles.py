import harfang as hg
from utils import *
from math import pi, cos, sin

# organic particles laying at the bottom of the sea

def particles_update_draw(vid, vtx_line_layout, dt, particles, particle_shader, noise_amplitude=1.0):
	dts = hg.time_to_sec_f(dt)
	# i

	for i in range(len(particles)):
		# update
		particles[i]["age"] = particles[i]["age"] + dt
		particles[i]["pos"] = particles[i]["pos"] + hg.RandomVec3(-noise_amplitude, noise_amplitude) * dts

		# draw
		# points
		vtx = hg.Vertices(vtx_line_layout, 2)
		vtx.Begin(0).SetPos(particles[i]["pos"]).SetColor0(hg.Color.White).End()
		vtx.Begin(1).SetPos(particles[i]["pos"] + hg.RandomVec3(-1/5, 1/5)).SetColor0(hg.Color.White).End()
		hg.DrawLines(vid, vtx, particle_shader)
	# end

	return particles
# end

def particles_update_draw_model(vid, dt, particles, particle_model, particle_shader, particle_uniforms, particle_tex_uniforms, particle_render_state, noise_amplitude=1.0, global_fade=1.0):
	dts = hg.time_to_sec_f(dt)
	part_color = hg.Vec4(0.25, 0.75, 1.0, 1.0)

	for i in range(len(particles)):
		# update
		particles[i]["age"] = particles[i]["age"] + dt
		particles[i]["pos"] = particles[i]["pos"] + hg.RandomVec3(-noise_amplitude, noise_amplitude) * dts

		# draw
		part_color.w = particles[i]["alpha"] * global_fade * remap(sin(hg.time_to_sec_f(particles[i]["age"])), -1.0, 1.0, 0.1, 1.0)
		val_uniforms_dirt = [hg.MakeUniformSetValue('color', part_color)]
		hg.DrawModel(vid, particle_model, particle_shader, val_uniforms_dirt, particle_tex_uniforms, 
					hg.TransformationMat4(particles[i]["pos"], particles[i]["rot"]), particle_render_state)
	# end

	return particles
# end

# hg.ModelBuilder()
def build_random_particles_model(mdl_builder, vtx_layout, particles_amount=1, radius=1.0):
	# particles_amount = particles_amount or 1
	# radius = radius or 1.0
	# i, j
	for i in range(particles_amount):
		# a, b, c, d
		position = hg.Vec3(0.0, 0.0, 0.0)
		for j in range(5):
			position = position + hg.RandomVec3(-radius, radius)
		# end
		position = position * hg.Vec3(1.0 / 5.0, 1.0 / 5.0, 1.0 / 5.0)
		vertex0 = hg.Vertex()
		vertex0.pos = hg.Vec3(-0.5 + position.x, - 0.5 + position.y, position.z)
		vertex0.normal = hg.Vec3(0, 0, -1)
		vertex0.uv0 = hg.Vec2(0, 0)
		a = mdl_builder.AddVertex(vertex0)
		vertex1 = hg.Vertex()
		vertex1.pos = hg.Vec3(-0.5 + position.x, 0.5 + position.y, position.z)
		vertex1.normal = hg.Vec3(0, 0, -1)
		vertex1.uv0 = hg.Vec2(0, 1)
		b = mdl_builder.AddVertex(vertex1)
		vertex2 = hg.Vertex()
		vertex2.pos = hg.Vec3(0.5 + position.x, 0.5 + position.y, position.z)
		vertex2.normal = hg.Vec3(0, 0, -1)
		vertex2.uv0 = hg.Vec2(1, 1)
		c = mdl_builder.AddVertex(vertex2)
		vertex3 = hg.Vertex()
		vertex3.pos = hg.Vec3(0.5 + position.x, -0.5 + position.y, position.z)
		vertex3.normal = hg.Vec3(0, 0, -1)
		vertex3.uv0 = hg.Vec2(1, 0)
		d = mdl_builder.AddVertex(vertex3)
		mdl_builder.AddQuad(d, c, b, a)
	# end
	mdl_builder.EndList(0)
	mdl = mdl_builder.MakeModel(vtx_layout)
	return mdl
# end