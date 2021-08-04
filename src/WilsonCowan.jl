@. function drₑ(rₑ, rᵢ, wₑₑ, wₑᵢ, aₑ, θₑ; I=0) 
    return (-rₑ + sigmoid(wₑₑ * rₑ - wₑᵢ * rᵢ + I, aₑ, θₑ))
end

@. function drᵢ(rₑ, rᵢ, wᵢₑ, wᵢᵢ, aᵢ, θᵢ; I=0) 
    return (-rᵢ + sigmoid(wᵢₑ * rₑ - wᵢᵢ * rᵢ + I, aᵢ, θᵢ))
end

@. function eNullcline(rₑ::Vector{Float64}, params)
		return (params.wₑₑ * rₑ - invSigmoid(rₑ, params.aₑ, params.θₑ) + params.Iₑ)/params.wₑᵢ
	end

@. function iNullcline(rᵢ::Vector{Float64}, params)
	return (params.wᵢᵢ * rᵢ + invSigmoid(rᵢ, params.aᵢ, params.θᵢ) - params.Iᵢ)/params.wᵢₑ
end