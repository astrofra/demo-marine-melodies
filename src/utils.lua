function map(value, min1, max1, min2, max2)
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
end

function clamp(value, min1, max1)
    return math.min(math.max(value, min1), max1)
end

-- Smoothing rate dictates the proportion of source remaining after one second
-- from https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
function dtAwareDamp(source, target, smoothing, dt)
    return hg.Lerp(source, target, 1.0 - (smoothing^dt))
end

function resolution_multiplier(w, h, m)
    return math.floor(w * m), math.floor(h * m)
end

function rand_angle()
    local a = math.random() * math.pi
    if math.random() > 0.5 then
        return a
    else
        return -a
    end
end

function EaseInOutQuick(x)
	x = clamp(x, 0.0, 1.0)
	return	(x * x * (3 - 2 * x))
end

function IsLinux()
    if package.config:sub(1,1) == '/' then
        return true
    else
        return false
    end
end