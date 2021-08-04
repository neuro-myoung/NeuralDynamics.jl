module NeuralDynamics

using Random, StatsBase, Statistics, DataFrames, Plots, StatsPlots, Parameters, Roots,
NLsolve, LinearAlgebra

include("ising2D.jl")
include("bifurcationDiagrams.jl")
include("plotFields.jl")
include("rungeKatta.jl")
include("FitzHughNagumo.jl")
include("neuronModels.jl")
include("activationFunctions.jl")
include("WilsonCowan.jl")

@with_kw struct neuronModel
    u::Vector{Float64}
    params
    nullclines::Tuple{Vector{Float64}, Vector{Float64}}
    vectorField::Tuple{Matrix{Float64}, Matrix{Float64}}
end

export simulateIsing2D
export bifurcationDiagram, addBifurcation!, plotField1D
export rk1, rk2
export plotNullclines, plotVectorFields!, FitzHughNagumo, neuronModel, findFixedPoints, simWilsonCowan, getVectorFields, getNullclines,
plotTrajectories!, plotTrajectory!, fWC!, getJacobianEigenvalues
export sigmoid, invSigmoid, dSigmoid

end
