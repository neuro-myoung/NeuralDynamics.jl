"""
	initializeParams(model::String; args...)
	
Creates a dictionary of parameters for a defined model. In the absence of optional arguments the model will be initialized with default parameter values. If some optional arguments are passed they will replace those default values in the dictionary. Currently implemented models include:
	
- "FHN": FitzHugh-Nagumo
- "SFF": Simple Feed-forward
- "WC": Wilson-Cowan
	
# Examples
	
```jldoctest
julia> params = initializeParams("FHN")
Dict{Symbol, Float64} with 7 entries:
 :R     => 1
 :tau1  => 1.0
 :tau2  => 2.0
 :I     => 0
 :b1    => 1.1
 :b0    => 0.9
	
julia> params = initializeParams("FHN", tau1 = 5.0, b1 = 2.0)
Dict{Symbol, Float64} with 7 entries:
 :R     => 1
 :tau1  => 5.0
 :tau2  => 2.0
 :I     => 0
 :b1    => 2.0
 :b0    => 0.9
```

# Note

Check the documentation for a given model in the docs to see what parameters 
are required.
"""
function initializeParams(model::String; input=0, args...)
		
	# Check model call
	if model == "FHN"
		# Initialize default dictionary
		defaultDict = Dict([:tau1=>1.0, :tau2=>2.0, :b0=>0.9, 
						    :b1=>1.1, :R=>1, :I=>input])
	
	elseif model == "SFF"
		defaultDict = Dict([:tau=>1.0, :a=>1.2, :theta=>2.8, :w=>0.0, :I=>input])
	
	elseif model == "WC"
		if input == 0
			defaultDict = Dict([:tauE=>1.0, :aE=>1.2, :thetaE=>2.8, :tauI=>2.0,
			:aI=>1.0, :thetaI=>4.0, :wEE=>9.0, :wEI=>4.0, :wIE=>13.0, :wII=>11.0,
			:IE=>input, :II=>input])
		else
			defaultDict = Dict([:tauE=>1.0, :aE=>1.2, :thetaE=>2.8, :tauI=>2.0,
			:aI=>1.0, :thetaI=>4.0, :wEE=>9.0, :wEI=>4.0, :wIE=>13.0, :wII=>11.0,
			:IE=>input[1], :II=>input[2]])
		end
	else
		error("Sorry, that model is not currently implemented. See documentation 
			for available models.")
	end

	## Check for user defined values
	if length(args) == 0
		return defaultDict
	else 
		# Reassign values from args...
		for arg in args
			defaultDict[arg[1]] = arg[2]
		end
		
		return defaultDict
	end
end

"""
	modelEquations(name::String)
	modelEquations(name::String, DEs, nullclines)
	
Generates a struct of type `modelEquations` containing the model name, differential
equations, and nullcline equations. Custom models can be built by inputting your own
equations. Some models are automatically implemented and the relevant struct will be
returned just by calling these models by name. Currently implemented models include:
	
- "FHN": FitzHugh-Nagumo
- "WC": Wilson-Cowan
	
# Examples
	
```jldoctest
julia> mdl=modelEquations("FHN")
modelEquations("FHN", (NeuralDynamics.fhn_dudt, NeuralDynamics.fhn_dwdt), (NeuralDynamics.fhn_nullclinewu, NeuralDynamics.fhn_nullclineww))
	
julia> mdl=modelEquations("WC")
modelEquations("WC", (NeuralDynamics.wc_drₑ, NeuralDynamics.wc_drᵢ), (NeuralDynamics.wc_eNullcline, NeuralDynamics.wc_iNullcline))
```
"""
struct modelEquations
	name::String
	DEs::Tuple
	nullclines::Tuple
end

function modelEquations(name::String)
	if name == "FHN"
		return modelEquations(name, (fhn_dudt, fhn_dwdt), (fhn_nullclinewu,fhn_nullclineww))
	elseif name == "WC"
		return modelEquations(name, (wc_drₑ, wc_drᵢ), (wc_eNullcline, wc_iNullcline))
	else
		error("Input a built-in model designation or custom model equations.")
	end
end