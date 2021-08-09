# Models

```@meta
CurrentModule = NeuralDynamics
DocTestSetup = quote
    using NeuralDynamics
end
```

Below I provide a basic introduction to implementations of the models in this package. 

## FitzHugh-Nagumo
---
### Description
The FitzHugh-Nagumo model is a 2D approximation of the Hodgkin-Huxley model. The general form of the dynamical equations describing this model are

`` \tau \dot{u} = F(u,w) + RI ``

`` \tau_{w} \dot{w} = G(u,w) ``

where ``u`` is the membrane voltage, ``I`` is the input current, and ``R`` is the resistance. The three gating variables of the Hodgkin-Huxley model are summarized by the single recovery variable ``w``. ``F(u,w)`` and ``G(u,w)`` are given by the following equations:

`` F(u,w) = u - \frac{1}{3}u^3-w ``

`` G(u,w) = b_{0}+b_{1}u-w ``

### Parameters
- **tau1**: Time constant governing equation 1
- **tau2**: Time constant governing equation 2
- **b0**: Parameter for equation 2
- **b1**: Parameter for equation 2
- **R**: Resistance
- **I**: Input current

### Building the model
    ## Default parameters
    params = initializeParams("FHN")

    ## Change some parameters
    initializeParams("FHN", tau1=1.2, b0=0.5)

    ## Customize all parameters
    initializeParams("FHN", tau1=1.2, tau2=2.5, b0=1.1, b1=1.9, R=1.2, I=1)

## Simple Feed-forward
---

### Description
A simple feed-forward network can be described by the following dynamical equation describing network connections between excitatory neurons:

``\frac{dr_{E}}{dt} = [-r_{E}+F(w\cdot r_{E}+I_{ext})]/τ``

Here, ``r_E`` describes the network activity, ``w`` decribes the weight of the connectivity between neurons, ``I_{ext}`` is the external input to the network, and ``tau`` is the time constant for the decay of network activity. The average neuronal activity is described by a sigmoid function ``F(r_E)`` of the following form:

``F(x;a,\theta)=\frac{1}{1+e^{-a(x-\theta)}}-\frac{1}{1+e^{a\theta}}``

Here, ``a`` describes the gain of the function and ``\theta`` the threshold.

### Parameters
- **tau**: Time constant governing network dynamics
- **a**: gain
- **theta**: threshold
- **w**: connection weight
- **I**: Input current

### Building the model
    ## Default parameters
    params = initializeParams("SFF")

    ## Change some parameters
    initializeParams("SFF", tau1=1.2, a=0.5)

    ## Customize all parameters
    initializeParams("SFF", tau=1, a=0.5, theta=1.1, w=1, I=1)

## Wilson-Cowan
---

### Description
The Wilson-Cowan network describes a network of neurons with distinct excitatory and inhibitory populations that project onto each other and within themselves. The network can be described by the following coupled differential equations:

`` \tau_{E} \frac{dr_{E}}{dt}=-r_{E}+F_{E}(w_{EE}r_{E}-w_{EI}r_{I}+I^{ext}_{E}; a_{E}, \theta_{E}) ``

``\tau_{I} \frac{dr_{I}}{dt}=-r_{I}+F_{I}(w_{IE}r_{E}-w_{II}r_{I}+I^{ext}_{I}; a_{I}, \theta_{I})``

Here, ``r_E(t)`` represents the average firing rate of the excitatory population at time ``t``, ``r_I(t)`` represents the average firing rate of the inhibitory population at time ``t``, The connection strengths are represented by the four weight terms as follows: ``w_{EE} (E \rightarrow E)``, ``w_{EI} (I \rightarrow E)``, ``w_{IE} (E \rightarrow I)``, and ``w_{II} (I \rightarrow I)``. The transfer functions for each population can be represented by distinct sigmoids of the following form: 

``F(x;a,\theta)=\frac{1}{1+e^{-a(x-\theta)}}-\frac{1}{1+e^{a\theta}}``

This implementation of the model is temporally coarse grained and assumes no absolute refractory period.

### Parameters
- **tauE**: Time constant governing the excitatory network dynamics
- **aE**: gain term for the excitatory transfer function
- **thetaE**: threshold term for the excitatory transfer function
- **tauI**: Time constant governing the inhibitory network dynamics
- **aI**: gain term for the inhibitory transfer function
- **thetaI**: threshold term for the inhibitory transfer function
- **wEE**: connection strength within the excitatory network
- **wEI**: connection strength from the inhibitory to the excitatory network
- **wIE**: connection strength from the excitatory to the inhibitory network
- **wII**: connection strength within the inhibitory network
- **IE**: external input to the excitatory network
- **II**: external input to the inhibitory network

### Building the model
    ## Default parameters
    params = initializeParams("WC")

    ## Change some parameters
    initializeParams("WC", tauE=1.2, aE=0.5)

    ## Customize all parameters
    initializeParams("WC"; tauE= 1.2, tauI= 2.5, aE=0.5, thetaE=0.8, aI=1.1, thetaI=1.2, wEE=6.4, wEI=4.8, wIE=6.0, wII=1.2, IE=0.8, II=0.2)