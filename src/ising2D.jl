function initState(params)
    """
    Given a structure of parameters and returns an initial state for the system in a 2D Ising simulation.
    
    Arguments
    params: An object with initial conditions
    
    Output
    array: An Nx x Ny array of initial spins
    """
    return rand(params.Nx, params.Ny) .< (1 + params.M₀)/2
end

function chooseRandomSpin(xDim, yDim)
    """
    Given the X and Y dimensions of an arra selects a random element from that array.
    
    Arguments
    xDim: Size of the array in X
    yDim: Size of the array in Y
    
    Output
    array: An X and Y index chosen randomly
    """
    return [rand(1:yDim), rand(1:xDim)]
end

function getNeighbors(loc, xDim, yDim)
    """
    Returns a list of nearest neighbors by Manhattan distance for a given index
    
    Arguments
    loc: Index in an array
    xDim: Size of the array in X
    yDim: Size of the array in Y
    
    Output
    array: An array of tuples with the indices of nearest neighbors
    """
    neighbors = [] # Neighbors are pts on the grid with a Manhattan distance of 1
    
    for step in (-1,1)
        neighbor = ( loc[1], loc[2] + step)
        if loc[2] + step == 0 || loc[2] + step > xDim
            continue
        else
            push!(neighbors, neighbor)
            neighbor = ( loc[1] + step, loc[2])
            if loc[1] + step == 0 || loc[1] + step > yDim
                continue
            else
                push!(neighbors, neighbor)
            end
        end
    end
    return neighbors
end

function singleStep!(X, loc, params)
    """
    Performs a single step in the Ising model given a particular state, particle, and parameters.
    
    Arguments
    X: 2D bitarray giving the current state of the simulation
    loc: Indices indicating the location of a particular molecule in the simulation
    params: An object with initial conditions
    
    Output
    array: Modifies the original X based on the Ising model.
    """
    
    #Metropolis-Hasting (calculate local field)
    heff = params.h #external field
    
    for n in getNeighbors(loc, params.Nx, params.Ny)
        # Global field - NN fields weighted by J 
        heff = heff - params.J * (-1)^X[n[1], n[2]]
    end
    
    # Local energy of the spin
    e₀ = heff*(-1)^X[loc[1], loc[2]]
    
    # Check to see if new state is favored & flip if true
    Δe = -2*e₀
    if Δe < 0 || rand() < exp(-Δe/params.T)
        X[loc[1], loc[2]] = !X[loc[1], loc[2]]
    end		
end

function magnetization(X, params)
    """
    Calculates the net magnetization of the system in an Ising model.
    
    Arguments
    X: 2D bitarray giving the current state of the simulation
    params: An object with initial conditions
    
    Output
    array: A float indicating the net magnetization of the simulation in its current state.
    """
	return 2 * sum(X) / (params.Nx * params.Ny) -1 
end


function simulateIsing2D(params, tsteps = 10000, Nhist = 100)
    """
    Iterative simulation of a 2D Ising model.
    
    Arguments
    params: An object with initial conditions
    tsteps: An integer indicating the total number of steps in the simulation (default 10000)
    Nhist: An integer indicating the total number of snapshots to take along the simulation path (default 100)
    
    Output
    Mhist: A 1D array of magnetization states for the system at each iteration of the simulation.
    XHist: A 3D array of snapshots collected during the simulation.
    """
    println("Running...")
	snapshots = 1:Int64(tsteps/Nhist):tsteps+Int64(tsteps/Nhist)
	snapshotInd = 1
		
	# Magnetization history
	Mhist = []
		
	X = initState(params)
	Xhist = fill(0, (Nhist, params.Nx, params.Ny))
	thisT = []
	push!(Mhist, magnetization(X, params))
		
	for t in 1:tsteps
		if snapshots[snapshotInd] == t
			Xhist[snapshotInd,:,:] = X
			push!(thisT, t)
			snapshotInd += 1
		end
		singleStep!(X, chooseRandomSpin(params.Nx, params.Ny), params)
		push!(Mhist, magnetization(X,params))
	end
		
	if snapshotInd < length(snapshots)
		if snapshots[snapshotInd] == tsteps
			Xhist[snapshotInd, :, :] =X
			push!(thisT, tsteps)
		end
	end
	println("DONE")
		
	return Mhist, Xhist
end