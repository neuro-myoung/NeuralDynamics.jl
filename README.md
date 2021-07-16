# NeuralDynamics

[![Build Status](https://travis-ci.com/neuro-myoung/NeuralDynamics.jl.svg?branch=master)](https://travis-ci.com/neuro-myoung/NeuralDynamics.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/neuro-myoung/NeuralDynamics.jl?svg=true)](https://ci.appveyor.com/project/neuro-myoung/NeuralDynamics-jl)
[![Coverage](https://codecov.io/gh/neuro-myoung/NeuralDynamics.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/neuro-myoung/NeuralDynamics.jl)
[![Coverage](https://coveralls.io/repos/github/neuro-myoung/NeuralDynamics.jl/badge.svg?branch=master)](https://coveralls.io/github/neuro-myoung/NeuralDynamics.jl?branch=master)

## Description
A small package developed for a dynamical systems course for creating custom plots and running numerical simulations.

## Prerequisites

Before you begin make sure you have Julia v1.6 or higher (Tests were not yet developed for older versions)

## Installation

```
git clone https://github.com/neuro-myoung/NeuralDynamics.jl.git
```

Then be sure to add the package contents to your development environment. From the package manager type the following.

```
]dev NeuralDynamics
```
Then you will be able to import the package as with any other Julia package
```
using NeuralDynamics
```

## Examples
**Documentation** to come...
For now here are some examples of plots made with this package:

### Bifurcation Diagrams

### Ising Simulation
```Mhist, X = simulateIsing2D(params, 2000000);```

Display the results of the simulation:



## Contributing
To contribute to **NeuralDynamics.jl**, follow these steps:

1. Fork this repository.
2. Create a branch: git checkout -b *branch_name*.
3. Make your changes and commit them: git commit -m '*commit_message*'
4. Push to the original branch: git push origin *project_name* *location*
5. Create a pull request.

Alternatively see the GitHub [documentation](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request) on creating a pull request.

## Contributors

[@neuro-myoung](https://github.com/neuro-myoung)

## Contact

If you want to contact me you can reach me at michael.young@duke.edu

## License
This project uses an [MIT License](https://opensource.org/licenses/MIT)