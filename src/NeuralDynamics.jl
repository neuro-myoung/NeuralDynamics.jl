module NeuralDynamics

using Random, StatsBase, Statistics, DataFrames, Plots, StatsPlots, Parameters

include("ising2D.jl")
include("bifurcationDiagrams.jl")
include("plotFields.jl")
include("rungeKatta.jl")
include("FitzHughNagumo.jl")
include("neuronModels.jl")

@with_kw mutable struct neuronModel
    u::Vector{Float64}
    params::Dict{Symbol, Real}
    nullclines::Tuple{Vector{Float64}, Vector{Float64}}
    vectorField::Tuple{Matrix{Float64}, Matrix{Float64}}
end

export simulateIsing2D
export bifurcationDiagram, addBifurcation!, plotField1D
export rk1, rk2
export plotNullclines, plotVectorFields!, FitzHughNagumo, neuronModel

end
