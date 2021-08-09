"""
	getNullclines(x, modelEqs, params::Dict)

	getNullclines(x, y, modelEqs, params::Dict)
	
Determines the nullclines of the defined model over the sampled space using the 
dictionary of model parameters and struct containing the model equations. 

The nullcine of ``x`` with respect to some parameter ``t`` is defined as the 
points along the phase plane were `` \\frac{dx}{dt} = 0``.

# Example
	
```jldoctest
julia> params = initializeParams("FHN")
Dict{Symbol, Float64} with 7 entries:
 :R     => 1
 :tau1  => 1.0
 :tau2  => 2.0
 :I     => 0
 :b1    => 1.1
 :b0    => 0.9

julia> mdl = modelEquations("FHN")
 modelEquations("FHN", (NeuralDynamics.fhn_dudt, NeuralDynamics.fhn_dwdt), (NeuralDynamics.fhn_nullclinewu, NeuralDynamics.fhn_nullclineww))

julia> ncls = getNullclines(-2.5:0.01:2.5, mdl, params)

julia> params = initializeParams("WC")
Dict{Symbol, Float64} with 12 entries:
  :tauE   => 1.0
  :wEE    => 9.0
  :wIE    => 13.0
  :thetaE => 2.8
  :wEI    => 4.0
  :wII    => 11.0
  :tauI   => 2.0
  :aE     => 1.2
  :aI     => 1.0
  :II     => 0.0
  :thetaI => 4.0
  :IE     => 0.0

julia> mdl = modelEquations("WC")
 modelEquations("WC", (NeuralDynamics.wc_drₑ, NeuralDynamics.wc_drᵢ), (NeuralDynamics.wc_eNullcline, NeuralDynamics.wc_iNullcline))

julia> ncls = getNullclines((-0.01:0.001:0.96, -0.01:0.001:0.8), mdl, params)
```
"""
function getNullclines(x, modelEqs, params::Dict)

	ncls = []
	for i in eachindex(modelEqs.nullclines)
		push!(ncls, modelEqs.nullclines[i](x, params))
	end
	
	return ncls
end

function getNullclines(x, y, modelEqs, params::Dict) #Fix

	inputs=[x, y]
	ncls = []
	for i in eachindex(modelEqs.nullclines)
		push!(ncls, modelEqs.nullclines[i](inputs[i], params))
	end
	
	return ncls
end

"""
	getVectorFields(x, modelEqs ,params::Dict; subdivisions::Int64=10)
	
Given an array of x-indices (and optionally y-indices), a model, and a 
dictionary of model parameters a `Vector` of 2D arrays will be returned with the 
local x and y gradients at evenly sampled points across the defined space. The 
granularity of sampling is determined by the optional parameter `subdivisions` 
with a default sampling density of 10 resulting in a 10x10 grid of vector 
fields.

# Examples
```jldoctest
julia> params = initializeModel("FHN")
Dict{Symbol, Float64} with 7 entries:
 :R     => 1
 :tau1  => 1.0
 :tau2  => 2.0
 :I     => 0
 :b1    => 1.1
 :b0    => 0.9

julia> mdl = modelEquations("FHN")
 modelEquations("FHN", (NeuralDynamics.fhn_dudt, NeuralDynamics.fhn_dwdt), (NeuralDynamics.fhn_nullclinewu, NeuralDynamics.fhn_nullclineww))

julia> fields = getVectorFields(-2.5:0.01:2.5, mdl)
	
julia> fields = getVectorFields(-2.5:0.01:2.5, mdl, subdivisions=5)

julia> fields = getVectorFields(-2.5:0.01:2.5, -1:0.01:1, mdl, subdivisions=20)
```
"""
function getVectorFields(x, modelEqs ,params::Dict;
	subdivisions::Int64=10)

	xSparse = minimum(x):(maximum(x) - minimum(x))/(subdivisions-1):maximum(x)
	xGrid = xSparse' .* ones(length(xSparse))
	yGrid = xSparse .* ones(length(xSparse))'

	fields = []

	for func in modelEqs.DEs
		push!(fields, func(xGrid, yGrid, params))
	end

	return fields
end

function getVectorFields(x, y, modelEqs ,params::Dict;
	subdivisions::Int64=10)

	xSparse = minimum(x):(maximum(x) - minimum(x))/(subdivisions-1):maximum(x)
	xGrid = xSparse' .* ones(length(xSparse))
	ySparse = minimum(y):(maximum(y) - minimum(y))/(subdivisions-1):maximum(y)
	yGrid = ySparse .* ones(length(ySparse))'

	fields = []

	for func in modelEqs.DEs
		push!(fields, func(xGrid, yGrid, params))
	end

	return fields
end

"""
	findFixedPoints(xGuess::Vector, func, params)
	
Given an array `xGuess` giving initial guesses for fixed points, a helper function
(see below) `func` to find the roots of, and a dictionary of model parameters, 
`params` this function will return a vector of fixed points determined using
Newton's method. Helper functions have been defined for the `"FHN"` and `"WC"`
models and follow the general convention `fFHN!` or `fWC!` respectively. 

# Examples
```jldoctest
julia> params = initializeParams("WC")
Dict{Symbol, Float64} with 12 entries:
  :tauE   => 1.0
  :wEE    => 9.0
  :wIE    => 13.0
  :thetaE => 2.8
  :wEI    => 4.0
  :wII    => 11.0
  :tauI   => 2.0
  :aE     => 1.2
  :aI     => 1.0
  :II     => 0.0
  :thetaI => 4.0
  :IE     => 0.0

julia> guesses = [[0.0,0.0],[0.4,0.2],[0.9,0.6]]
3-element Vector{Vector{Float64}}:
 [0.0, 0.0]
 [0.4, 0.2]
 [0.9, 0.6]


julia> fps = findFixedPoints(guesses, fWC!, params)
3-element Vector{Vector{Float64}}:
 [0.0, 0.0]
 [0.33685240829408575, 0.168419676112977]
 [0.9384304716775121, 0.6724810433274886]
```
"""
function findFixedPoints(xGuess::Vector, func, params)

    zeroArr = repeat([zeros(2)], length(xGuess))
    for i in 1:length(xGuess)
        zeroArr[i] = nlsolve(x -> func(x, params), 
                            xGuess[i], method=:newton).zero
    end
    return zeroArr
end

"""
	getJacobianEigenvalues(fixedPoints, params)
	
Given an array of fixed points and model parameters this function will return the
eigenvalues of the Jacobian matrix for the Wilson-Cowan model. Currently, only the Wilson-
Cowan model equations have been implemented.

``J = \\begin{bmatrix} \\frac{\\partial}{\\partial r_E}G_E(r_E^*, r_I^*) & \\frac{\\partial}{\\partial r_I}G_E(r_E^*, r_I^*) \\\\ \\frac{\\partial}{\\partial r_E}G_I(r_E^*, r_I^*) & \\frac{\\partial}{\\partial r_I}G_I(r_E^*, r_I^*) \\end{bmatrix}``

# Examples
```jldoctest
julia> params = initializeParams("WC")
Dict{Symbol, Float64} with 12 entries:
  :tauE   => 1.0
  :wEE    => 9.0
  :wIE    => 13.0
  :thetaE => 2.8
  :wEI    => 4.0
  :wII    => 11.0
  :tauI   => 2.0
  :aE     => 1.2
  :aI     => 1.0
  :II     => 0.0
  :thetaI => 4.0
  :IE     => 0.0

julia> guesses = [[0.0,0.0],[0.4,0.2],[0.9,0.6]]
3-element Vector{Vector{Float64}}:
 [0.0, 0.0]
 [0.4, 0.2]
 [0.9, 0.6]


julia> fps = findFixedPoints(guesses, fWC!, params)
3-element Vector{Vector{Float64}}:
 [0.0, 0.0]
 [0.33685240829408575, 0.168419676112977]
 [0.9384304716775121, 0.6724810433274886]

 julia> eigenVals = getJacobianEigenvalues(fps, params)
 3-element Vector{Any}:
  ComplexF64[-0.6233838572258439 - 0.1311095729053099im, -0.6233838572258439 + 0.1311095729053099im]
  [-0.8726689790568727, 1.057207976436168]
  [-1.4219741349895596, -0.95956219494619]
 
```
"""
function getJacobianEigenvalues(fixedPoints, params)
    
    eigenvals = []
    
    for i in 1:length(fixedPoints)
        rₑ, rᵢ = fixedPoints[i]
        J= zeros(2,2)

        J[1,1] = (-1 + params[:wEE] * dSigmoid(params[:wEE] * rₑ - params[:wEI] * rᵢ + params[:IE], params[:aE], params[:thetaE]))/params[:tauE]
        J[1,2] = (-params[:wEI] * dSigmoid(params[:wEE] * rₑ - params[:wEI] * rᵢ + params[:IE],params[:aE], params[:thetaE]))/params[:tauE]
        J[2,1] = (params[:wIE] * dSigmoid(params[:wIE] * rₑ - params[:wII] * rᵢ + params[:II],params[:aI], params[:thetaI]))/params[:tauI]
        J[2,2] = (-1 - params[:wII] * dSigmoid(params[:wIE] * rₑ - params[:wII] * rᵢ + params[:II], params[:aI], params[:thetaI]))/params[:tauI]
        push!(eigenvals, eigvals(J))
    end
    return eigenvals 
end

"""
	simulate(t, model::String, params::Dict, init)
	
Given a timecourse of `t` passed as a `Vector` or `StepRange` this function
will simulate the model defined by `model` (`String`) with parameters `params`
(`Dict`) with initial conditions defined in the `init` (`Vector` or `Float`). 
The results are returned as a `Vector`. Currently implemented models are:
	
- "FHN": FitzHugh-Nagumo
- "SFF": Simple Feed-forward
- "WC": Wilson-Cowan

# Examples
```jldoctest
julia> mdl = initializeModel("FHN")
Dict{Symbol, Float64} with 7 entries:
 :R     => 1
 :tau1  => 1.0
 :tau2  => 2.0
 :I     => 0
 :b1    => 1.1
 :b0    => 0.9
	
julia> ru, rw = simulate(0:0.1:50, "FHN", mdl, (-2.0, 1.0))

```
"""
function simulate(t, model::String, params::Dict, init)

	dt = t[2]-t[1]

	if model == "FHN" #FitzHugh-Nagumo Model
    	## Initialize arrays
    	ru = zeros(length(t))
		rw = zeros(length(t))
		ru[1], rw[1] = init
    
    	for i in 1:length(t)-1
        
        	## Calculate derivatives
        	du = dt * fhn_dudt(ru[i], rw[i], params)
        	dw = dt * fhn_dwdt(ru[i], rw[i], params)
    
        	## Update with Euler's method
        	ru[i+1]=ru[i] + du
        	rw[i+1]=rw[i] + dw
    	end
		
		return ru, rw
	elseif model == "SFF"	#Simple Feed-forward Model
		ru = zeros(length(t))
		ru[1] = init
    
    	for i in 1:length(t)-1
        
        	## Calculate derivatives
        	du = dt * sff_drdt.(ru[i], params[:w], params[:I], params[:a], 
				params[:theta], params[:tau])
    
        	## Update with Euler's method
        	ru[i+1]=ru[i] + du
    	end

		return ru
	elseif model == "WC"
		rₑ=zeros(length(t))
		rₑ[1] = init[1]
		rᵢ=zeros(length(t))
		rᵢ[1] = init[2]

		if length(params[:IE]) == 1
			Iₑ = repeat([params[:IE]], length(rₑ))
		else
			Iₑ = params[:IE]
		end

		if length(params[:II]) == 1
			Iᵢ = repeat([params[:II]], length(rᵢ))
		else
			Iᵢ = params[:II]
		end
		
		for i in 1:length(t)-1
			
			## Calculate derivatives
			drdtₑ = dt * wc_drₑ(rₑ[i], rᵢ[i], params, Iₑ[i])
			drdtᵢ = dt * wc_drᵢ(rₑ[i], rᵢ[i], params, Iᵢ[i])
		
			## Update with Euler's method
			rₑ[i+1]=rₑ[i] + drdtₑ
			rᵢ[i+1]=rᵢ[i] + drdtᵢ
		end
		
		return rₑ, rᵢ
	end
end