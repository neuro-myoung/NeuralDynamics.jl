@. function sigmoid(x, params)
"""
Sigmoid neuronal population activation function.

Arguments:
    x: population input
    a: gain
    θ: threshold

Output:
    The population activation response F(x) for input x.
"""

    return 1/(1+exp(-params.a*(x-params.θ))) - 1/(1+exp(params.a*params.θ))
end 

@. function sigmoid(x, a, θ)
"""
Sigmoid neuronal population activation function.

Arguments:
    x: population input
    a: gain
    θ: threshold

Output:
    The population activation response F(x) for input x.
"""

    return 1/(1+exp(-a*(x-θ))) - 1/(1+exp(a*θ))
end 

function invSigmoid(x::Float64, a, θ)
    return -log(1/(x+1/(1+exp(a*θ)))-1)/a + θ
end

@. function invSigmoid(x::Vector{Float64}, a, θ)
    return -log(1/(x+1/(1+exp(a*θ)))-1)/a + θ
end

function dSigmoid(x, a, θ)
    return a * exp(-a * (x-θ)) * (1 + exp(-a * (x-θ)))^-2
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

