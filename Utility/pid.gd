extends RefCounted
class_name PID

#don't use this if possible, it's unreasonably hard to tune
# and tends to diverge if you mess up even a tiny bit

var _pweight: float 
var _iweight: float 
var _dweight: float 

var _errorB #error from last time
var _errorC #error from the time before that

var _starting = false #need to alter behavior on first 2 passes,
var _started  = false #otherwise won't have enough info

var _ierror #integral error helps steady state error = 0 (e.g. overcome force)
var _derror #derivative error helps with less overshooting

var _result #weighted total error


func _init(p: float, i: float, d: float) -> void:
	_pweight = p
	_iweight = i
	_dweight = d


func _swap(_errorA) -> void:
	_errorC = _errorB
	_errorB = _errorA


func update(_errorA, delta: float):
	
	#perform a type check on every update() but the first
	if _starting: 
		assert(is_instance_of(_errorA, typeof(_errorB)), #error message below
				"PID update() called with mismatched type.")
	
	if _started:      #all  3 points available, use 3-point backwards difference
		_ierror = _errorA * delta
		_derror = (_errorC - 4*_errorB + 3*_errorA) / (2*delta) #<-(3pt bw. d.)
		
		_result = _pweight*_errorA + _iweight*_ierror + _dweight*_derror
	else:
		if _starting: #only 2 points available, use classic difference formula
			_started = true #next time we'll have 3 available
			
			_ierror = _errorA * delta
			_derror = (_errorA - _errorB) / delta #<- (classic difference)
			
			_result = _pweight*_errorA + _iweight*_ierror + _dweight*_derror
		else:         #only 1 point  available, try to return zero
			_starting = true #next time we'll have 2 available
			
			#try to match type but just return the function input if not possible
			match typeof(_errorA):
				TYPE_FLOAT:
					_result = 0.0
				TYPE_VECTOR2:
					_result = Vector2(0.0, 0.0)
				TYPE_VECTOR3:
					_result = Vector3(0.0, 0.0, 0.0)
				_:
					print("WARNING: Only intended PID types are float, "
							+ "Vector2, and Vector3.")
					_result = _errorA
	
	#one last check for my peace of mind
	#assert(is_instance_of(_result, typeof(_errorA)), 
			#"U did something wrong in PID bro...")
	
	#Finally, function input is history. update errorB and errorC, then return
	_swap(_errorA)
	return _result
