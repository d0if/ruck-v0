extends Node


func approach_angle(current: float, target: float, rate: float = 0.1):
	#normal easing doesn't work since we have angles capped between 0/2PI. Find closest +-2PI and approach it
	var diff = target - current
	var result
	if diff > PI: #would be easier to approach -PI/4 from 0 instead of 7PI/4
		result = (current + rate * (diff - 2*PI))
	elif diff < -PI: #would be easier to approach 9PI/4 from 2PI instead of PI/4
		result = (current + rate * (diff + 2*PI))
	else: result = (current + rate * diff)
	#
	return cap_radians(result)
		
func cap_radians(angle: float):
	#assuming the angle is already within +- 2PI
	if angle < 0:
		angle += 2.0*PI
	elif angle >= 2.0*PI:
		angle -= 2.0*PI
	return angle
