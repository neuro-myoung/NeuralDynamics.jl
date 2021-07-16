### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ d45ca573-d7c2-4639-9a1b-108933f96644
begin
	import Pkg
	Pkg.activate("../environments/v1.6")
	using Plots, PlutoUI, NeuralDynamics, Statistics
	TableOfContents()
end

# ╔═╡ 221c650c-1203-4b7a-b131-04a2411d2377
md"# Import packages and use base environment"

# ╔═╡ 70cfde12-d501-45da-9432-e4d0645dc79e
md"Load in a few dependencies. All the helper functions and calculations are compiled in the package NeuralDynamics.jl and preloaded as well."

# ╔═╡ c42dc6c2-7a84-4def-a161-30cbaeeb3772
md"# Ising Model"

# ╔═╡ 4db9cde4-b04e-47fa-9a5b-94a310f9f6f6
md"""

## Exercise 1

Run simulations for different controol parameters $T$ (temperature) and $h$ (external field). Note the difference in the behavior of the system (magnetization M in particular) above and below the critical temperature.

Are the results affected by the value of the initial magnetization? Why?

$M=\frac{1}{N}\sum_{i=1}^{N}s_i\in[-1,1]$
"""

# ╔═╡ 1fb2ed0d-ba32-431d-8d7f-f35ebd17dbcb
md"### Set Initial Conditions"

# ╔═╡ a0d3244c-e80f-4e10-aac4-232b2810b49b
begin
	Tc = 2/log(1+sqrt(2));
	
	mutable struct Parameters
		Nx::Int32      # nrows
		Ny::Int32      # ncols
		J::Float64     # interaction strength (nearest neighbors)
		T::Float64     # temperature (kb = 1)
		h::Float64     # external field
		M₀::Float64    # initial magnetization
	end
	
	params = Parameters(150, 150, 1, Tc/2.5, 0, 0.5)
end

# ╔═╡ e63df9ed-6153-4e5b-980c-f7a94b00950e
md"### Run Simulation"

# ╔═╡ 9d2bf487-e0cf-4538-af8c-53d7e2313a1a
Mhist, X = simulateIsing2D(params, 2000000);

# ╔═╡ 62d15b1c-3a23-469d-a6d6-f2f76ecaddde
md"### Display Results"

# ╔═╡ f428cc65-723a-4b56-a596-d63067e6c618
md"Critical temperature according to Onsager's solution: $Tc"

# ╔═╡ f1b5b4c1-0239-454b-a2a5-947e082828cd
begin
	l1 = @layout [a [b; c]]
	
	p1 = plot(Mhist, legend=false, xlab="Iterations", ylab="Magnetization", 
		xformatter = :plain)

	p2 = heatmap(X[1,:,:], legend=false, title="Initial State", 
		axis=([], false), aspect_ratio=:equal, size=(300,300))
	p3 = heatmap(X[end,:,:], legend=false, title="Final State",
		axis=([], false), aspect_ratio=:equal, size=(300,300))
	
	plot(p1, p2, p3, layout=l1,size=(900,600))
end

# ╔═╡ 6d434821-d7f5-4f56-89ef-e1d0146d5567
@gif for i ∈ 1:size(X,1)
    heatmap(X[i,:,:], legend=false, axis=([], false), aspect_ratio=:equal, size=(600,600))
end

# ╔═╡ 737987d6-f98d-493c-b4f9-7b3f08a7e30b
md"""

## Exercise 2

Fill in the gaps in the code below. Plot the equilibrium magnetization as a function of temperature for a fixed value of $h$.

Note that we have to run multiple Monte Carlo simulations, which is time consuming. Start from a low number of time steps (e.g., $tsteps=1000$) to check your code. If everything works as expected, increase the number of time steps to $10^5$ (it will take approximately $3$ minutes to finish).

- Is the transition sharp? Why?
- What happens if the number of steps is too low?
"""

# ╔═╡ a3abdcdb-462e-44a2-a3f8-be5922c001fb
begin
	TArr = Tc/2:((3*Tc/2 - Tc/2)/10):3*Tc/2
	mArr = zeros(length(TArr))
		
	for i in 1:length(TArr)
		params.T = TArr[i]	
		mHist2, X2 = simulateIsing2D(params, 100000)
		mArr[i] = mean(mHist2[end-10000:end])
	end
	
	scatter(TArr, mArr, xlab="Temperature (kB)", ylab="Magnetization", legend=false)
	plot!([TArr[1], TArr[end]], [0, 0], color=:black, linetype=:dashed)
	scatter!([Tc],[0], color=:red, markersize=8)

end

# ╔═╡ Cell order:
# ╟─221c650c-1203-4b7a-b131-04a2411d2377
# ╟─70cfde12-d501-45da-9432-e4d0645dc79e
# ╠═d45ca573-d7c2-4639-9a1b-108933f96644
# ╟─c42dc6c2-7a84-4def-a161-30cbaeeb3772
# ╟─4db9cde4-b04e-47fa-9a5b-94a310f9f6f6
# ╟─1fb2ed0d-ba32-431d-8d7f-f35ebd17dbcb
# ╠═a0d3244c-e80f-4e10-aac4-232b2810b49b
# ╟─e63df9ed-6153-4e5b-980c-f7a94b00950e
# ╠═9d2bf487-e0cf-4538-af8c-53d7e2313a1a
# ╟─62d15b1c-3a23-469d-a6d6-f2f76ecaddde
# ╟─f428cc65-723a-4b56-a596-d63067e6c618
# ╟─f1b5b4c1-0239-454b-a2a5-947e082828cd
# ╠═6d434821-d7f5-4f56-89ef-e1d0146d5567
# ╟─737987d6-f98d-493c-b4f9-7b3f08a7e30b
# ╠═a3abdcdb-462e-44a2-a3f8-be5922c001fb
