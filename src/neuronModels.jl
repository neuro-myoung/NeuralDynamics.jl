function getNullclines(u, model, params; I=0)
	
    if model == "FHN"
        wuNull = nullclinewu(collect(u), params.R, I)
        wwNull = nullclineww(collect(u), params.b₀, params.b₁)
        return (wuNull, wwNull)
    elseif model == "WC"
        eNull = eNullcline(u[1], params)
        iNull = iNullcline(u[2], params)
        return (eNull, iNull)
    else
        warn("Sorry that model is not yet implemented!")
    end
end

function getVectorFields(u, model, params, subdivisions=10; I=0)
    
    uSparse = minimum(u):(maximum(u) - minimum(u))/subdivisions:maximum(u)
    uGrid = uSparse' .* ones(length(uSparse))
    wGrid = uSparse .* ones(length(uSparse))'

    if model == "FHN"
        du = dudt.(uGrid, wGrid, params.τ₁, params.R, I)
        dw = dwdt.(uGrid, wGrid, params.b₀, params.b₁, params.τ₂)
    elseif model == "WC"
        du = drₑ(uGrid, wGrid, 
                 params.wₑₑ, params.wₑᵢ, params.aₑ, params.θₑ ; I=params.Iₑ)/params.τₑ
        dw = drᵢ(uGrid, wGrid, 
                 params.wᵢₑ, params.wᵢᵢ, params.aᵢ, params.θᵢ; I=params.Iᵢ)/params.τᵢ
    else
        warn("Sorry that model is not yet implemented!")
    end

    return (du, dw)
end

function FitzHughNagumo(u, params; I=0)
    
    nullclines = getNullclines(u, "FHN", params; I = I)
    fieldLines = getVectorFields(u, "FHN", params; I = I)

    return neuronModel(u, params, nullclines, fieldLines)
end

function simWilsonCowan(tₛᵢₘ, params, (rₑinit, rᵢinit); Ie=:none, Ii=:none)
		
    dt = tₛᵢₘ[2]-tₛᵢₘ[1]

    if Ie != :none 
        Iₑ = Ie
    else
        Iₑ = params.Iₑ * ones(length(tₛᵢₘ))
    end

    if Ii != :none 
        Iᵢ = Ii
    else
        Iᵢ = params.Iᵢ * ones(length(tₛᵢₘ))
    end
    
    ## Initialize arrays
    rₑ=zeros(length(tₛᵢₘ))
    rₑ[1] = rₑinit
    rᵢ=zeros(length(tₛᵢₘ))
    rᵢ[1] = rᵢinit
    
    for i in 1:length(tₛᵢₘ)-1
        
        ## Calculate derivatives
        drdtₑ = dt/params.τₑ * drₑ(rₑ[i], rᵢ[i], params.wₑₑ, params.wₑᵢ, 
                                   params.aₑ, params.θₑ ; I = Iₑ[i])
        drdtᵢ = dt/params.τᵢ * drᵢ(rₑ[i], rᵢ[i], params.wᵢₑ, params.wᵢᵢ, 
                                   params.aᵢ, params.θᵢ; I = Iᵢ[i])
    
        ## Update with Euler's method
        rₑ[i+1]=rₑ[i] + drdtₑ
        rᵢ[i+1]=rᵢ[i] + drdtᵢ
    end
    
    return rₑ, rᵢ
end

function plotNullclines(neuron; labels = ("",""), xlab="", ylab="", colors=[])
    if length(neuron.nullclines) == 0
        error("No nullclines!")
    else
        
        if length(colors) == 0
            colors = palette(:default, length(neuron.nullclines))
        end
        
        plt = plot(neuron.u, neuron.nullclines[1], color=colors[1], legend=true, 
        label=labels[1], xlab = xlab, ylab=ylab, xlims=(minimum(neuron.u), maximum(neuron.u)), 
        ylims=(minimum(neuron.u), maximum(neuron.u)))
        
        for ncl in 2:length(neuron.nullclines)
            plot!(neuron.u, neuron.nullclines[ncl], color=colors[ncl],
                label=labels[ncl])
        end
        
        return plt
    end
end

function plotVectorFields!(neuron; color=:black)
	res = size(neuron.vectorField[1], 1)-1
	u = minimum(neuron.u):(maximum(neuron.u)-minimum(neuron.u))/res:maximum(neuron.u)
	uGrid = u' .* ones(res+1)
    wGrid = u .* ones(res+1)'
	
	quiver!(uGrid, wGrid, quiver=makeArrows.(neuron.vectorField[1], neuron.vectorField[2], 0.2), color=color)
end

function plotVectorFields!(u, fields::Tuple{Matrix{Float64}, Matrix{Float64}} ; color=:black)
	res = size(fields[1], 1)-1
	u = minimum(u):(maximum(u)-minimum(u))/res:maximum(u)
	uGrid = u' .* ones(res+1)
    wGrid = u .* ones(res+1)'
	
	quiver!(uGrid, wGrid, quiver=makeArrows.(fields[1], fields[2], 0.2), color=color)
end

function makeArrows(x, y, scale)
	return (x,y) .* scale
end

function plotTrajectory!(x, y ;color=:red, label="")
    plot!(x, y, linewidth=2, color=color, label=label)
    scatter!([x[1]], [y[1]], color=color, markersize=10, markerstrokewidth=0, label=:none)
end

function plotTrajectories!(xArray, yArray, params;color=:gray, label="")
    
    for i in xArray
        for j in yArray
            rₑTemp, rᵢTemp = simWilsonCowan(0:0.1:50, params, (i,j))
            
            if i == minimum(xArray) && j == minimum(yArray)
                plot!(rₑTemp, rᵢTemp, color=color, 
                    label=label, alpha=0.8)
            else
                plot!(rₑTemp, rᵢTemp, color=color, 
                    label=:none, alpha=0.8)
            end
        end
    end
end

function findFixedPoints(xGuess::Vector{Vector{Float64}},
    func, params)

    zeroArr = repeat([zeros(2)], length(xGuess))
    for i in 1:length(xGuess)
        zeroArr[i] = nlsolve(x -> func(x, params), 
                            xGuess[i], method=:newton).zero
    end
    return zeroArr
end

function getJacobianEigenvalues(fixedPoints, params)
    
    eigenvals = []
    
    for i in 1:length(fixedPoints)
        println(fixedPoints[i])
        rₑ, rᵢ = fixedPoints[i]
        J= zeros(2,2)

        J[1,1] = (-1 + params.wₑₑ * dSigmoid(params.wₑₑ * rₑ - params.wₑᵢ * rᵢ + params.Iₑ, params.aₑ, params.θₑ))/params.τₑ
        J[2,1] = (-params.wₑᵢ * dSigmoid(params.wₑₑ * rₑ - params.wₑᵢ * rᵢ + params.Iₑ,params.aₑ, params.θₑ))/params.τₑ
        J[1,2] = (params.wᵢₑ * dSigmoid(params.wᵢₑ * rₑ - params.wₑᵢ * rᵢ + params.Iᵢ,params.aᵢ, params.θᵢ))/params.τᵢ
        J[2,2] = (-1 - params.wᵢᵢ * dSigmoid(params.wᵢₑ * rₑ - params.wᵢᵢ * rᵢ + params.Iᵢ, params.aᵢ, params.θᵢ))/params.τᵢ
        push!(eigenvals, eigvals(J))
    end
    return eigenvals 
end