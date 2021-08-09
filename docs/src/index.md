# NeuralDynamics.jl

```@meta
CurrentModule = NeuralDynamics
DocTestSetup = quote
    using NeuralDynamics
end
```
NeuralDynamics is a package for basic analysis, simulation, and visualization of
dynamical models for neurons or networks of neurons. It is based largely on a 
minicourse taught by @nalewkoz on Neural Bifurcations. The Pluto notebooks can 
serve as interactive tools to visualize some of the models implemented.

## Package Features
- Implementations of some basic neuron and network models.
- Convenience functions for phase analysis and simulation.
- Convenient plotting functions built on Plots.jl.

## Installation

The latest release of NeuralDynamics can be installed from the julia package 
manager REPL with
```
] add NeuralDynamics
```

From here the package can be loaded by typing
```
julia> using NeuralDynamics
```
into the julia REPL.

See the Tutorial for a basic example of the workflow and features available.

## List of currently implemented models

The following models are currently available and can be called using the 
associated string in parentheses.
- FitzHughNagumo (`"FSH"`)
- Wilson-Cowan (`"WC"`)
- Simple Feed-forward(`"SFF"`)

!!! info "Interactive Examples" 
    Working examples of analyses with interactivity can be found in the Pluto notebooks found in the notebooks folder.

## In Progress
- generalize simulation function
- generalize getJacobianEigenvalues function
- Implement HH and LIF models
- Introduce higher order RK methods for simulation
- Add Ising simulation
- Add Bifurcation Diagrams
- Always room to refactor

Documentation produced using Documenter.jl
Last updated 2021-08-08