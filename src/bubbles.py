## bubbles particles

import harfang as hg
from utils import *
from math import pi, cos, sin

default_spawn_interval = 1.0 / 2.0 # in seconds
default_random_spawn_interval = 1.0 # factor of randomness of the spawn frequency (0.0 = no randomness)
max_age = hg.time_from_sec_f(10.0) # in seconds

def bubbles_update_draw(scene, res, info, bubble_instance, dt, bubbles, emitter_matrix, emitter_velocity, spawn_interval=default_spawn_interval, random_spawn_interval=default_random_spawn_interval):

    # spawn_interval = spawn_interval or default_spawn_interval
    # random_spawn_interval = random_spawn_interval or default_random_spawn_interval

    dts = hg.time_to_sec_f(dt)
    gravity = hg.Vec3(0.0, 2.0, 0.0) # drag bubble to the surface
    v_oscillation = hg.Vec3(0, 0, 0) # simulate water resistance
    scale_vector = hg.Vec3(1, 1, 1)
    max_age_f = hg.time_to_sec_f(max_age)

    to_remove = []

    # update existing particles
    for i in range(len(bubbles["particles"])):
        # move it
        # vel_norm # = 0.0
        # if hg.Len2(bubbles["particles"][i]["vel"]) > 0.00001 then
            # bubbles["particles"][i]["vel"] = bubbles["particles"][i]["vel"] - (bubbles["particles"][i]["vel"] * dts) # damp velocity
        vel_norm = hg.Len(bubbles["particles"][i]["vel"])
        vel_norm = dtAwareDamp(vel_norm, 0.0, 0.1, dts)
        bubbles["particles"][i]["vel"] = hg.Normalize(bubbles["particles"][i]["vel"]) * vel_norm
            # vel_norm = clamp(remap(hg.Len2(bubbles["particles"][i]["vel"]), 0.0, 0.0001, 0.0, 1.0), 0.0, 1.0)
            # vel_norm = remap(hg.Len2(bubbles["particles"][i]["vel"]), 0.0, 0.0001, 0.0, 1.0)
        # end
        bubbles["particles"][i]["pos"] = bubbles["particles"][i]["pos"] + bubbles["particles"][i]["vel"] * dts * 60.0 # bubble ejection speed
        bubbles["particles"][i]["pos"] = bubbles["particles"][i]["pos"] + gravity * dts * (1.0 - vel_norm) # bubble going to the surface
        v_phase = hg.time_to_sec_f(bubbles["particles"][i]["age"]) + (sin(hg.time_to_sec_f(bubbles["particles"][i]["age"]) * 2.1245) + 1.0)
        v_phase = v_phase * (bubbles["particles"][i]["seed"] + 0.5)
        v_oscillation.x = sin(v_phase)
        v_oscillation.y = (sin(v_phase * 1.542874) + 1.0)
        v_oscillation.z = cos(v_phase)
        bubbles["particles"][i]["pos"] = bubbles["particles"][i]["pos"] + v_oscillation * dts * (1.0 - vel_norm) # bubble going to the surface

        bubbles["particles"][i]["transform"].SetPos(bubbles["particles"][i]["pos"])

        # scale it
        scale_factor = clamp(remap(bubbles["particles"][i]["age"], 0.0, max_age / 10.0, 0.2, 1.0), 0.2, 1.0)
        scale_factor = scale_factor * clamp(remap(bubbles["particles"][i]["age"], max_age - (max_age / 10.0), max_age, 1.0, 0.0), 0.0, 1.0)
        scale_vector.x = scale_factor
        scale_vector.y = scale_factor
        scale_vector.z = scale_factor
        bubbles["particles"][i]["transform"].SetScale(scale_vector)

        # make it older
        bubbles["particles"][i]["age"] = bubbles["particles"][i]["age"] + dt
        if bubbles["particles"][i]["age"] > max_age:
            # delete particle
            scene.DestroyNode(bubbles["particles"][i]["node"])
            scene.GarbageCollect()
            # print(scene.GetAllNodes():size())
            to_remove.append(i)
    #     end
    # end

    # remove the deleted particles from the list
    for i in range(len(to_remove)):
        del bubbles["particles"][to_remove[i]]
    # end

    bubbles["emitter"]["spawn_timeout"] = bubbles["emitter"]["spawn_timeout"] + dt

    # spawn new particles if possible
    if spawn_interval > 0.0 and bubbles["emitter"]["spawn_timeout"] > hg.time_from_sec_f(spawn_interval):
        new_bubble_node = scene.CreateNode("bubble")
        p = hg.GetTranslation(emitter_matrix)
        t = scene.CreateTransform(p)
        t.SetScale(hg.Vec3(0,0,0))
        new_bubble_node.SetTransform(t)
        new_bubble_node.SetInstance(bubble_instance.GetInstance())
        new_bubble_node.SetupInstanceFromAssets(res, info)
        # randomize spawn interval
        _r_sp_i = remap(lua_rand(), 0.0, 1.0, -0.5 * random_spawn_interval * spawn_interval, 0.5 * random_spawn_interval * spawn_interval)
        bubbles["emitter"]["spawn_timeout"] = hg.time_from_sec_f(_r_sp_i)

        # add the new particle to the main table
        bubbles["particles"].append({"node":new_bubble_node, "transform":t, "pos":p, "vel":emitter_velocity, "seed":lua_rand(), "age":hg.time_from_sec_f(0)})
    # end

    return bubbles
# end