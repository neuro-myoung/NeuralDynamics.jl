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

# ╔═╡ de1d9360-df75-11eb-13c8-b1578d07db14
begin
	import Pkg
	Pkg.activate("../environments/v1.6")
	using NeuralDynamics, PlutoUI, Plots, StatsPlots
	TableOfContents()
	nbsp =  html"&nbsp" 
end

# ╔═╡ 6a56f8bb-b501-43be-ae1c-15cf00d4317e
md"# Bifurcations and phase transitions in neurons and their networks"

# ╔═╡ 6c570eef-493a-4240-a8d3-e6198e583a89
md"## Exercise 1"

# ╔═╡ 125c4637-31f4-4e30-a113-e87b08c7a7ec
md""" 
Let

$$\dot x = f(x)$$

and

a) $$f(x)=r-x-e^{-x}$$

b) $$f(x)=rlnx+x-1$$

c) $$f(x)=x+tanh(rx)$$

d) $$f(x)=rx-sin(x)$$

**Using the code below**, in each case plot $\dot x$ as a function of $x$ for different values of the control parameter $r$. You will have to fill out blanks denoted by "..."

Sketch (pen and paper is fine) all the qualitatively different vector fields that occur as $r$ is varied. Find values of $r$ at which bifurcations occur,
and classify each bifurcation as saddle-node, transcritical, supercritical pitchfork, or subcritical pitchfork.

"""

# ╔═╡ 019a64b5-71b7-4f0e-b05b-6baaebf7d780
begin
	function f1(x, r)
		return r .- x .- exp.(-x)
	end
	
	function f2(x, r)
		return r .* log.(x) .+ x .- 1
	end
	
	function f3(x, r)
		return x .+ tanh.(r .* x)
	end
	
	function f4(x, r)
		return r .* x .- sin.(x)
	end
end;

# ╔═╡ 5b0e0252-f10e-498c-8b08-e4ac1b67d0b2
md"""
### Set Parameters

r1: $(@bind r1 Slider(0.6:0.01:2))
r2: $(@bind r2 Slider(-4:0.1:2))

r3: $(@bind r3 Slider(-5:0.01:5))
r4: $(@bind r4 Slider(-2:0.005:2))
"""

# ╔═╡ 24465a53-7f82-4d3d-95fa-9009f8ac675f
p1 = plotField1D(f1, -1, 1, r1, (-0.5,0.5), "Saddle-node");

# ╔═╡ 306336c2-70cd-4c53-bb10-42d659728fb5
p2 = plotField1D(f2, 0.01, 5, r2, (-1,1), "Transcritical");

# ╔═╡ 7f4f1a8d-9635-4145-82ce-6d027a89fe99
p3 = plotField1D(f3, -3, 3, r3, (-1,1), "Subcritical Pitchfork");

# ╔═╡ 5cea4d67-b12e-4c3b-870b-c1c35d9520a0
p4 = plotField1D(f4, -20, 20, r4, (-2,2), "Subcrit Pitchfork & SN");

# ╔═╡ aab9c3dd-4281-4478-b7c1-bdf63cf14e80
begin
	l1 = @layout [a b; c d]	
	plot(p1, p2, p3, p4, layout = l1, size=(650,600))
end

# ╔═╡ e383b18e-9c8b-4549-b6ea-9ddd0196335e
md"## Exercise 2"

# ╔═╡ c639147c-0c18-45b1-b3a1-f80e27596d06
md"""
Plot bifurcation diagrams ($f(x)$'s as before), i.e., the values of $x^{*}$ vs $r$. There is an easy way to do this, and a harder (but perhaps more intuitive) using a root finding algorithm (e.g. Newton-Raphson).

Note the $x^{*}$ denotes a fixed point of the flow, so we need to solve the equation

$f(x^{*})=0$

The easy way is based on the observation that often the dependance of $f(x)$ on the control parameter is simpler than on $x$. You can write your own code, or use the code provided below. You still have to figure out what "rOfx(x)" function should be, and provide a reasonable range of values for x.
"""

# ╔═╡ c15d8a47-9934-4659-a0d0-24d797821099
begin
	function rOfx1(x)
		return x .+ exp.(-x)
	end
	
	function rOfx2(x)
		return (1 .- x) ./ log.(x)
	end
	
	function rOfx3(x)
		return atanh.(-x) ./ x
	end
	
	function rOfx4(x)
		return sin.(x) ./ x
	end
end;

# ╔═╡ e285fea9-2964-498b-9f72-612d7254746d
begin
	l2 = @layout [a b;
		c d]
	
	p5 = bifurcationDiagram(rOfx1, f1, -1, 1)
	p6 = bifurcationDiagram(rOfx2, f2, 0.001, 5)
	addBifurcation!(1, f2, -2.5, -0.001);
	p7 = bifurcationDiagram(rOfx3, f3, -1, 1)
	addBifurcation!(0, f3, -3.5, -0.5);
	p8 = bifurcationDiagram(rOfx4, f4, -20, 20)
	addBifurcation!(0, f4, -0.2, 1.2);
	
	plot(p5, p6, p7, p8, layout = l2, size=(650,600))
end

# ╔═╡ dde469cf-3109-44bc-9c10-b70208a8f4d9
md"## Exercise 3"

# ╔═╡ 77901a18-b6a3-430c-adfe-1fd3d4200398
md"""
In this exercise you are finally "on your own".
Implement Euler's method and, for a fixed $r$ and a chosen flow $f(x)$ from Exercise 1, plot $x(t)$ for a few different initial conditions.

Analyze and answer:
- Do results depend on $\Delta t$? How? It is instructive to check this using $f(x) = rx(1-x)$.
- Are your predictions, summarized in the bifurcation diagrams, confirmed?
- Are lower values of $\Delta t$ always better?
- Could you think of any better ways of solving these equations other than Euler's method?

"""

# ╔═╡ c7df73ba-3f9e-4750-9b0a-b25931b815b5
md"""
### Set Parameters

$(@bind h Slider(0.01:0.01:3,default=0.1)) 
$(@bind x₀ Slider(-10:0.01:10, default=0))
$(@bind r Slider(-10:0.1:10, default=0))
"""

# ╔═╡ 5a7e7a81-6a27-4445-ba16-76e721944334
md"""
Δt: $(h) $nbsp $nbsp $nbsp $nbsp $nbsp $nbsp $nbsp $nbsp  $nbsp $nbsp $nbsp $nbsp  $nbsp $nbsp $nbsp $nbsp 
x₀: $(x₀)
$nbsp $nbsp $nbsp $nbsp $nbsp $nbsp $nbsp $nbsp  $nbsp $nbsp $nbsp $nbsp  $nbsp $nbsp $nbsp $nbsp
r: $(r)
"""

# ╔═╡ 53389946-dda5-427c-8524-d5e8fb690161
begin
	test = rk1(f4, 0, x₀, r, h, 1000)
	test2 = rk2(f4, 0, x₀, r, h, 1000)
	@df test plot(:t, :x, xlab="t", ylab="x", label="Euler")
	@df test2 plot!(:t, :x, xlab="t", ylab="x", label="Improved Euler", 
		linestyle=:dash, color=:purple)
end

# ╔═╡ 254523da-ba44-4fe2-87f6-147b48f0edd9
md"""
## Answers

The results of Euler's method do not depend on Δt so long as Δt is small. If it is too large the value will oscillate about the asymptotic value or blow up.

So long as the initial guess is reasonable over time the system approaches the stable fixed points shown in the bifurcation diagram as predicted following the vector field.

Lower values of Δt are not always better in that they incur an additional computational cost. Ideally the step sizes would be larger farther away from the fixed point (while the slope is large) and smaller as the system approaches the fixed point (the slope is shallow).

An adaptive algorithm that takes into account the local slope (second derivative?) when determining step size may improve performance. Using a higher order polynomial approximation as opposed to linear (Taylor Expansion). Also taking the average of the slope of the field at x+h and the slope at the initial point may reduce the error.
"""

# ╔═╡ Cell order:
# ╟─6a56f8bb-b501-43be-ae1c-15cf00d4317e
# ╠═de1d9360-df75-11eb-13c8-b1578d07db14
# ╟─6c570eef-493a-4240-a8d3-e6198e583a89
# ╟─125c4637-31f4-4e30-a113-e87b08c7a7ec
# ╠═019a64b5-71b7-4f0e-b05b-6baaebf7d780
# ╟─24465a53-7f82-4d3d-95fa-9009f8ac675f
# ╟─306336c2-70cd-4c53-bb10-42d659728fb5
# ╟─7f4f1a8d-9635-4145-82ce-6d027a89fe99
# ╟─5cea4d67-b12e-4c3b-870b-c1c35d9520a0
# ╟─5b0e0252-f10e-498c-8b08-e4ac1b67d0b2
# ╟─aab9c3dd-4281-4478-b7c1-bdf63cf14e80
# ╟─e383b18e-9c8b-4549-b6ea-9ddd0196335e
# ╟─c639147c-0c18-45b1-b3a1-f80e27596d06
# ╠═c15d8a47-9934-4659-a0d0-24d797821099
# ╟─e285fea9-2964-498b-9f72-612d7254746d
# ╟─dde469cf-3109-44bc-9c10-b70208a8f4d9
# ╟─77901a18-b6a3-430c-adfe-1fd3d4200398
# ╟─c7df73ba-3f9e-4750-9b0a-b25931b815b5
# ╟─5a7e7a81-6a27-4445-ba16-76e721944334
# ╠═53389946-dda5-427c-8524-d5e8fb690161
# ╟─254523da-ba44-4fe2-87f6-147b48f0edd9
