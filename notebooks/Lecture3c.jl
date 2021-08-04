### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ f7741ca8-f1e3-4212-98bb-3bc2f0b94694
begin
	import Pkg
	Pkg.activate("../environments/v1.6")
	using Plots, PlutoUI, NeuralDynamics, Random
	TableOfContents()
end

# ╔═╡ 69d62570-ad5c-46c2-99c8-645f4b124ddf
md"# Wilson-Cowan model"

# ╔═╡ ef0815fe-f3ca-11eb-3a7d-39fd9d59783c
md"""

In the previous section, you became familiar with a neuronal network consisting of only an excitatory population. Here, we extend the approach we used to include both excitatory and inhibitory neuronal populations in our network. A simple, yet powerful model to study the dynamics of two interacting populations of excitatory and inhibitory neurons, is the so-called **Wilson-Cowan** rate model, which will be the main subject of this tutorial.

The objectives of this section are to:

- Write the **Wilson-Cowan equations for firing rate dynamics of a 2D system composed of an excitatory (E) and an inhibitory (I) population of neurons.
- Simulate the dynamics of the system, i.e., Wilson-Cowan model.
- Visualize and inspect the behavior of the system using **phase plane analysis**, **vector fields**, and **nullclines**.
- Find and plot the **fixed points** of the Wilson-Cowan model.
- Learn how the Wilson-Cowan model can reach an oscillatory state.

[Reference Paper Wilson H and Cowan J (1972) Excitatory and inhibitory interactions in localized populations of model neurons. Biophysical Journal 12](https://www.sciencedirect.com/science/article/pii/S0006349572860685?via%3Dihub)
"""

# ╔═╡ ffaaca75-8d90-4278-843b-39854408e326
md"""
## Introduction

Many of the rich dynamics recorded in the brain are generated by the interaction of excitatory and inhibitory subtype neurons. Here, we will model two coupled populations of E and I neurons (**Wilson-Cowan** model). We can write two coupled differential equations, each representing the dynamics of the excitatory or inhibitory population:

$\tau_{E} \frac{dr_{E}}{dt}=-r_{E}+F_{E}(w_{EE}r_{E}-w_{EI}r_{I}+I^{ext}_{E}; a_{E}, \theta_{E})$

$\tau_{I} \frac{dr_{I}}{dt}=-r_{I}+F_{I}(w_{IE}r_{E}-w_{II}r_{I}+I^{ext}_{I}; a_{I}, \theta_{I})$

 $r_{E}(t)$ represents the average activation (or firing rate) of the excitatory population at time $t$, and $r_{I}(t)$ the activation (or firing rate) of the inhibitory population. The pearameters $\tau_{E}$ and $\tau_{I}$ control the timescales of the dynamics of each population. Connection strengths are given by: $w_{EE} (E \rightarrow E)$, $w_{EI} (I \rightarrow E)$, $w_{IE} (E \rightarrow I)$, and $w_{II} (I \rightarrow I)$. The terms $w_{EI}$ and $w_{IE}$ respresent connections from the inhibitory to the excitatory population and vice versa, respectively. The transfer functions (or F-I curves) $F_{E}(x; a_E, \theta_E)$ and $F_{I}(x; a_I, \theta_I)$ can be different for the excitatory and the inhibitory populations.

Note that this is a somehow simplified version of the original model: (a) it's already temporally coarse grained, and (b) we assume no absolute refractory period here.

**How would you incorporate a refractory period here (on a population level as opposed to single neuron level**

## Simulations

We will run a numerical simulation (implemented as a helper function) of our equations and visualize two simulations with similar initial points.
"""

# ╔═╡ e259ec1e-b23e-4853-b213-2e7a1afa9e87
begin
	## Helper Functions
	struct modelParameters
		τₑ::Float64
		aₑ::Float64
		θₑ::Float64
		τᵢ::Float64
		aᵢ::Float64
		θᵢ::Float64
		wₑₑ::Float64
		wₑᵢ::Float64
		wᵢₑ::Float64
		wᵢᵢ::Float64
		Iₑ::Float64
		Iᵢ::Float64
	end
	
	function initializeModel(; τₑ=1.0, aₑ=1.2, θₑ=2.8, τᵢ=2.0, aᵢ=1.0, θᵢ=4.0, wₑₑ=9.0, wₑᵢ=4.0, wᵢₑ=13.0, wᵢᵢ=11.0, Iₑ=0.0, Iᵢ=0.0)
		return modelParameters(τₑ, aₑ, θₑ, τᵢ, aᵢ, θᵢ, wₑₑ, wₑᵢ, wᵢₑ, wᵢᵢ, Iₑ, Iᵢ)
	end
	
	
end

# ╔═╡ d186e7b6-8a13-4fa8-b2f9-9ae43a05567c
begin
	params=initializeModel()
	rₑ1, rᵢ1 = simWilsonCowan(0:0.1:50, params, (0.32,0.15))
	rₑ2, rᵢ2 = simWilsonCowan(0:0.1:50, params, (0.33,0.15))
	
	l1 = @layout [a; b]
	
	p1 = plot(0:0.1:50, rₑ1, label="E population", color=:blue, ylim=(0,1))
	plot!(0:0.1:50, rᵢ1, label="I population", color=:red) 
	
	p2 = plot(0:0.1:50, rₑ2, label="E population", color=:blue, ylim=(0,1))
	plot!(0:0.1:50, rᵢ2, label="I population", color=:red)
	
	plot(p1, p2, layout=l1)
end

# ╔═╡ 797e6ee8-3a97-41fb-851d-bd2e60c44b4f
md"""
The two plots above show the temporal evolution of excitatory ($r_E$, blue) and inhibitory ($r_I$, red) activity for t wo different sets of initial conditions.

## Phase plane analysis

Just like we used a graphical method to study the dynamics of a 1D system studied previously, here we will employ a graphical approach called **phase plane analysis** to study the dynamics of a 2D system like the Wilson-Cowan model.

So far, we have plotted the activities of the two populations as a function of time, i.e., in the **activity-t** plane, either the $(t, r_E(t))$ plane or the $(t, r_I(t))$ one. Instead, we can plot the two activities $r_E(t)$ and $r_I(t)$ against each other at any time point t. This characterization in the **rᵢ-rₑ** plane $(r_I(t), r_E(t))$ is called the **phase plane**. Each line in the phase plane indicates how both $r_E$ and $r_I$ evolve with time.

### Nullclines of the Wilson-Cowan Equations

An important concept in phase plane analysis is the "nullcline" which is defined as the set of points in the phase plane where the activity of one population (but not necessarily the other) does not change.

In other words, the $E$ and $I$ nullclines of Equation $(1)$ are defined as the points where $\frac{dr_E}{dt}=0$, for the excitatory nullcline, or $\frac{dr_I}{dt}=0$ for the inhibitory nullcline. That is:
	
$-r_E + F_E(w_{EE}r_E-w_{EI}r_I+I^{ext}_E;a_E,\theta_E) = 0  \tag{2}$
$-r_I + F_I(w_{IE}r_E-w_{II}r_I+I^{ext}_I;a_I,\theta_I) = 0  \tag{3}$

### Compute the nullclines of the Wilson-Cowan model

In the next exercise, we will compute and plot the nullclines of the E and I population.

Along the nullcline of the excitatory population, you can calculate the inhibitory activity by rewriting Equation $2$ into:

$r_I=\frac{1}{w_{EI}}[w_{EE}r_E-F_E^{-1}(r_E;a_E,\theta_E)+I^{ext}_E]	\tag{4}$ 

where $F^{-1}_E(r_E;a_E,\theta_E)$ is the inverse of the excitatory transfer function (defined below). Equation $4$ defines the $r_E$ nullcline.

Note that, when computing the nullclines with Equations $4-5$, we also need to calculate the inverse of the transfer functions.

The inverse of the sigmoid shaped **f-I** function that we have been using is:

$F^{-1}(x;a,\theta)=-\frac{1}{a}ln \Bigg[ \frac{1}{x+\frac{1}{1+e^{a\theta}}}-1 \Bigg] + \theta 	\tag{6}$

The first step is to implement the inverse transfer function.
"""

# ╔═╡ 38599e0e-e5e6-49e0-97f9-2bdf99b9b96e
begin
	x = collect(1e-6:0.001:0.93)
	plot(x, invSigmoid(x, 1, 3), linewidth=2, legend=:false, xlab="x", ylab="F⁻¹(x)")
end

# ╔═╡ 7cdf7cc3-f2bc-45f7-905d-480ea45e89db
md"""
Now you can compute the nullclines using Equations $4$-$5$ (repeated here for ease of access):

$r_I = \frac{1}{w_{EI}}[w_{EE}r_E-F^{-1}_E(r_E;a_E,\theta_E)+I^{ext}_E]	\tag{4}$
$r_E = \frac{1}{w_{IE}}[w_{II}r_I+F^{-1}_I(r_I;a_I,\theta_I)-I^{ext}_I]	\tag{5}$
"""

# ╔═╡ dce5dd3f-6ab8-4a05-b179-bfa87e6c0386
begin
	rₑNull = collect(-0.01:0.001:0.96)
	rᵢNull = collect(-0.01:0.001:0.8)
	ncls = getNullclines((rₑNull,rᵢNull), "WC", params)
	
	plot(rₑNull, ncls[1], xlab="rₑ", ylab="rᵢ", label="E Nullcline", linewidth=2, legend=:topleft)
	plot!(ncls[2], rᵢNull, label="I Nullcline", linewidth=2)
	
end

# ╔═╡ b0fb05af-42c5-455e-83b4-7f82c9e77852
md"""
Note that by definition along the blue line in the phase plane spanned by $r_E$, $r_I$, $\frac{dr_E(t)}{dt}=0, therefore, it is called a nullcline.

That is, the blue nullcline divides the phase plane spanned by $r_E$, $r_I$ into two regions: on one side of the nullcline $\frac{dr_E(t)}{dt} > 0$ and on the other side $\frac{dr_E(t)}{dt} < 0$.

The same is true for the red line along which $\frac{dr_I(t)}{dt}=0$. That is, the red nullcline divides the phase plane spanned by $r_E$, $r_I$ into two regions: on one side of the nullcline $\frac{dr_I(t)}{dt} > 0$ and on the other side $\frac{dr_I(t)}{dt} < 0$.
"""

# ╔═╡ 51e055d3-41a2-451c-84f4-c09dd1a62429
md"""
## Vector Field

How can the phase plane and the nullcline curves help us understand the behavior of the Wilson-Cowan model?

The activities of $E$ and $I$ populations $r_E(t)$ and $r_I(t)$ at each time point $t$ correspond to a single point in the phase plane, with coordinates $(r_E(t), r_I(t))$. Therefore, the time-dependent trajectory of the system can be described as a continuous curve in the phase plane, and the tangent vector to the trajectory, which is defined as the vector $\Big( \frac{dr_E(t)}{dt}, \frac{dr_I(t)}{dt} \Big)$, indicates the direction towards which the activity is evolving and how fast is the activity changing along each axis. In fact, for each point $(E,I)$ in the phase plane, we can compute the tangent vector $\Big( \frac{dr_E}{dt}, \frac{dr_I}{dt} \Big)$, which better indicates the behavior of the system when it traverses that point.

The map of tangent vectors in the phase plane is called the **vector field**. The behavior of any trajectory in the phase plane is determined by i) the initial conditions $(r_E(0), r_I(0))$, and ii) the vector field $\Big( \frac{dr_E(t)}{dt}, \frac{dr_I(t)}{dt} \Big)$.

In general, the value of the vector field at a particular point in the phase plane is represented by an arrow. The orientation and the size of the arrow reflect the direction and the norm of the vector, respectively.

### Compute and plot the vector field $\Big( \frac{dr_E(t)}{dt}, \frac{dr_I(t)}{dt} \Big)$

Note that

$\frac{dr_E}{dt}=[-r_E+F_E(w_{EE}r_E-w_{EI}r_I+I_E^{ext};a_E,\theta_E)]\frac{1}{\tau_E}$
$\frac{dr_I}{dt}=[-r_I+F_I(w_{IE}r_E-w_{II}r_I+I_I^{ext};a_I,\theta_I)]\frac{1}{\tau_I}$
"""

# ╔═╡ ac21c7c6-69ad-4975-af2b-7a0a4b44034f
begin
	
	## Get fields
	eiArr = 0:0.05:1
	fields = getVectorFields(eiArr, "WC", params)
	
	## Simulate
	rₑ3, rᵢ3 = simWilsonCowan(0:0.1:50, params, (0.6,0.8))
	rₑ4, rᵢ4 = simWilsonCowan(0:0.1:50, params, (0.6,0.6))
	
		
	sampleSpace = 0.0:0.2:1
	
	pWC = plot(rₑNull, ncls[1], xlab="rₑ", ylab="rᵢ", label="E Nullcline", 							linewidth=2, legend=:outertopright)
	plot!(ncls[2], rᵢNull, label="I Nullcline", linewidth=2)
	plotVectorFields!(eiArr, fields, color =:teal)
	plotTrajectory!(rₑ3, rᵢ3, color=:orange, label="Sample trajectory: \nlow activity")
	plotTrajectory!(rₑ4, rᵢ4, color=:purple, label="Sample trajectory: \nhigh activity")
	plotTrajectories!(sampleSpace, sampleSpace, params, color=:gray, label="Sample Trajectories")

	pWC
end

# ╔═╡ 8d312d7a-a0d4-402a-b72d-cc76acf3a738
md"""
The last phase plane plot shows us that:
- Trajectories follow the direction of the vector field.
- Different trajectories eventually always reach one of two points depending on the initial conditions.
- The two points where the trajectories converge are the intersection of the two nullcline curves

### Analyzing the vector field

There are, in total, three intersection points, meaning that the system has three fixed points.
1. One of the fixed points (the one in the middle) is never the final state of a trajectory. Why is that?
2. Why do the arrows tend to get smaller as they approach the fixed points?

## Fixed points

### Finding fixed points

From the above nullclines, we notice that the system features three fixed points with the parameters we used. To find their coordinates, we need to choose proper initial values to give the `find_roots` function, since the algorithm can only find fixed points in the vicinity of the initial value.

### Find the fixed points of the Wilson-Cowan model

In this exercise, you will use the function ` insert here ` to find each of the fixed points by varying the initial values. Note that you can choose the values near the intersections of the nullclines as the intiial values to calculate the fixed points.
"""

# ╔═╡ 5e49f283-5b85-4b04-ba04-cc47c9ebe17a
guesses = [[0.0,0.0],[0.4,0.2],[0.9,0.6]]

# ╔═╡ fe6b836d-3e5a-4aea-9de6-3c03edb2fe16
begin 
	fps = findFixedPoints(guesses, fWC!, params)

	pfp = plot(rₑNull, ncls[1], xlab="rₑ", ylab="rᵢ", 
			label="E Nullcline", linewidth=2, legend=:outertopright)
	plot!(ncls[2], rᵢNull, label="I Nullcline", linewidth=2)
	for coord in fps
		dispVal = round.(coord, digits=2)
		scatter!([coord[1]], [coord[2]], color=:black, markersize=8,
			legend=:none)
		annotate!([coord[1]], [coord[2]+0.1], text("$dispVal"))
	end
	pfp
end

# ╔═╡ 7e9da57f-d3d8-4a9b-9df0-9a645d02bf83
md"""
### Stability of a fixed point and eigenvalues of the Jacobian Matrix

First, let's rewrite the system $1$ as:

$\frac{dr_E}{dt}=G_E(r_E,r_I)$
$\frac{dr_I}{dt}=G_I(r_E,r_I)$

where

$G_E(r_E,r_I) = \frac{1}{\tau_E}[-r_E + F_E(w_{EE}r_E - w_{EI}r_I+I^{ext}_E;a,\theta)]$
$G_U(r_E,r_I) = \frac{1}{\tau_I}[-r_I + F_I(w_{IE}r_E - w_{II}r_I+I^{ext}_I;a,\theta)]$

By definition, $\frac{dr_E}{dt}=0$ and $\frac{dr_I}{dt}=0$ at each fixed point. Therefore, if the initial state is exactly at the fixed point, the state of the system will not change as time evolves.

However, if the initial state deviates slightly from the fixed point, there are two possibilities:

1. The trajectory will be attracted back to the fixed point.
2. The trajectory will diverge from the fixed point.

These two possibilities define the type of fixed point, i.e. stable or unstable. Similar to the 1D system studied in the previous section, the stability of a fixed point $(r_E^*, r_I^*)$ can be determined by linearizing the dynamics of the system (can you figure out how?). The linearization will yield a matrix of first-order derivatives called the Jacobian matrix:

$J = \begin{bmatrix} \frac{\partial}{\partial r_E}G_E(r_E^*, r_I^*) & \frac{\partial}{\partial r_I}G_E(r_E^*, r_I^*) \\ \frac{\partial}{\partial r_E}G_I(r_E^*, r_I^*) & \frac{\partial}{\partial r_I}G_I(r_E^*, r_I^*) \end{bmatrix}$

The eigenvalues of the Jacobian matrix calculated at the fixed point will determine whether it is a stable or unstable fixed point.

We can now compute the derivatives needed to build the Jacobian matrix. Using the chain and product rules the derivatives for the excitatory population are given by:

$\frac{\partial}{\partial r_E}G_E(r_E^*, r_I^*)=\frac{1}{\tau_E}[-1+w_{EE}F'_E(w_{EE}r_E^*-w_{EI}r^*_I+I^{ext}_E;\alpha_E,\theta_E)]$
$\frac{\partial}{\partial r_I}G_E(r_E^*, r_I^*)=\frac{1}{\tau_E}[-w_{EI}F'_E(w_{EE}r_E^*-w_{EI}r^*_I+I^{ext}_E;\alpha_E,\theta_E)]$

The same applies to the inhibitory population.
"""

# ╔═╡ b9798208-9176-4543-a09a-05d57943d21f
md"""
### Compute the Jacobian Matrix for the Wilson-Cowan Model
"""

# ╔═╡ 0c0deb0a-6107-4a59-b889-ef3870cdb0a7
getJacobianEigenvalues(fps, params)

# ╔═╡ 14336933-2e28-445b-bba6-f2014f4fa37d
md"""
As is evident, the stable fixed points are characterized by eigenvalues with a negative real part, while the unstable point is characterized by at least one positive eigenvalue. It's a saddle point in our case, since it features both positive and negative eigenvalues.

### Effect of $w_{EE}$ on the nullclines and the eigenvalues

The sign of the eigenvalues is determined by the connectivity (interaction) between excitatory and inhibitory populations.

Below we investigate the effect of $w_{EE}$ on the nullclines and the eigenvalues of the dynamical system.

### Nullclines position in the phase plane changes with parameter values

How do the nullclines move for different values of the parameter $w_{EE}$? What does this mean for fixed points and system activity?

wₑₑ: $(@bind wEE Slider(0.0:0.1:15; default=9.0, show_value=true))
τₑ: $(@bind tauE Slider(0.1:0.1:10; default=1.0, show_value=true))

wᵢᵢ: $(@bind wII Slider(0.0:0.1:15; default=11.0, show_value=true))
τᵢ: $(@bind tauI Slider(0.1:0.1:50; default=2.0, show_value=true))

wₑᵢ: $(@bind wEI Slider(0.0:0.1:15; default=4.0, show_value=true))
Iₑ: $(@bind Ie Slider(0.1:0.1:10; default=0.0, show_value=true))

wᵢₑ: $(@bind wIE Slider(0.0:0.1:15; default=13.0, show_value=true))
"""

# ╔═╡ ae50a971-701c-4aff-b9dc-3cb25b0e287d
begin
	params2 = initializeModel(; τₑ=tauE, τᵢ=tauI, wₑₑ=wEE, wₑᵢ=wEI, wᵢₑ=wIE, wᵢᵢ=wII, Iₑ=Ie)
	
	ncls2 = getNullclines((rₑNull,rᵢNull), "WC", params2)
	rₑ5, rᵢ5 = simWilsonCowan(0:0.1:50, params2, (0.2,0.2))
	rₑ6, rᵢ6 = simWilsonCowan(0:0.1:50, params2, (0.4,0.1))
	
	lsub = @layout [a ; b]
	louter = @layout [a b]

	p3 = plot(rₑNull, ncls2[1], xlab="rₑ", ylab="rᵢ", label="E Nullcline", linewidth=2, legend=:topleft)
	plot!(ncls2[2], rᵢNull, label="I Nullcline", linewidth=2)
	
	p4 = plot(0:0.1:50, rₑ5, label="E population", color=:blue, ylim=(0,1), legend=:bottomright)
	plot!(0:0.1:50, rᵢ5, label="I population", color=:red) 
	
	p5 = plot(0:0.1:50, rₑ6, label="E population", color=:blue, ylim=(0,1), legend=:none)
	plot!(0:0.1:50, rᵢ6, label="I population", color=:red)
	
	psub = plot(p4, p5, layout=lsub)
	pouter = plot(p3, psub, layout=louter)
	pouter
end

# ╔═╡ 7684ade7-64ba-4419-aa89-4630f2fbd4a3
md"""
We could also investigate the effect of different $w_{EI}$, $w_{IE}$, $w_{II}$, $\tau_E$, $\tau_I$, and $I^{ext}_E$ on the stability of fixed points. In addition, we can also consider the perturbation of parameters of the gain curve $F(\cdot)$.
"""

# ╔═╡ 5a7199ab-a05d-489d-9498-7223f0359612
md"""
## Limit cycle -oscillations

For some values of interaction terms $(w_{EE},w_{IE},w_{EI},w{II})$, the eigenvalues can become complex. When at least one pair of the eigenvalues is complex, oscillations arise. The stability of oscillations is determined bythe real part of the eigenvalues. The size of the complex part determines the frequency of oscillations.

For instance, if we use a different set of parameters, $w_{EE}=6.4$, $w_{EI}=4.8$, $w_{IE}=6.$, $w_{II}=1.2$, and $I^{ext}_E=0.8$, then we shall observe that the E and I population activity start to oscillate! Please execute the cell below to check the oscillatory behavior.
"""

# ╔═╡ c8c09dd2-8e05-4a0f-ad4c-01b48c57fc90
begin
	params3 = initializeModel(;wₑₑ=6.4, wₑᵢ=4.8, wᵢₑ=6.0, wᵢᵢ=1.2, Iₑ=0.8)
	rₑ7, rᵢ7 = simWilsonCowan(0:0.1:100, params3, (0.25,0.25))
	p6 = plot(0:0.1:100, rₑ7, label="E population", color=:blue, ylim=(0,1))
	plot!(0:0.1:100, rᵢ7, label="I population", color=:red) 
end

	

# ╔═╡ 463dffc2-18e8-46cb-ad12-caa5f3d74802
md"""
We can also understand the oscillations of the population behavior using the phase plane. By plotting a set of trajectories with different initial states, we can see that these trajectories will move in a circle instead of converging to a fixed point. This circle is called a **limit cycle** and shows periodic oscillations of the $E$ and $I$ population behavior under some conditions. Let's plot the phase plane using the previously defined functions.
"""

# ╔═╡ 0f2f643c-d416-48f8-9145-a35b75c86522
begin
	fps2 = findFixedPoints([[0.5,0.5]], fWC!, params3)
	ncls3 = getNullclines((rₑNull,rᵢNull), "WC", params3)
	fields2 = getVectorFields(eiArr, "WC", params3)
	
	dispVal2 = round.(fps2[1], digits=2)

	sampleSpace2 = 0.0:0.25:1
	
	pWC2 = plot(rₑNull, ncls3[1], xlab="rₑ", ylab="rᵢ", label="E Nullcline", 							linewidth=2, legend=:outertopright)
	plot!(ncls3[2], rᵢNull, label="I Nullcline", linewidth=2)
	scatter!([fps2[1][1]], [fps2[1][2]], color=:black, markersize=8, label=:none)
	annotate!([fps2[1][1]], [fps2[1][2]+0.1], text("$dispVal2"))
	plotVectorFields!(eiArr, fields2, color =:teal)
	plotTrajectories!(sampleSpace2, sampleSpace2, params3, color=:gray, label="Sample Trajectories")

	pWC2
end

# ╔═╡ e51502d7-dcb6-4702-b432-f80c3a2ad46d
getJacobianEigenvalues(fps2, params3)

# ╔═╡ cb86a731-fe33-49f6-a45f-15df6e775a82
md"""
From the above, examples, the change of model parameters changes the shape of the nullclines and, accordingly, the behavior of the $E$ and $I$ populations from steady fixed points to oscillations. However, the shape of the nullclines is unable to fully determine the behavior of the network. The vector field also matters. To demonstrate this, here, we will investigate the effect of time constants on the population behavior. By changing the inhibitory time constant $\tau_I$, the nullclines do not change, but the network behavior changes substantially from steady state to oscillations with different frequencies.

As you know, such a dramatic change in the system behavior is referred to as a **bifurcation**. What kind of bifurcation are we dealing with here?

τᵢ: $(@bind tauI2 Slider(0.1:0.1:50; default=2.0, show_value=true))

"""

# ╔═╡ ea59b8f6-ea4d-435f-899a-df04d56b32e4
begin
	params4 = initializeModel(;wₑₑ=6.4, wₑᵢ=4.8, wᵢₑ=6.0, wᵢᵢ=1.2, Iₑ=0.8, τᵢ=tauI2)
	fps3 = findFixedPoints([[0.5,0.5]], fWC!, params4)
	ncls4 = getNullclines((rₑNull,rᵢNull), "WC", params4)
	fields3 = getVectorFields(eiArr, "WC", params4)
	rₑ8, rᵢ8 = simWilsonCowan(0:0.1:100, params4, (0.25,0.25))
	
	
	l3 = @layout [a b]
	
	pWC3 = plot(rₑNull, ncls4[1], xlab="rₑ", ylab="rᵢ", label="E Nullcline", 							linewidth=2, legend=:none, title="τᵢ=$tauI2"*" ms")
	plot!(ncls4[2], rᵢNull, label="I Nullcline", linewidth=2)
	scatter!([fps3[1][1]], [fps3[1][2]], color=:black, markersize=8, label=:none)
	plotVectorFields!(eiArr, fields3, color =:teal)
	plotTrajectory!(rₑ8, rᵢ8, color=:black)
	plotTrajectories!(sampleSpace2, sampleSpace2, params4, color=:gray, label="Sample Trajectories")
	
	pWC3Activity = plot(0:0.1:100, rₑ8, label="E population", color=:blue, ylim=(0,1))
	plot!(0:0.1:100, rᵢ8, label="I population", color=:red) 

	plot(pWC3, pWC3Activity, layout=l3)
end


# ╔═╡ 4c897322-9582-4066-8960-9c585e560005
getJacobianEigenvalues(fps3, params4)

# ╔═╡ 55014f6a-aaf7-40f1-aa2c-6d1faed25f2b
md"""
Both $\tau_E$ and $\tau_I$ feature in the Jacobian of the two population network (**Eq. 7**). So here it seems that just by increasing $\tau_I$ the eigenvalue corresponding to the fixed point changes (how?).
"""

# ╔═╡ a50eb8d2-dc17-4fa3-a287-9f5912b854f1
md"""
## Fixed points and working memory

The input into the neurons was measured in vivo is often noisy (what is the source of noise?). Here, the noisy synaptic input current is modeled as an Ornstein-Uhlenbeck (OU) process, which has been discussed several times in the previous tutorials.
"""

# ╔═╡ 29c0c0d7-4677-460e-9c6d-1987ae09327b
function OrnsteinUhlenbeck(tArray, params, signal; seed=nothing)
	if seed != nothing
		Random.seed!(seed)
	else
		Random.seed!()
	end
	
	dt = tArray[2]-tArray[1]

	noise = randn(length(tArray))
	I = zeros(length(noise))
	I[1] = noise[1] * signal
	
	for i in 2:length(I)-1
		I[i+1] = I[i] + dt/params.τ * (0. - I[i]) + sqrt(2 * dt/params.τ) * signal * noise[i+1]
	end

	return I
end

# ╔═╡ 94f1efc8-e144-42ed-ba96-9cd85879c5cf
begin
	struct OUModelParams
		τ::Float64
	end
	
	params5 = OUModelParams(1.)
	Iₒᵤ = OrnsteinUhlenbeck(0.1:0.1:50, params5, 0.1)
	plot(collect(0.1:0.1:50), Iₒᵤ, legend=:none, ylab="Iₒᵤ", xlab="Time (ms)")

end


# ╔═╡ 1f554429-1a41-48f9-beac-7d8ccb0854b7
md"""
With the default parameters, the system fluctuates around a resting state with the noisy input.
"""

# ╔═╡ cfa18de4-ea7e-4ab4-8867-ad7a72b19af8
begin
	Ie2 = OrnsteinUhlenbeck(collect(0:0.1:100), params5, 0.1, seed=2022)
	Ii2 = OrnsteinUhlenbeck(collect(0:0.1:100), params5, 0.1, seed=2021)
	
	rE, rI = simWilsonCowan(0:0.1:100, params4, (0.1,0.1), Ie=Ie2, Ii=Ii2)
	plot(collect(0:0.1:100), rE, color=:blue, linewidth=2, label="E Population", 
		ylab="Activity", xlab="Time (ms)")
	plot!(collect(0:0.1:100), rI, color=:red, linewidth=2, label="I Population")
end

# ╔═╡ 01299142-99ad-43d3-ac33-041541c2d0ae
md"""
### Short pulse induced persistent activity

Then, let's use a brief 10-ms positive current to the E population when the system is at equilibrium. When this amplitude (SE below) is sufficiently large, a persistent activity is produced that outlasts the transient input. What is the firing rate of the persistent activity, and what is the critical input strength? Try to understand the phenomena from the above phase-plane analysis.

SE: $(@bind SE Slider(0.0:0.01:1.0; default=0.0, show_value=true))
startₑ: $(@bind start1 Slider(1:1:100; default=10, show_value=true))

SI: $(@bind SI Slider(0.0:0.01:1.0; default=0.0, show_value=true))
startᵢ: $(@bind start2 Slider(1:1:100; default=1, show_value=true))
"""

# ╔═╡ eaaf1701-ac8f-4d8b-ae2f-99e0aa4464c6
begin
	tArray = 0:0.1:100

	function squarePulse(array, start, lag=10.)
		stimulus = zeros(length(0:0.1:100))
		dt = array[2]-array[1]
		startLoc = Int64.(start/dt)
		endLoc = Int64.(start/dt + lag/dt)
		stimulus[startLoc:endLoc] .= 1.
			
		return stimulus
	end
	
	stim = squarePulse(tArray, start1)
	stim2 = squarePulse(tArray, start2)
	stimLoc = start1:1:start1+10
	stim2Loc = start2:1:start1+10
	Ie3 = OrnsteinUhlenbeck(collect(tArray), params5, 0.1, seed=2021)
	pulse = sum(stim)
	
	rE2, rI2 = simWilsonCowan(0:0.1:100, params, (0.1,0.1), Ie=Ie3+stim*SE, Ii=Ie3+stim2*SI)
	
	plot(collect(tArray), rE2, color=:blue, linewidth=2, label="E Population", ylab="Activity", xlab="Time (ms)",
	ylims=(0,1.3))
	plot!([start1,start1+10],[1,1], linewidth=4,color=:blue,
	label=:none)
	annotate!([start1+5],[1.05], text("stim on E", :center, 10))
	plot!([start2,start2+10],[1.1,1.1], linewidth=4,color=:red,
	label=:none)
	annotate!([start2+5],[1.15], text("stim on I", :center, 10))
	plot!(collect(tArray), rI2, color=:red, linewidth=2, label="I Population")

end

# ╔═╡ 3ffb472e-5679-46e2-beb0-54af1e8b8ad8
md"""
Explore what happens when a second, brief current is applied to the inhibitory population.
"""

# ╔═╡ Cell order:
# ╟─69d62570-ad5c-46c2-99c8-645f4b124ddf
# ╠═f7741ca8-f1e3-4212-98bb-3bc2f0b94694
# ╟─ef0815fe-f3ca-11eb-3a7d-39fd9d59783c
# ╟─ffaaca75-8d90-4278-843b-39854408e326
# ╟─e259ec1e-b23e-4853-b213-2e7a1afa9e87
# ╟─d186e7b6-8a13-4fa8-b2f9-9ae43a05567c
# ╟─797e6ee8-3a97-41fb-851d-bd2e60c44b4f
# ╟─38599e0e-e5e6-49e0-97f9-2bdf99b9b96e
# ╟─7cdf7cc3-f2bc-45f7-905d-480ea45e89db
# ╟─dce5dd3f-6ab8-4a05-b179-bfa87e6c0386
# ╟─b0fb05af-42c5-455e-83b4-7f82c9e77852
# ╟─51e055d3-41a2-451c-84f4-c09dd1a62429
# ╟─ac21c7c6-69ad-4975-af2b-7a0a4b44034f
# ╟─8d312d7a-a0d4-402a-b72d-cc76acf3a738
# ╠═5e49f283-5b85-4b04-ba04-cc47c9ebe17a
# ╟─fe6b836d-3e5a-4aea-9de6-3c03edb2fe16
# ╟─7e9da57f-d3d8-4a9b-9df0-9a645d02bf83
# ╟─b9798208-9176-4543-a09a-05d57943d21f
# ╠═0c0deb0a-6107-4a59-b889-ef3870cdb0a7
# ╟─14336933-2e28-445b-bba6-f2014f4fa37d
# ╟─ae50a971-701c-4aff-b9dc-3cb25b0e287d
# ╟─7684ade7-64ba-4419-aa89-4630f2fbd4a3
# ╟─5a7199ab-a05d-489d-9498-7223f0359612
# ╟─c8c09dd2-8e05-4a0f-ad4c-01b48c57fc90
# ╟─463dffc2-18e8-46cb-ad12-caa5f3d74802
# ╟─0f2f643c-d416-48f8-9145-a35b75c86522
# ╠═e51502d7-dcb6-4702-b432-f80c3a2ad46d
# ╟─cb86a731-fe33-49f6-a45f-15df6e775a82
# ╟─ea59b8f6-ea4d-435f-899a-df04d56b32e4
# ╟─4c897322-9582-4066-8960-9c585e560005
# ╟─55014f6a-aaf7-40f1-aa2c-6d1faed25f2b
# ╟─a50eb8d2-dc17-4fa3-a287-9f5912b854f1
# ╟─29c0c0d7-4677-460e-9c6d-1987ae09327b
# ╟─94f1efc8-e144-42ed-ba96-9cd85879c5cf
# ╟─1f554429-1a41-48f9-beac-7d8ccb0854b7
# ╟─cfa18de4-ea7e-4ab4-8867-ad7a72b19af8
# ╟─01299142-99ad-43d3-ac33-041541c2d0ae
# ╟─eaaf1701-ac8f-4d8b-ae2f-99e0aa4464c6
# ╟─3ffb472e-5679-46e2-beb0-54af1e8b8ad8
