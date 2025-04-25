extends Node

func approach_angle_ease(current: float, target: float, rate: float = 0.1, error: float = 0.001):
	#normal easing doesn't work since we have angles capped between 0/2PI. Find closest +-2PI and approach it
	if rate >= 1.0: return target
	var diff = target - current
	if abs(diff) < abs(error): return target
	var result
	if diff > PI: #would be easier to approach -PI/4 from 0 instead of 7PI/4
		result = (current + rate * (diff - 2*PI))
	elif diff < -PI: #would be easier to approach 9PI/4 from 2PI instead of PI/4
		result = (current + rate * (diff + 2*PI))
	else: result = (current + rate * diff)
	#
	return cap_radians(result)

func approach_ease(current: float, target: float, rate: float = 0.1, error: float = 0.001):
	#normal easing
	if rate >= 1.0: return target
	var dist = target - current
	if abs(dist) < abs(error): return target
	else: return current + rate * dist

func approach_line(current: float, target: float, rate: float = 0.1):
	if rate < 0.0: rate = abs(rate) #enforce positive rate
	var dist = target - current #can be negative
	if rate > abs(dist):
		return target
	else:
		if dist < 0.0:
			return current - rate
		else:
			return current + rate

func approach_ease_capdelta(current: float, target: float, rate: float = 0.1, max_delta: float = 0.01, error: float = 0.001):
	#use normal easing if we would be making a change greater than max_delta, otherwise use straightline
	if rate >= 1.0: return target
	var dist = target - current
	if abs(dist * rate) >= max_delta:
		return approach_line(current, target, max_delta)
	else:
		return approach_ease(current, target, rate, error)

func cap_radians(angle: float, start: float = 0.0):
	#put any angle within the range [start, start+2PI]
	#assuming the angle is already within +- 2PI of [start, start+2PI]. 
	#reasonable assumption for camera movement & such
	if angle < start:
		angle += 2.0*PI
	elif angle >= start + 2.0*PI:
		angle -= 2.0*PI
	return angle

func cap_above(current: float, cap: float):
	if current > cap:
		return cap
	else:
		return current

func cap_below(current: float, cap: float):
	if current < cap:
		return cap
	else:
		return current

func cap_above_ease(current: float, ease_cap: float, rate: float = 0.1, error: float = 0.001):
	if current > ease_cap:
		return approach_ease(current, ease_cap, rate, error)
	else:
		return current

func cap_below_ease(current: float, ease_cap: float, rate: float = 0.1, error: float = 0.001):
	if current < ease_cap:
		return approach_ease(current, ease_cap, rate, error)
	else:
		return current

func cap_above_line(current: float, line_cap: float, rate: float = 0.1):
	if current > line_cap:
		return approach_line(current, line_cap, rate)
	else:
		return current

func cap_below_line(current: float, line_cap: float, rate: float = 0.1):
	if current < line_cap:
		return approach_line(current, line_cap, rate)
	else:
		return current
