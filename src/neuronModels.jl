function getNullclines(u, model; tau1=1.0, tau2=2.0, b0=0.9, b1=1.1, R=1.0, I=0.0)
	
    if model == "FHN"
        wuNull = nullclinewu(collect(u), R, I)
        wwNull = nullclineww(collect(u), b0, b1)
        return (wuNull, wwNull)

    else
        warn("Sorry that model is not yet implemented!")
    end
end

function getVectorFields(u, model, subdivisions=10; 
    tau1=1, tau2=2, b0=0.9, b1=1.1, R=1, I=0)
    
    uSparse = minimum(u):(maximum(u) - minimum(u))/subdivisions:maximum(u)
    uGrid = uSparse' .* ones(length(uSparse))
    wGrid = uSparse .* ones(length(uSparse))'

    if model == "FHN"
        du = dudt.(uGrid, wGrid, tau1, R, I)
        dw = dwdt.(uGrid, wGrid, b0, b1, tau2)
        return (dw, du)
    else
        warn("Sorry that model is not yet implemented!")
    end
end

function FitzHughNagumo(u; tau1=1, tau2=2, b0=0.9, b1=1.1, R=1, I=0)
    
    params = Dict(:tau1=>tau1, :tau2=>tau2, :b0=>b0, :b1=>b1, :R=>R, :I=>I)
    nullclines = getNullclines(u, "FHN"; tau1 = tau1, tau2 = tau2, b0 = b0, 
                               b1 = b1, R = R, I = I)
    fieldLines = getVectorFields(u, "FHN"; tau1 = tau1, tau2 = tau2, b0 = b0,
                              b1 = b1, R = R, I = I)
            
    return neuronModel(u, params, nullclines, fieldLines)
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
	
	quiver!(uGrid, wGrid, quiver=makeArrows.(neuron.vectorField[1], neuron.vectorField[2], 0.1), color=color)
end

function makeArrows(x, y, scale)
	return (x,y) .* scale
end