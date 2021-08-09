
function OrnsteinUhlenbeck(tArray, tau, signal; seed=nothing)
	
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
		I[i+1] = I[i] + dt/tau * (0. - I[i]) + sqrt(2 * dt/tau) * signal * noise[i+1]
	end

	return I
end