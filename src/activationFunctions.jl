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

