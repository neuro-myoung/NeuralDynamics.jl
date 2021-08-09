push!(LOAD_PATH,"../src/")
using Documenter, NeuralDynamics

makedocs(
    sitename = "NeuralDynamics.jl",
    doctest = true,
    pages = [
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "Models" => "models.md",
        "Function Documentation" => "functions.md"
    ]
)

deploydocs(
    repo = "github.com/neuro-myoung/NeuralDynamics.jl.git",
)