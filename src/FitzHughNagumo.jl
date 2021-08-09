## FitzHughNagumo model equations

@. function fhn_nullclinewu(u, params)
    return u - (u^3)/3 + params[:R] * params[:I]
end

@. function fhn_nullclineww(u, params)
    return params[:b0] + params[:b1] * u
end

@. function fhn_dudt(u::Array, w::Array, params::Dict)
        return (u - (u^3)/3 - w + params[:R]*params[:I])/params[:tau1]
end


function fhn_dudt(u::Float64, w::Float64, params::Dict)
    return (u - (u^3)/3 - w + params[:R]*params[:I])/params[:tau1]
end

@. function fhn_dwdt(u::Array, w::Array, params::Dict)
    return (params[:b0] + params[:b1]*u - w)/params[:tau2]
end

function fhn_dwdt(u::Float64, w::Float64, params::Dict)
    return (params[:b0] + params[:b1]*u - w)/params[:tau2]
end

