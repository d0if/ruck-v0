extends Node

func approach_angle_ease(current: float, target: float, rate: float = 0.1, error: float = 0.001):
	#normal easing doesn't work since we have angles capped between 0/2PI. Find closest +-2PI and approach it
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
