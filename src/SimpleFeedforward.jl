function sff_drdt(r, w, I, a, theta, tau)
	return (-r + sigmoid(w * r + I, a, theta))/tau
end