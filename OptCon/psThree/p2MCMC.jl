using Distributions
using Plots
using LinearAlgebra
using Printf
using StatsBase
pyplot()

N = 10000
I = 1000
T = 100
S = 1000

priorMuBeta = 4.0
priorMuSigma = 1.0
priorTauBeta = 2.0
priorTauSigma = 1.0

betaTruth = 5.0
tauTruth = 1.0

function CalculateAcceptanceRate( theta::Vector{Float64}, N::Int64)
    nDiff = 0.0
    for i in 1:N
        if( theta[i+1] != theta[i])
            nDiff += 1
        end
    end
    #return nDiff
    return nDiff / convert(Float64,N)
end

function SimulateData( I, T, β, σ², τ, x)
    X = Matrix{Float64}(undef,I,T)
    Y = Matrix{Float64}(undef,I,T)
    α = rand( Normal(0.0, tauTruth), I)
    for i in 1:I
        X[i,:] = rand( Normal( 10.0, 5.0), T)
        Y[i,:] .= X[i,:].*betaTruth .+ α[i]
    end    
end

function SimulateLogitData()
    X = Matrix{Float64}(undef,I,T)
    Y = Matrix{Float64}(undef,I,T)
    α = rand( Normal(0.0, tauTruth), I)
    for i in 1:I
        X[i,:] = rand( Normal( 0.0, 1.0), T)
        for j in 1:T
            Y[i,j] = round( logit(X[i,j]*betaTruth + α[i]) )#+ rand(Normal(0.0, .25),1)[1] )
        end
    end
end



function pFunStandard( β, τ, α, y, x, σ²) #, τ² )
    
    betaPrior = -.5*log( 2*pi*priorMuSigma) - .5*(priorMuBeta - β)^2/ priorMuSigma
        #(1/sqrt(2*pi*priorMuSigma))*exp( (priorMuBeta-β)^2 / (2*priorMuSigma) )
    tauPrior =-.5*log( 2*pi*priorTauSigma) - .5*(priorTauBeta - β)^2/ priorTauSigma
        #(1/sqrt(2*pi*priorTauSigma))*exp( (priorTauBeta-τ)^2 / (2*priorTauSigma) )
    likelihood = sum(-.5*log( 2*pi*σ²) - .5*(y[j,i] - x[j,i]*β - α)^2/ σ² for (i,j) in zip(1:I,1:T)) 
    
    return exp(likelihood)#+betaPrior+tauPrior)#1.0 / sqrt( 2 * pi * σ²) * exp( -.5*(y - x*β)^2 / σ²)
    #return alphaDensity*yDensity
end

function logit( x::Float64 )
    return exp(x) / ( 1.0 + exp(x))
end

function logitMinus( x::Float64)
    return 1.0 / (1.0+exp(x))
end



function pFunLogit( β, τ, α, y, x)
    # Now lets consider when $Y \sim Bernoulli( \ell( x \beta + \alpha_i ))$
    # Where $\ell(x) = \frac{\exp(x)}{1+\exp(x)}
    # So the likelihood function is given by the pdf: $\ell(x)^y (1 - \ell(x))^(1-y)
    # Log likelihood is: $y \log \ell(x) + (1-y) \log ( 1 - \ell(x))

    betaPrior = -.5*log( 2*pi*priorMuSigma) - .5*(priorMuBeta - β)^2/ priorMuSigma
        #(1/sqrt(2*pi*priorMuSigma))*exp( (priorMuBeta-β)^2 / (2*priorMuSigma) )
    tauPrior =-.5*log( 2*pi*priorTauSigma) - .5*(priorTauBeta - β)^2/ priorTauSigma
        #(1/sqrt(2*pi*priorTauSigma))*exp( (priorTauBeta-τ)^2 / (2*priorTauSigma) )
    likelihood = sum( y[j,i]*log(logit(x[j,i]*β + α)) +
                      (1-y[j,i])*log(logitMinus(x[j,i]*β + α)) for (i,j) in zip(1:I,1:T))
    return exp(likelihood+betaPrior+tauPrior)
end


function betaFun( beta, betaOld )
    return 1 / (2*.1)
end

function betaSimFun( xOld )
    return rand(Uniform(xOld-.1,xOld+.1),1)[1]
end


function tauFun( tauNew, tauOld )
    return 1.0 / ( min(tauOld+.01,5.0)-max(tauOld-.01,0.025))
end

function tauSimFun( tauOld)
    return rand(Uniform(max(tauOld-.01,.025),min(tauOld+.01,5.0)),1)[1]
end

function qFun( beta, tau, betaOld, tauOld)
    return betaFun( beta, betaOld)*tauFun(tau,tauOld)
end



function StandardMCMC( startVal, N::Int64)
    β = Vector{Float64}(undef,N+1)
    τ = Vector{Float64}(undef,N+1)
    α = Vector{Float64}(undef,N+1)
    coinFlips = rand(Uniform(),N)
    β[1] = startVal[1]
    τ[1] = startVal[2]
    α[1] = startVal[3]
    for i in 1:N
        betaStar = betaSimFun( β[i])
        tauStar = tauSimFun(τ[i])#qSimFun( τ[i], qArgs )
        alphaStar = rand(Normal(0,tauStar),1)[1]

        p1 = pFunStandard( betaStar, tauStar, alphaStar, Y,X, 1.0 )
        # p1 = pFunLogit( betaStar, tauStar, alphaStar, Y,X )
        p2 = qFun(β[i], τ[i], betaStar, tauStar)
        p3 = pFunStandard( β[i], τ[i], α[i], Y,X, 1.0 )
        # p3 = pFunLogit( β[i], τ[i], α[i], Y,X )
        p4 = qFun(betaStar, tauStar, β[i], τ[i])

               
        if( coinFlips[i] <= p1*p2 / (p3*p4))
            β[i+1] = betaStar
            τ[i+1] = tauStar
            α[i+1] = alphaStar
        else
            β[i+1] = β[i]
            τ[i+1] = τ[i]
            α[i+1] = α[i]
        end
    end
    return [β, τ, α]
end

function MultiplyMCMC( startVal, N::Int64, S::Int64 )
    β = Vector{Float64}(undef,N+1)
    τ = Vector{Float64}(undef,N+1)
    α = Vector{Vector{Float64}}(undef,N+1)
    coinFlips = rand(Uniform(),N)
    β[1] = startVal[1]
    τ[1] = startVal[2]
    α[1] = ones(S)*startVal[3]#rand(Normal(0,τ[1]),S)
    for i in 1:N
        betaStar = betaSimFun( β[i])
        tauStar = tauSimFun(τ[i])#qSimFun( τ[i], qArgs )
        alphaStar = rand(Normal(0,tauStar),S)

        p1 = exp(sum( log(pFunStandard( betaStar, tauStar, alphaStarZ, Y,X, 1.0 )) for alphaStarZ in alphaStar ))
        p2 = qFun(β[i], τ[i], betaStar, tauStar)
        p3 = exp(sum( log(pFunStandard( β[i], τ[i], alphaStarZ, Y,X, 1.0 )) for alphaStarZ in α[i] ))
        p4 = qFun(betaStar, tauStar, β[i], τ[i])

        quant = p1*p2/(p3*p4)
        
        if( coinFlips[i] <= p1*p2/(p3*p4))
            β[i+1] = betaStar
            τ[i+1] = tauStar
            α[i+1] = alphaStar
        else
            β[i+1] = β[i]
            τ[i+1] = τ[i]
            α[i+1] = α[i]
        end
    end
    return [β, τ, α]
end
            

function PseudoMarginalMCMC( startVal, N::Int64, S::Int64, qFun, pFun, pArgs)
    β = Vector{Float64}(undef,N+1)
    τ = Vector{Float64}(undef,N+1)
    α = Vector{Vector{Float64}}(undef,N+1)
    coinFlips = rand(Uniform(),N)
    β[1] = startVal[1]
    τ[1] = startVal[2]
    α[1] = ones(S)*startVal[3]#rand(Normal(0,τ[1]),S)
    for i in 1:N
        betaStar = betaSimFun( β[i])
        tauStar = tauSimFun(τ[i])#qSimFun( τ[i], qArgs )
        alphaStar = rand(Normal(0,tauStar),S)

        p1 = mean(pFunStandard( betaStar, tauStar, alphaStarZ, Y,X, σ² ) for alphaStarZ in alphaStar)
        #p1 = mean(pFunLogit( betaStar, tauStar, alphaStarZ, Y,X ) for alphaStarZ in alphaStar)
        #println(p1)
        p2 = qFun(β[i], τ[i], betaStar, tauStar)
        p3 = mean(pFunStandard(β[i], τ[i], alphaStarZ, Y,X, σ² ) for alphaStarZ in α[i])
        #p3 =mean(pFunLogit(β[i], τ[i], alphaStarZ, Y,X ) for alphaStarZ in α[i])
        p4 = qFun(betaStar, tauStar, β[i], τ[i])

        quant = p1*p2/(p3*p4)
        
        if( coinFlips[i] <= p1*p2/(p3*p4))
            β[i+1] = betaStar
            τ[i+1] = tauStar
            α[i+1] = alphaStar
        else
            β[i+1] = β[i]
            τ[i+1] = τ[i]
            α[i+1] = α[i]
        end
    end

    return [β, τ, α]
end


p1 = histogram( β[2000:end], title ="\$\\beta\$", normalize=:pdf )
p2 = histogram( τ[2000:end], title="\$\\tau\$", normalize=:pdf )
p3 = plot( autocov( β[2000:end] ), seriestype=:scatter, title="\$\\beta\$ ACF" )
p4 = plot( autocov( τ[2000:end] ), seriestype=:scatter, title="\$\\tau\$ ACF")

plot( p1,p2, p3,p4, layout=(2,2), legend = false)
savefig("Logit_A.pdf")

likelihoods =  Vector{Float64}(undef,N+1)
for i in 1:(N+1)
    likelihoods[i] = mean(pFunStandard(β[i], τ[i], alphaStarZ, Y,X, σ² ) for alphaStarZ in α[i])
end

