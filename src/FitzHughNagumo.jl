	## FitzHughNagumo model equations
	@. function nullclinewu(u, R, I)
		return u - (u^3)/3 + R*I
	end
	
	@. function nullclineww(u, b0, b1)
		return b0 + b1 * u
	end
	
	@. function dudt(u, w, tau1, R, I)
		return (u - (u^3)/3 - w + R*I)/tau1
	end
	
	@. function dwdt(u, w, b0, b1, tau2)
		return (b0 + b1*u - w)/tau2
	end
	