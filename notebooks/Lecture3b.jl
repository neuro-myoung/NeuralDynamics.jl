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

# ╔═╡ 743f4cc6-6bd2-491e-8a64-5947554bc839
begin
	import Pkg
	Pkg.activate("../environments/v1.6")
	using Plots, PlutoUI, NeuralDynamics, NLsolve
	TableOfContents()
end

# ╔═╡ dfdde882-6871-47ea-a935-c33f3794f7c1
md"# Population Dynamics"

# ╔═╡ 60d66ee0-f393-11eb-0f70-214941234e7c
md"""
## Dynamics of a single feed-forward population

Individual neurons respond by spiking. When we average the spikes of neurons in a population, we can define the average firing activity of the population. In this model, we are interested in how the population-averaged firing varies as a function of time and network parameters. Mathematically, we can describe the firing rate dynamic of a feed-forward network as:

$\tau \frac{dr}{dt} = -r + F(I_{ext})$

Here, $r(t)$ represents the average firing rate of the neural population of interest at time $t$, $\tau$ controls the timescale of teh evolution of the average firing rate, $I_{ext}$ represents the external input, and the transfer function $F(\cdot)$ (which can be related to the f-I curve of individual neurons described in the next sections) represents the population activation function in response to all received inputs. (which can be related to f-I curve of individual neurons described in the next sections) represents the population activation function in response to all received inputs.
"""

# ╔═╡ 47e70f44-4c85-411b-8547-6afd4c0ca655
md"""
## F-I curves

Let's first investigate the activation functions before simulating the dynamics of the entire population.

In this exercise, you will implement a sigmoidal **F-I** curve or transfer function $F(x)$, with gain $a$ and threshold level $\theta$ as parameters:

$F(x;a,\theta)=\frac{1}{1+e^{-a(x-\theta)}}-\frac{1}{1+e^{a\theta}}$
"""

# ╔═╡ a9d0dec1-8591-4977-b315-fa55fc4b278c
md"""
### Parameter exploration of F-I curve

Here's an interactive demo that shows how the F-I curve changes for different values of the gain and threshold parameters.

1. How does the gain parameter ($a$) affect the F-I curve?
    The parameter $a$ affects the slope of the sigmoid.
2. How does the threshold parameter ($\theta$) affect the F-I curve?
    The parameter $\theta$ affects the position of the sigmoid and can shift it left/right.

a = $(@bind a1 Slider(0.1:0.1:10; default=1.2, show_value=true))

θ = $(@bind θ1 Slider(0.1:0.1:10; default=2.8, show_value=true))
"""

# ╔═╡ a24ea7a9-da14-400e-b66d-110157a4968e
begin	
	x = 1:0.1:10
	params1 = initializeParams("SFF", a=a1, theta=θ1)
	WC = modelEquations("WC")
	f = sigmoid.(x, params1[:a], params1[:theta])
	plot(x, f, ylim=(0,1), color=:black, xlab="x (au)", ylab="F(x)", legend=false,
		linewidth=2, grid=false)
	
end

# ╔═╡ f96c5b37-4994-44e7-a29e-e8ebcd2dbb75
md"""
## Simulation scheme of dynamics

In more complicated cases, the exact solution of a given set of differential equations may be difficult or impossible to solve analytically. As we have seen before, we can use numerical methods, specifically the Euler method, to find the solution (that is, simulate the population activity).

### Parameter exploration of single population dynamics

Explore these dynamics of population activity in this interactive demo.

1. How does $r_{sim}(t)$ change with different $I_{ext}$ values?
2. How does it change with different $\tau$ values?

Note that, $r_{ana}(t)$ denotes the analytical solution. We do not learn how to solve this here, but in this particular case the ODE is linear, thus it is straightforward to obtain the solution, and it has a simple form (an exponential decay).

 $τ$ = $(@bind τ1 Slider(0.1:0.1:10; default=1, show_value=true))

 $I_{ext}$ = $(@bind Iₑ1 Slider(0:0.1:10; default=0, show_value=true))

 $r_{0}$ = $(@bind r₀1 Slider(0:0.1:10; default=0.2, show_value=true))

"""

# ╔═╡ 1b52e7f5-cd9e-4a85-a1df-02ad7c5cf426
begin
	params2 = initializeParams("SFF", tau = τ1, I=Iₑ1)
	
	r_sim = simulate(0:0.1:100, "SFF", params2, r₀1)
	Fᵢ = sigmoid.(Iₑ1 .* ones(length(r_sim)), params2[:a], params2[:theta])
	r_ana = r₀1 .+ (Fᵢ .- r₀1) .* (1 .- exp.(-(0:0.1:100) ./ params2[:tau]))
	
	plot(0:0.1:100, r_sim, color=:black, xlab="t (ms)", ylab="Activity r(t)",
		linewidth=2, grid=false, label="rₛᵢₘ", ylim=(0,1))
	plot!(0:0.1:100, r_ana, color=:blue, linestyle=:dash, linewidth=2, label="rₐₙₐ")
	plot!(0:0.1:100, Fᵢ, color=:red, linestyle=:dash, linewidth=2, label="Fₑₓₜ")
end

# ╔═╡ 5b73a10b-7bb0-47a0-9728-313efabc7045
md"""
### Discussion

Above, we have numerically solved a system driven by a positive input. Yet, $r(t)$ either decays to zero or reaches a fixed non-zero value.

1. Why doesn't the solution of the system "explode" in a finite time? In other words, what guarantees that $r(t)$ stays finite?

2. Which parameter would you change in order to increase the maximum value of the response?
"""

# ╔═╡ c8aed09f-fe0b-4335-960d-c72591fb9d8f
md"""
## Dynamics of a single excitatory population

Here we will add a "feedback loop" representing connections between neurons in the population. Because the population is assumed to be excitatory, the feedback is positive.

$\frac{dr_{E}}{dt} = [-r_{E}+F(w\cdot r_{E}+I_{ext})]/τ$

## Finding fixed points

### Visualization of fixed points

Let us use the techniques that we have developed in the past two weeks. As you should appreciate by now, when it is not possible to find the solution analytically, a graphical approach can be taken. To that end, it is useful to plot $\frac{dr_{E}}{dt}$ as a function of $r_{E}$. The values of $r_{E}$ for which the plotted function crosses zero on the y axis correspond to fixed points. Here, let us, for example, set $w = 5.0$ and $I_{ext} = 0.3$. Then, plot $\frac{dr_{E}}{dt}$ as a function of $r_{E}$, and check for the presence of fixed points.
"""

# ╔═╡ 26cc2b71-855b-4162-951d-4ba25d9ea88a
begin
	function drdt(x, w, I, a, theta, tau) 
		return (-x + sigmoid(w * x + I, a, theta))/tau
	end
	
	r = 0:0.001:1
	params3 = initializeParams("SFF", w=5.0, I=0.3)
	
	dr2 = drdt.(r,params3[:w], params3[:I], params3[:a], params3[:theta], params3[:tau])
	
	plot(r, dr2, xlim=(0,1), color=:black, legend=false, xlab="rₑ", ylab="drₑ/dt")
	hline!([0], color=:black, linestyle=:dash)
end

# ╔═╡ bc55f0f2-b7af-4204-91dc-605e7e27aef2
md"""
### Numerical calculation of fixed points

We will now find the fixed points numerically. To do so, we need to specify initial values ($r_{guess}$) for the root-finding algorithm to start from. From the line $\frac{dr_{E}}{dt}$ plotted above in the last exercise, initial values can be chosen as a set of values close to where the line crosses zero on the y axis (real fixed point).

The next cell defines a helper function that we will use:

`findFixedPoints(xGuess, func; params, Iₑ)` uses a root-finding algorithm to locate a fixed point near a given initial value. If `xGuess` is an array it will find the roots nearest each of the elements. `params` and `Iₑ` are optional arguments if model parameters are required for the function provided or if there is an external input respectively.


"""

# ╔═╡ 1cff1311-dece-46eb-b7e6-91619863d7b7
begin
	function findFixedPoints(xGuess::Vector, func, params)

    zeroArr = repeat([zeros(2)], length(xGuess))
    for i in 1:length(xGuess)
        zeroArr[i] = nlsolve(x -> func(x, params), 
                            xGuess[i], method=:newton).zero
    end
    return zeroArr
end

	xGuesses= [0.6, 0.1, 0.8];
	println(nlsolve(x -> drdt(x, params3[:w], params3[:I], params3[:a], params3[:theta], params3[:tau]), xGuesses[1], method=:newton).zero)
end;

# ╔═╡ 44d0770d-53fa-4e24-9b28-d7182c6a3504
begin
	fixedPoints = findFixedPoints(xGuesses, drdt, params3)
	
	plot(r, dr2, xlim=(0,1), color=:black, legend=false, xlab="rₑ", ylab="drₑ/dt")
	hline!([0], color=:black, linestyle=:dash)
	scatter!(fixedPoints, zeros(length(fixedPoints)), color=:black, markersize=8)
end

# ╔═╡ a6bf8851-86b9-4579-81f4-f3ac7d266bfb
md"""
### Fixed points as a fucntion of recurrent and external inputs.

You can now explore how the previous plot changes when the recurrent coupling $w$ and the external input $I_{ext}$ take different values. How does the number of fixed points change?

 $w$ = $(@bind w2 Slider(0:1:20; default=5, show_value=true))

 $I_{ext}$ = $(@bind Iₑ2 Slider(0:0.1:10; default=0.3, show_value=true))

"""

# ╔═╡ 2570bd70-4fc9-4c78-af62-53757cad1e74
begin
	params4 = initializeModel(w=w2)
	dr3 = drₑdt(r,params4, Iₑ=Iₑ2)
	fixedPoints2 = findFixedPoints(xGuesses, drₑdt, params=params4, Iₑ=Iₑ2)
	plot(r, dr3, xlim=(0,1), color=:black, legend=false, xlab="rₑ", ylab="drₑ/dt")
	hline!([0], color=:black, linestyle=:dash)
	scatter!(fixedPoints2, zeros(length(fixedPoints2)), color=:black, markersize=8)
end

# ╔═╡ 38683a9f-a3ca-4da8-84e4-86844e3fad56
md"""
### Relationship between trajectories & fixed points

Let's examine the relationship between the population activity over time and the fixed points. 

Here, let us investigate the dynamics of $r_{E}(t)$ starting with different initial values $r_{E}(0) = r_{init}$.

We will also plot next to it the trajectories of $r(t)$ with $r_{init} = 0.0, 0.1, 0.2, ..., 0.9.$

 $r_{0}$ = $(@bind r₀2 Slider(0:0.01:1; default=0.2, show_value=true))
"""

# ╔═╡ c69e49a8-eb85-42fa-813a-a4f761154fe5
begin
	params5 = initializeModel(w = 5.0)
	r_sim2 = rk1(dr, 0, 0.1, 200, params5, r₀2, Iₑ=0.3)
	l1 = @layout [a b]
	
	p1 = plot(r_sim2.t, r_sim2.x, color=:black, xlab="t (ms)", ylab="Activity r(t)",
		linewidth=2, grid=false, label=false, ylim=(0,1))
	
	p2 = plot(r_sim2.t, rk1(dr, 0, 0.1, 200, params5, 0.0, Iₑ=0.3).x, alpha=1.0,
			label="r₀= 0.0", color=:blue, xlab="t (ms)")

	for r₀ in 0.1:0.1:0.9
		plot!(r_sim2.t, rk1(dr, 0, 0.1, 200, params5, r₀, Iₑ=0.3).x, alpha=1-r₀, 
			label="r₀= $r₀", color=:blue, title="Two (three?) Steady States?", 					titlefontsize=8)
	end
	
	plot(p1, p2, layout=l1, nrow=1, size=(700,350))
end

# ╔═╡ 2ac252aa-926b-4649-bb22-59a57f2ee00e
md"""
We have three fixed points but only two steady states with a finite basin of attraction. It turns out that the stability of the fixed points matters. If a fixed point is stable, a trajectory starting near that fixed point will stay close to that fixed point and converge to it (the steady state will equal the fixed point). If a fixed point is unstable, any trajectories starting close to it wwill diverge and go towards stable fixed points. In fact, the only way for a trajectory to reach a stable state at an unstable fixed point is if the initial value **exactly** equals the value of the fixed point.
"""

# ╔═╡ Cell order:
# ╟─dfdde882-6871-47ea-a935-c33f3794f7c1
# ╠═743f4cc6-6bd2-491e-8a64-5947554bc839
# ╟─60d66ee0-f393-11eb-0f70-214941234e7c
# ╠═47e70f44-4c85-411b-8547-6afd4c0ca655
# ╟─a9d0dec1-8591-4977-b315-fa55fc4b278c
# ╠═a24ea7a9-da14-400e-b66d-110157a4968e
# ╟─f96c5b37-4994-44e7-a29e-e8ebcd2dbb75
# ╟─1b52e7f5-cd9e-4a85-a1df-02ad7c5cf426
# ╟─5b73a10b-7bb0-47a0-9728-313efabc7045
# ╠═c8aed09f-fe0b-4335-960d-c72591fb9d8f
# ╠═26cc2b71-855b-4162-951d-4ba25d9ea88a
# ╟─bc55f0f2-b7af-4204-91dc-605e7e27aef2
# ╠═1cff1311-dece-46eb-b7e6-91619863d7b7
# ╟─44d0770d-53fa-4e24-9b28-d7182c6a3504
# ╟─a6bf8851-86b9-4579-81f4-f3ac7d266bfb
# ╟─2570bd70-4fc9-4c78-af62-53757cad1e74
# ╟─38683a9f-a3ca-4da8-84e4-86844e3fad56
# ╟─c69e49a8-eb85-42fa-813a-a4f761154fe5
# ╟─2ac252aa-926b-4649-bb22-59a57f2ee00e
