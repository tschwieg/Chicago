using Optim
using Plots
gr()

N = 100
dCost = .25
u(α) = α^.5

p = prevY / N
pHealthy(α) = 1 - (1-p)^α
β = 1
γ = .25
r = .25
x = 10

decisionHealthy(α) = -1*(u(α) - dCost*α - β*pHealthy(α))


function TransitionMat( prevY, x )
   

    α_H = optimize(decisionHealthy, 0, 25).minimizer

    tMat = zeros(x+2,x+2)
    tMat[1,1] = 1 - pHealthy(α_H)
    tMat[1,2] = 1 - tMat[1,1]

    for i in 1:x
        tMat[1+i,2+i] = 1
    end
    tMat[x+2,1] = r
    tMat[x+2,x+2] = 1-r
    return tMat
end

function GenerateSick( start )
    
    state = zeros(x+2)'
    state[1] = N - start
    state[5] = start

    numSick = zeros(100)

    for i in 1:100
        mat = TransitionMat( state[5], x)
        state = state*mat
        numSick[i] = state[5]
    end
    return numSick
end

sick = GenerateSicK( 50 )
plot(sick)
