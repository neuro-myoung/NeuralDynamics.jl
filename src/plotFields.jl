function arrow0!(x, y, u, v; as=0.07, lc=:black, la=1)
    nuv = sqrt(u^2 + v^2)
    v1, v2 = [u;v] / nuv,  [-v;u] / nuv
    v4 = (3*v1 + v2)/3.1623  # sqrt(10) to get unit vector
    v5 = v4 - 2*(v4'*v2)*v2
    v4, v5 = as*nuv*v4, as*nuv*v5
    plot!([x,x+u], [y,y+v], lc=lc,la=la)
    plot!([x+u,x+u-v5[1]], [y+v,y+v-v5[2]], lc=lc, la=la)
    plot!([x+u,x+u-v4[1]], [y+v,y+v-v4[2]], lc=lc, la=la)
end

function plotField1D(func, xₘᵢₙ, xₘₐₓ, r, yrange, title="", N=500)
    xArr = xₘᵢₙ:(xₘₐₓ-xₘᵢₙ)/N:xₘₐₓ
    
    ## Define vector field display
    xVectArr = collect(xₘᵢₙ:(xₘₐₓ-xₘᵢₙ)/15:xₘₐₓ)[:]
    fxVectArr = func(xVectArr, r)
    xVectDir = fxVectArr ./ abs.(fxVectArr)
    fieldLength = xVectDir.* ((xₘₐₓ-xₘᵢₙ)/30)
    
    ## Custom plot
    plot(xArr, func(xArr, r), linewidth=3, legend=false,
    xlab="x", ylab="x'", ylim=yrange, title=title)
    for (x,y,u,v) in zip(xVectArr,zeros(length(xVectArr)),
            fieldLength, zeros(length(xVectArr)))
        display(arrow0!(x, y, u, v; as=1.8/(sqrt(xₘₐₓ-xₘᵢₙ)), lc=:red, la=3))
    end
    annotate!(xₘᵢₙ + 0.05*(xₘₐₓ-xₘᵢₙ), 0.95*yrange[2], text("r=$r", :left))
end