module NeuralDynamics

using StatsBase, Plots, NLsolve, LinearAlgebra, Random

include("phaseAnalysis.jl")
include("FitzHughNagumo.jl")
include("SimpleFeedforward.jl")
include("WilsonCowan.jl")
include("OrnsteinUhlenbeck.jl")
include("modelingTools.jl")
include("plottingFunctions.jl")
include("activationFunctions.jl")

export initializeParams, getVectorFields, getNullclines , simulate, modelEquations, findFixedPoints, getJacobianEigenvalues
export plotVectorFields!, plotTrajectory!, plotTrajectories!
export sigmoid, invSigmoid, dSigmoid
export fWC!
export OrnsteinUhlenbeck

end
