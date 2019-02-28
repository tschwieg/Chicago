using Distributions
using JuMP
using Gurobi
using Ipopt

srand(235711)

S = 50
T = 1000
α = 3.0
δ = 6.0

function SimulateFirmEntry(  α::Float64, δ::Float64, T::Int64)
    x = rand(Bernoulli(.5),T)+1.0
    ϵ₁ = rand(Gumbel(),T)
    ϵ₂ = rand(Gumbel(),T)

    x = convert.(Int64,x)

    #Pick the easy equilibrium
    pEntry = [.5, .7846]
    pX = [pEntry[x[i]] for i in 1:T]

    entryOne = [rand( Bernoulli(pX[i]),1)[1] for i in 1:T]
    entryTwo = [rand( Bernoulli(pX[i]),1)[1] for i in 1:T]

    return entryOne,entryTwo,x
end


    
function EstimateData( entryOne::Vector{Int64}, entryTwo::Vector{Int64},
                       x::Vector{Int64}, T::Int64)

    m = Model(solver = IpoptSolver())
    @variable( m, 0.0 <= p[1:2,1:T] <= 1.0)
    @variable(m, 3.0 <= α <= 10.0)
    @variable(m, 1.0 <= δ <= 10.0)
    
    @NLconstraint( m, EquilibriumOne[t=1:T],
                   log(p[1,t]) == x[t]*α - δ*p[2,t] - log(1 + exp(x[t]*α - δ*p[2,t])) )

    @NLconstraint( m, EquilibriumTwo[t=1:T],
                 log(p[2,t]) == x[t]*α - δ*p[1,t] - log(1 + exp(x[t]*α - δ*p[1,t])) )

    
    @NLobjective( m, Max, sum( entryOne[i]*log(p[1,i]) + (1-entryOne[i])*log( 1.0 - p[1,i] ) + entryTwo[i]*log(p[2,i]) + (1-entryTwo[i])*log( 1.0 - p[2,i] ) for i in 1:T ) )
    
    status = solve(m)
    println(getvalue(α))
    println(getvalue(δ))
    return [getvalue(α), getvalue(δ)]
end

alphaDraws = Vector{Float64}(S)
deltaDraws = Vector{Float64}(S)

for i in 1:S
    c = EstimateData( SimulateFirmEntry( α, δ, T )..., T )
    alphaDraws[i] = c[1]
    deltaDraws[i] = c[2]
end

̂α = mean( alphaDraws )
̂δ = mean( deltaDraws )
