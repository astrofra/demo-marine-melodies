import harfang as hg
from math import pi, pow
from random import random, uniform

def lua_rand(a=None, b=None):
    if a is None and b is None:
        return random()
    if a is not None and b is None:
        return int(uniform(1.0, a))
    return int(uniform(a, b))


def remap(value, min1, max1, min2, max2):
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1)
# end

def clamp(value, min1, max1):
    return min(max(value, min1), max1)
# end

# Smoothing rate dictates the proportion of source remaining after one second
# from https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
def dtAwareDamp(source, target, smoothing, dt):
    return hg.Lerp(source, target, 1.0 - pow(smoothing, dt))
# end


def resolution_multiplier(w, h, m):
    return int(w * m), int(h * m)
# end


def rand_angle():
    a = lua_rand() * pi
    if lua_rand() > 0.5:
        return a
    else:
        return -a
#     end
# end

def EaseInOutQuick(x):
	x = clamp(x, 0.0, 1.0)
	return	(x * x * (3 - 2 * x))
# end