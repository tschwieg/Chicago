using Random
using Latexify
using Distributions

thetapos = [0.5,1,10]
npos = [2,5,20,100]

Random.seed!( 235711 )

#This just allocates a bunch of arrays to fit all the data we're asked to simulate
X = zeros( length(thetapos), length(npos) )
hatABS = zeros( length(thetapos), length(npos) )
tildeABS = zeros( length(thetapos), length(npos) )
hatMSE = zeros( length(thetapos), length(npos) )
tildeMSE = zeros( length(thetapos), length(npos) )
ind = zeros( length(thetapos), length(npos) )

tempx = zeros(10000,maximum(npos))
tempHatTheta = zeros(10000)
tempTildeTheta = zeros(10000)
    
for i in 1:length(thetapos)
    theta = thetapos[i]
    dist = Uniform( theta, 2*theta)
    for j in 1:length(npos)
        n = npos[j]
        for k in 1:10000
            tempx[k,1:n] = rand( dist, n)
            tempHatTheta[k] = maximum(tempx[k,1:n])/2.0
            tempTildeTheta[k] = (2.0/3.0)*mean(tempx[k,1:n])
        end

        tempHatABS = abs.( tempHatTheta .- theta)
        hatABS[i,j] = mean( tempHatABS )

        tempTildeABS = abs.( tempTildeTheta .- theta)
        tildeABS[i,j] = mean(tempTildeABS)

        tempHATMSE = tempHatABS .* tempHatABS
        hatMSE[i,j] = mean(tempHATMSE)

        tempTildeMSE = tempTildeABS .* tempTildeABS
        tildeMSE[i,j] = mean( tempTildeMSE)

        temp = tempTildeMSE .> tempHATMSE
        ind[i,j] = mean(temp)
    end
end
latexify( hatABS )
latexify( tildeABS )
latexify( hatMSE )
latexify( tildeMSE )
latexify( ind )
