"""
    sigmoid(x, a, θ)

The sigmoid activation function with input x, gain parameter a, and threshold 
parameter θ.

# Examples
```jldoctest
julia> s = sigmoid(0.1:0.1:10, 1, 3)
100-element Vector{Float64}:
 0.0047276899008509565
 0.009898302721301974
 ⋮
 0.9515673560023477
 0.9516630756280327
 ```
"""
function sigmoid(x::Float64, a, θ)
    return 1/(1+exp(-a*(x-θ))) - 1/(1+exp(a*θ))
end 

"""
    invSigmoid(x, a, θ)

The inverse sigmoid function with input x, gain parameter a, and threshold 
parameter θ.

# Examples
```jldoctest
julia> invSigmoid(0.4, 1, 3)
 2.788923286876553

julia> invSigmoid.(0.1:0.1:0.9, 1, 3)
9-element Vector{Float64}:
 1.2450653370666414
 1.8876115356593868
 2.369626590583188
 2.788923286876553
 3.190275495162158
 3.6077434164384417
 4.084930356824196
 4.71455281467788
 5.891524586559516
 ```
"""
function invSigmoid(x, a, θ)
    return -log(1/(x+1/(1+exp(a*θ)))-1)/a + θ
end

"""
    dSigmoid(x, a, θ)

The derivative of the sigmoid function with input x, gain parameter a, and 
threshold parameter θ.

# Examples
```jldoctest
julia> dSigmoid(0.4, 1, 3)
 0.0643582991757735

julia> dSigmoid.(0.1:0.1:0.9, 1, 3)
 9-element Vector{Float64}:
  0.04943356893664324
  0.05403811475638431
  0.05900771248391522
  0.0643582991757735
  0.07010371654510816
  0.07625499905185225
  0.08281956699074117
  0.08980032904006871
  0.0971947048006254
 ```
 """
function dSigmoid(x, a, θ)
    return a * exp(-a * (x-θ)) * (1 + exp(-a * (x-θ)))^-2
end
