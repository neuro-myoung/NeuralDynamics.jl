@. function wc_drₑ(rₑ::Array, rᵢ::Array, params::Dict) 
		return (-rₑ + sigmoid(params[:wEE] * rₑ - params[:wEI] * rᵢ + params[:IE], 
			params[:aE], params[:thetaE]))/params[:tauE]
	end

    function wc_drₑ(rₑ::Float64, rᵢ::Float64, params::Dict) 
		return (-rₑ + sigmoid(params[:wEE] * rₑ - params[:wEI] * rᵢ + params[:IE], 
			params[:aE], params[:thetaE]))/params[:tauE]
	end

    function wc_drₑ(rₑ::Float64, rᵢ::Float64, params::Dict, I) 
		return (-rₑ + sigmoid(params[:wEE] * rₑ - params[:wEI] * rᵢ + I, 
			params[:aE], params[:thetaE]))/params[:tauE]
	end

@. function wc_drᵢ(rₑ::Array, rᵢ::Array, params::Dict) 
	    return (-rᵢ + sigmoid(params[:wIE] * rₑ - params[:wII] * rᵢ + params[:II], 
			params[:aI], params[:thetaI]))/params[:tauI]
	end

    function wc_drᵢ(rₑ::Float64, rᵢ::Float64, params::Dict) 
	    return (-rᵢ + sigmoid(params[:wIE] * rₑ - params[:wII] * rᵢ + params[:II], 
			params[:aI], params[:thetaI]))/params[:tauI]
	end

    function wc_drᵢ(rₑ::Float64, rᵢ::Float64, params::Dict, I) 
	    return (-rᵢ + sigmoid(params[:wIE] * rₑ - params[:wII] * rᵢ + I, 
			params[:aI], params[:thetaI]))/params[:tauI]
	end

@. function wc_eNullcline(rₑ::Vector, params::Dict)
        return (params[:wEE] * rₑ - invSigmoid.(rₑ, params[:aE], params[:thetaE]) + 
            params[:IE])/params[:wEI]
    end

@. function wc_iNullcline(rᵢ::Vector, params::Dict)
        return (params[:wII] * rᵢ + invSigmoid.(rᵢ, params[:aI], params[:thetaI]) - 
            params[:II])/params[:wIE]
    end

function fWC!(x, params)		
    rₑ, rᵢ = x
    
    de = wc_drₑ(rₑ, rᵢ, params)
    di = wc_drᵢ(rₑ, rᵢ, params)
    return (de, di)
end