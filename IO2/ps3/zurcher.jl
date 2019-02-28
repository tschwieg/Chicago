using CSV
using DataFrames
using JuMP
using Ipopt

df = CSV.read( "ps3_mileage.csv" )
describe(df)

#0,1,2,3,4,5,6,7,8,9,10+
bins = [1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,maximum(df[:,1])]
K = length(bins)

T = size(df,1)

binSpots = Vector{Int64}(size(df,1))

lb = 0.0
for j in 1:K
    println(bins[j])
    for i in 1:T
        if df[i,1] > lb && df[i,1] <= bins[j]
            binSpots[i] = j
        end
    end
    lb = bins[j]
end


a = Vector{Int64}(T)
a .= 1

transMat = zeros(2,K,K)
for i in 2:T
    # We need to impose that this matrix is symmetric
    if binSpots[i] < binSpots[i-1]
        a[i] = 2
        transMat[2,binSpots[i-1],binSpots[i]] += 1.0
        continue
    end
    
    transMat[1,binSpots[i-1],binSpots[i]] += 1.0
end

for i in 1:K
    #Stochastic Matrices have their columns sum to one.
    normalizerNoFix = sum( transMat[1,i,j] for j in 1:K)
    normalizerFix = sum( transMat[2,i,j] for j in 1:K)
    for j in 1:K
        transMat[1,i,j] /= normalizerNoFix
        if normalizerFix > 0.0
            transMat[2,i,j] /= normalizerFix
        end
        
    end
end


function u( i::Real, j::Real, θ1::Real, θ2::Real, θ3::Real)
    xt = j + .5
    if i == 1
        return -(θ1*xt + θ2*xt*xt)
    else
        return -θ3
    end
end

    

β = .9

# First lets get some results using MPEC
m = Model( solver=IpoptSolver())

JuMP.register(m, :u, 5, u, autodiff=true)

@variable( m, θ[i=1:3] )
@variable( m, vJ[i=1:2,j=1:K])

#@NLparameter( m, bins[t=1:T] == binSpots[t], Int)
#@NLparameter(m, A[t=1:T] == a[t])
@NLparameter( m, Pr[p=1:2,i=1:K,j=1:K] == transMat[p,i,j])

@NLexpression( m, logDenom[j=1:K],
               log( sum( exp(vJ[i,j]) for i in 1:2)))

@NLconstraint( m, MPEC[i=1:2,j=1:K], vJ[i,j] == u(i,j,θ[1],θ[2],θ[3]) +
               β*sum( log(sum(exp(vJ[k,ℓ]) for k in 1:2))*Pr[i,j,ℓ]
                      for ℓ in 1:K)*(1.0 / K) )


@NLobjective(m, Max, sum((a[t]-1)*(vJ[2,binSpots[t]]) +
                         (2-a[t])*(vJ[1,binSpots[t]]) -
                         logDenom[binSpots[t]] +
                         log( Pr[a[t-1],binSpots[t-1],binSpots[t]])
                         for t in 2:T))

status = solve(m)

getvalue(θ)
getvalue(vJ)
