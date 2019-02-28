using Distributions

srand(235711)

θ = [.001,.1,.25,.5]
N = [5,20,50,100,500,1000]

critVal = -quantile( Normal( 0,1), .025)

M = 1000
confCheck = zeros(M,length(θ), length(N))
NconfCheck = zeros(M,length(θ), length(N))
for m in 1:M
    for t in θ
        for n in N
            Yes = Vector{Int64}(n)
            coinFlips = rand(Uniform(),n)
            questions = rand(Uniform(),n)
            for i in 1:n
                if( coinFlips[i] > .5)
                    Yes[i] = questions[i] <= .1
                else
                    Yes[i] = questions[i] <= t
                end
            end

            yBar = mean(Yes)
            thetaHat = 2*yBar - .1

            MarkovBound = sqrt(1/(.05*n))
            confCheck[m,findfirst(θ,t),findfirst(N,n)] = abs(thetaHat - t) < MarkovBound
            vHat = (4/n)*((1.0+10.0*thetaHat)/20.0)*((19.0 - thetaHat*10.0)/20.0)

            nBound = critVal*sqrt(vHat)
            NconfCheck[m,findfirst(θ,t),findfirst(N,n)] = abs(thetaHat - t) < nBound
        end
    end
end

println( "For Markov Bound: \n")
for t in 1:length(θ)
    println( "θ = ", θ[t])
    println("\n")
    for n in 1:length(N)
        println( "n = ", N[n], ". Percent Correct: ", mean(confCheck[:,t,n]) )
    end
    println("\n\n\n")
end


println( "For Normal Bound: \n")
for t in 1:length(θ)
    println( "θ = ", θ[t])
    println("\n")
    for n in 1:length(N)
        println( "n = ", N[n], ". Percent Correct: ", mean(NconfCheck[:,t,n]) )
    end
    println("\n\n\n")
end
        
        
        
