-- boids fish simulation

function draw_min_max_box(vid, vtx_line_layout, min_max, particle_shader)
    -- draw min max
    local vtx = hg.Vertices(vtx_line_layout, 5)
    vtx:Begin(0):SetPos(hg.Vec3(min_max.mn.x, min_max.mn.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(hg.Vec3(min_max.mx.x, min_max.mn.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(2):SetPos(hg.Vec3(min_max.mx.x, min_max.mx.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(3):SetPos(hg.Vec3(min_max.mn.x, min_max.mx.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(4):SetPos(hg.Vec3(min_max.mn.x, min_max.mn.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)

    local vtx = hg.Vertices(vtx_line_layout, 5)
    vtx:Begin(0):SetPos(hg.Vec3(min_max.mn.x, min_max.mn.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(hg.Vec3(min_max.mx.x, min_max.mn.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(2):SetPos(hg.Vec3(min_max.mx.x, min_max.mx.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(3):SetPos(hg.Vec3(min_max.mn.x, min_max.mx.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(4):SetPos(hg.Vec3(min_max.mn.x, min_max.mn.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)

    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(hg.Vec3(min_max.mx.x, min_max.mx.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(hg.Vec3(min_max.mx.x, min_max.mx.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)

    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(hg.Vec3(min_max.mx.x, min_max.mn.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(hg.Vec3(min_max.mx.x, min_max.mn.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)

    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(hg.Vec3(min_max.mn.x, min_max.mx.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(hg.Vec3(min_max.mn.x, min_max.mx.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)

    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(hg.Vec3(min_max.mn.x, min_max.mn.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(hg.Vec3(min_max.mn.x, min_max.mn.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)

    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(hg.Vec3(min_max.mx.x, min_max.mn.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(hg.Vec3(min_max.mx.x, min_max.mx.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)

    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(hg.Vec3(min_max.mx.x, min_max.mn.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(hg.Vec3(min_max.mx.x, min_max.mx.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)

    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(hg.Vec3(min_max.mn.x, min_max.mn.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(hg.Vec3(min_max.mn.x, min_max.mx.y, min_max.mx.z)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)

    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(hg.Vec3(min_max.mn.x, min_max.mn.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(hg.Vec3(min_max.mn.x, min_max.mx.y, min_max.mn.z)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)
end

function draw_cross(vid, vtx_line_layout, pos, particle_shader, size)
    size = size or 1.0
    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(pos + hg.Vec3(-5 * size, 0, 0)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(pos + hg.Vec3(5 * size, 0, 0)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)
    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(pos + hg.Vec3(0, -5 * size, 0)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(pos + hg.Vec3(0, 5 * size, 0)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)
    local vtx = hg.Vertices(vtx_line_layout, 2)
    vtx:Begin(0):SetPos(pos + hg.Vec3(0, 0, -5 * size)):SetColor0(hg.Color.Red):End()
    vtx:Begin(1):SetPos(pos + hg.Vec3(0, 0, 5 * size)):SetColor0(hg.Color.Red):End()
    hg.DrawLines(vid, vtx, particle_shader)
end

function boids_update_draw(vid, vtx_line_layout, dt, boids, min_max, scene, physics, particle_shader, boid_center_node)
	local dts = hg.time_to_sec_f(dt)
	local i
    -- local min_max = hg.MinMax(hg.Vec3(-20, 0, -20), hg.Vec3(20, 15, 100))
    local bb_center = (min_max.mn + min_max.mx) * 0.5
    local speed = 3.0
    local length = 1.0
    local center = hg.Vec3(0,0,0)
    local main_dir = boids[1].dir
    local max_dist = hg.Dist(min_max.mn, min_max.mx)
    local _vec_up = hg.Vec3(0.0, 1.0, 0.0)

    local dir_avoidance = hg.Vec3()

    -- draw_min_max_box(vid, vtx_line_layout, min_max, particle_shader)

    -- compute the center of the boid
    for i = 1, #boids do
        center = center + boids[i].pos
    end
    center = center * (1.0 / #boids)

    if boid_center_node then
        physics:NodeWake(boid_center_node)
        -- boid_center_node:GetTransform():SetPos(center)
        local _dir = center - hg.GetTranslation(boid_center_node:GetTransform():GetWorld())
        physics:NodeAddForce(boid_center_node, _dir * 0.1)
        physics:NodeAddImpulse(boid_center_node, (physics:NodeGetLinearVelocity(boid_center_node) - (_dir * hg.Vec3(0.0, 1.0, 0.0))) * hg.Vec3(0.0, -1.0, 0.0))
    end

    center = hg.GetTranslation(boid_center_node:GetTransform():GetWorld())

    -- update and draw
	for i = 1, #boids do
		-- update
        boids[i].age = boids[i].age + dt
		boids[i].pos = boids[i].pos + boids[i].dir * dts * speed
        local pos_anticipation = boids[i].pos + boids[i].dir * dts * speed
        local color = hg.Color.White

        if hg.Contains(min_max, pos_anticipation) then
            local age_s = hg.time_to_sec_f(boids[i].age) * 60.0 + (i * 10)
            -- color = hg.Lerp(hg.Color.Blue, hg.Color.White, clamp(math.fmod(math.floor(age_s), 30) / 30.0, 0.0, 1.0))

            -- random direction
            if math.fmod(math.floor(age_s), 30) == 0 then
                dir_avoidance.x = math.random(-100, 100) / 200.0
                dir_avoidance.y = math.random(-100, 100) / 200.0
                dir_avoidance.z = math.random(-100, 100) / 200.0
                boids[i].target_dir = hg.Lerp(boids[i].target_dir, dir_avoidance, 0.5)
                boids[i].target_dir = hg.Normalize(boids[i].target_dir)
            end
            boids[i].dir = hg.Normalize(hg.Lerp(boids[i].dir, boids[i].target_dir, clamp(0.05 * dts * 60.0, 0.0, 1.0)))

            -- cohesion direction
            dir_avoidance = center - boids[i].pos
            boids[i].dir = hg.Normalize(hg.Lerp(boids[i].dir, dir_avoidance, clamp(0.005 * dts * 60.0, 0.0, 1.0)))
            boids[i].dir = hg.Normalize(hg.Lerp(boids[i].dir, main_dir, clamp(0.075 * dts * 60.0, 0.0, 1.0))) 
            
            -- avoid ground & landscape
            local ray_len = 2.5
            local hit = physics:RaycastFirstHit(scene, boids[i].pos, boids[i].pos + (boids[i].dir * ray_len))
            color = hg.Color.Yellow

            if hit.t > 0.0 and hit.t < ray_len then

                -- look for a way up
                local _new_dir = hg.GetRow(boids[i].transform:GetWorld(), 1)
                _new_dir = hg.Normalize(hg.Vec3(_new_dir.x, _new_dir.y, _new_dir.z))

                hit = physics:RaycastFirstHit(scene, boids[i].pos, boids[i].pos + (_new_dir * ray_len))

                if hit.t > 0.0 and hit.t < ray_len then
                    -- look for a way left
                    _new_dir = hg.GetRow(boids[i].transform:GetWorld(), 0)
                    _new_dir = hg.Normalize(hg.Vec3(_new_dir.x, _new_dir.y, _new_dir.z))
                    hit = physics:RaycastFirstHit(scene, boids[i].pos, boids[i].pos + (_new_dir * ray_len))

                    if hit.t > 0.0 and hit.t < ray_len then
                        -- look for a way right
                        _new_dir = _new_dir * -1.0
                        hit = physics:RaycastFirstHit(scene, boids[i].pos, boids[i].pos + (_new_dir * ray_len))

                        if hit.t > 0.0 and hit.t < ray_len then
                            -- go backward
                            _new_dir = hg.Normalize(boids[i].dir) * -1.0
                        end
                    end
                end

                -- boids[i].dir = _new_dir
                boids[i].dir = hg.Normalize(hg.Lerp(boids[i].dir, _new_dir, clamp(0.5 * dts * 60.0, 0.0, 1.0)))

                -- draw_cross(vid, vtx_line_layout, hit.P, particle_shader, 0.1)
                -- color = hg.Color.Red

                -- local vtx = hg.Vertices(vtx_line_layout, 2)
                -- vtx:Begin(0):SetPos(boids[i].pos):SetColor0(hg.Color.Purple):End()
                -- vtx:Begin(1):SetPos(boids[i].pos + (_new_dir * ray_len)):SetColor0(hg.Color.Purple):End()
                -- hg.DrawLines(vid, vtx, particle_shader)
                -- print(hit.node:GetName())
            end

            -- local vtx = hg.Vertices(vtx_line_layout, 2)
            -- vtx:Begin(0):SetPos(boids[i].pos):SetColor0(color):End()
            -- vtx:Begin(1):SetPos(boids[i].pos + boids[i].dir * ray_len):SetColor0(color):End()
            -- hg.DrawLines(vid, vtx, particle_shader)
        else
            color = hg.Color.Red
            boids[i].age = hg.time_from_sec_f(0.0)
            if pos_anticipation.x > min_max.mx.x then
                dir_avoidance.x = -(math.abs(pos_anticipation.x - min_max.mx.x) + 1.0)
            elseif pos_anticipation.x < min_max.mn.x then
                dir_avoidance.x = math.abs(pos_anticipation.x - min_max.mn.x) + 1.0
            end
            if pos_anticipation.y > min_max.mx.y then
                dir_avoidance.y = -(math.abs(pos_anticipation.y - min_max.mx.y) + 1.0)
            elseif pos_anticipation.y < min_max.mn.y then
                dir_avoidance.y = math.abs(pos_anticipation.y - min_max.mn.y) + 1.0
            end
            if pos_anticipation.z > min_max.mx.z then
                dir_avoidance.z = -(math.abs(pos_anticipation.z - min_max.mx.z) + 1.0)
            elseif pos_anticipation.z < min_max.mn.z then
                dir_avoidance.z = math.abs(pos_anticipation.z - min_max.mn.z) + 1.0
            end

            boids[i].dir = hg.Normalize(hg.Lerp(boids[i].dir, dir_avoidance, 0.01 * dts * 60.0))

            -- local vtx = hg.Vertices(vtx_line_layout, 2)
            -- vtx:Begin(0):SetPos(boids[i].pos):SetColor0(hg.Color.Yellow):End()
            -- vtx:Begin(1):SetPos(boids[i].pos + dir_avoidance):SetColor0(hg.Color.Yellow):End()
            -- hg.DrawLines(vid, vtx, particle_shader)
        end

		-- draw points or move nodes
        local fish_node = boids[i].node
        if fish_node then
            -- geometry based fish (tied to a node)
            -- boids[i].transform:SetPos(boids[i].pos)
            local mfish = hg.Mat4LookAt(boids[i].pos, boids[i].pos + boids[i].dir) -- , _vec_up)
            hg.SetTranslation(mfish, boids[i].pos)
            boids[i].transform:SetWorld(mfish)
        else
            -- no node, we draw a simpe line!
            -- local vtx = hg.Vertices(vtx_line_layout, 2)
            -- vtx:Begin(0):SetPos(boids[i].pos - boids[i].dir * length * 0.5):SetColor0(color):End()
            -- vtx:Begin(1):SetPos(boids[i].pos + boids[i].dir * length * 0.5):SetColor0(color):End()
            -- hg.DrawLines(vid, vtx, particle_shader)
        end
	end

	return boids
end