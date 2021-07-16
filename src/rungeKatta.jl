function rk1(func, t₀, x₀, r, h, n)
    t = t₀:h:(t₀ + n * h)
    x = zeros(length(t))
    x[1] = x₀
    
    for i in 1:length(t)-1
        x[i+1] = x[i] + h * func(x[i], r)
    end

    return DataFrame(t = collect(t)[:], x = x)
end

function rk2(func, t₀, x₀, r, h, n)
    t = t₀:h:(t₀ + n * h)
    x = zeros(length(t))
    x[1] = x₀
    
    for i in 1:length(t)-1
        x[i+1] = x[i] + h/2 * (func(x[i], r) + func(x[i]+h*func(x[i], r), r))
    end
    
    return DataFrame(t = collect(t)[:], x = x)
end