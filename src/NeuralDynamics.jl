module NeuralDynamics

using Random, StatsBase, Statistics, DataFrames, Plots, StatsPlots

include("ising2D.jl")
include("bifurcationDiagrams.jl")
include("plotFields.jl")
include("rungeKatta.jl")

export simulateIsing2D
export bifurcationDiagram, addBifurcation!, plotField1D
export rk1, rk2

end
