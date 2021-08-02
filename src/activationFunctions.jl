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

