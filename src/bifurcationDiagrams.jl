function bifurcationDiagram(func1, func2, xₘᵢₙ, xₘₐₓ, N=1000)
    xArr = collect(xₘᵢₙ:((xₘₐₓ)-(xₘᵢₙ))/N:(xₘₐₓ))[:]
    r = func1(xArr)
    x⁺ = func2(xArr .+ 0.00001*1,r)
    x⁻ = func2(xArr .- 0.00001*1,r)
    c = repeat([:red], length(r))
    df = DataFrame(r = r, x = xArr, x⁺ = x⁺./abs.(x⁺),  x⁻ = x⁻./abs.(x⁻), c=c)
    for i in eachrow(df)
        if i.x⁺ != i.x⁻ && i.x⁺ == -1
            i.c = :blue
        else
            continue
        end
    end
    
    @df df plot(:r, :x, color=:c, linewidth=2, xlab="r", ylab="x*", legend=false)
end

function addBifurcation!(val, func, rₘᵢₙ, rₘₐₓ, N=100)
    range = (rₘₐₓ)-(rₘᵢₙ)
    r = collect(rₘᵢₙ-0.1*range:
        ((rₘₐₓ+0.1*range) - (rₘᵢₙ-0.1*range))/N:
        rₘₐₓ+0.1*range)[:]
    xArr = repeat([val], length(r))
    x⁺ = func(val .+ 0.001,r)
    x⁻ = func(val .- 0.001,r)
    c = repeat([:red], length(r))
    df = DataFrame(r = r, x = xArr, x⁺ = x⁺./abs.(x⁺),  x⁻ = x⁻./abs.(x⁻), c=c)
    for i in eachrow(df)
        if i.x⁺ != i.x⁻ && i.x⁺ == -1
            i.c = :blue
        else
            continue
        end
    end
    
    @df df plot!(:r, :x, color=:c, linewidth=2, legend=false)
end