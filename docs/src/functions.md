# Function Documentation

```@meta
CurrentModule = NeuralDynamics
DocTestSetup = quote
    using NeuralDynamics
end
```
## Model Building

```@docs
initializeParams
```
```@docs
modelEquations
```

## Phase Analysis

```@docs
getNullclines
```

```@docs
getVectorFields
```

```@docs
findFixedPoints
```

```@docs
getJacobianEigenvalues
```

## Convenience Functions

```@docs
sigmoid
```

```@docs
invSigmoid
```

```@docs
dSigmoid
```

## Simulation
```@docs
simulate
```

## Plotting
```@docs
plotVectorFields!
```

```@docs
plotTrajectory!
```

```@docs
plotTrajectories!
```