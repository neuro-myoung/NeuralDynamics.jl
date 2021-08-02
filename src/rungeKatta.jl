function rk1(func, t₀, dt, n, params, x₀)
    t = t₀:dt:(t₀ + n * dt)
    x = zeros(length(t))
    x[1] = x₀
    
    for i in 1:length(t)-1
        x[i+1] = x[i] + dt * func(x[i], params)
    end

    return DataFrame(t = collect(t)[:], x = x)
end

function rk1(func1, t₀, dt, n, params, x₀; Iₑ=0)
    t = t₀:dt:(t₀ + n * dt)
    x = zeros(length(t))
    x[1] = x₀
    if Iₑ == 0
        Iₑ = zeros(length(t))
    elseif Iₑ != 0 && length(Iₑ) == 1
        Iₑ = Iₑ .* ones(length(t))
    end

    for i in 1:length(t)-1
        dx = dt/params.τ * func1(x[i], params; Iₑ = Iₑ[i])
        x[i+1] = x[i] + dx
    end

    return DataFrame(t = collect(t)[:], x = x)
end

function rk2(func, t₀, dt, n, params, x₀)
    t = t₀:dt:(t₀ + n * dt)
    x = zeros(length(t))
    x[1] = x₀
    
    for i in 1:length(t)-1
        x[i+1] = x[i] + dt/2 * (func(x[i], params) + func(x[i]+dt*func(x[i], params), params))
    end
    
    return DataFrame(t = collect(t)[:], x = x)
end