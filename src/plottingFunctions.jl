## Plotting functions for phase plane analysis

"""
plotTrajectory!(x, y; kwargs...)

Convenient plotting function to add results of a simulation to an existing phase 
plot. It takes the simulation output along the abscissa and ordinate as arguments 
in the form of  two Vectors or StepRanges `x` and `y`.
 
Additional plotting arguments can also be passed as `kwargs...`.

Check Plots.jl for additional information on plot arguments.

# Examples

```
julia> plotTrajectory!(-1:0.1:1, -1:0.1:1)

julia> plotTrajectory!(-1:0.1:1, -1:0.1:1, color=red, label="simulation", xlab="x", ylab="y")
```

For similar functionality see plotTrajectories!
"""
function plotTrajectory!(x::Vector, y::Vector; kwargs...)
    plot!(x, y; kwargs...)
    scatter!([x[1]], [y[1]]; kwargs...,  label=false)
end

"""
plotTrajectories!(t, x, y, model::String, params::Dict; kwargs...)

Convenient plotting function to add results of multiple simulations to an 
existing phase plot. It takes the simulation timecourse `t` (`Vector` or `StepRange`),  
and `x` and  `y` `Vectors` or `StepRanges` defining the sampling in each direction
in phase space respectively. The `model` is defined as a `String` and the model
parameters `param` as a `Dict`. Currently implemented models are:
	
- "FHN": FitzHughNagumo
 
Additional plotting arguments can also be passed as `kwargs...`.

Check Plots.jl for additional information on plot arguments.

# Examples

```
julia> mdl = initializeModel("FHN")
Dict{Symbol, Float64} with 7 entries:
 :R     => 1
 :tau1  => 1.0
 :tau2  => 2.0
 :I     => 0
 :b1    => 1.1
 :b0    => 0.9

julia> plotTrajectories!(0:0.1:50, -2.5:1:2.5, -2.5:1:2.5, "FHN", mdl)

julia> plotTrajectories!(0:0.1:50, -2.5:1:2.5, -2.5:1:2.5, "FHN", mdl, color=:gray, label="simulations")
```

For similar functionality see plotTrajectory!
"""
function plotTrajectories!(t, x, y, model::String, params::Dict; kwargs...)
	r₀Arr = [[i,j] for i in x for j in y]
	
    for coord in r₀Arr
		xTemp, yTemp = simulate(t, model, params, [coord[1], coord[2]])
            
            if coord == r₀Arr[1]
                plot!(xTemp, yTemp; kwargs...)
            else
                plot!(xTemp, yTemp; kwargs..., legend=:none)
            end
    end
end

"""
    plotVectorFields!(x, fields::Tuple; arrowScale=0.2, kwargs...)
	
Convenient plotting function to add vector fields to an existing phase plot. It 
takes a single vector `x` as input (for symmetrical axes) or two vectors `x` and 
`y` for unique axis ranges. The fields should be passed as a vector of 2D arrays 
giving the `x` and `y` gradients respectively. 

The `arrowScale` defaults to 0.2 but can be passed as an optional argument. 
Additional plotting arguments can also be passed as `kwargs...`.

Check Plots.jl for additional information on plot arguments.

# Examples
	
```
julia> plotVectorFields!(-1:0.1:1, ([3 2 3; 2 1 2; 3 2 3], [3 2 3; 2 1 2; 3 2 3]))

julia> plotVectorFields!(-1:0.1:1, ([3 2 3; 2 1 2; 3 2 3], [3 2 3; 2 1 2; 3 2 3]), arrowSize = 0.5)

julia> plotVectorFields!(-1:0.1:1, ([3 2 3; 2 1 2; 3 2 3], [3 2 3; 2 1 2; 3 2 3]), color="red", alpha=0.3)
```
"""
function plotVectorFields!(x, fields::Vector ;arrowScale=0.2, kwargs...)
	res = size(fields[1], 1)-1
	x = minimum(x):(maximum(x)-minimum(x))/res:maximum(x)
	xGrid = x' .* ones(res+1)
    yGrid = x .* ones(res+1)'
	quiver!(xGrid, yGrid, quiver=makeArrows.(fields[1], fields[2], arrowScale); kwargs...)
end

function makeArrows(x, y, scale)
	return (x,y) .* scale
end