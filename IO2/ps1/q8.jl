using DataFrames
using CSVFiles
using LinearAlgebra

#This takes a vector of M codified values and splits it into M-1
#columns of vectors that are dummies indiciating deviation from the
#first value.
function ReturnDummyMat( v::Vector)
    difVals = unique(v)
    mat = zeros(length(v),length(difVals)-1)
    for i in 1:(length(difVals)-1)
        mat[:,i] = v .== difVals[i]
    end
    return mat
end

#Builds the Y,X,Z matrices using columns from data as specified.
#regCols - exogenous X
#dummyCols - exogenous codified X to be turned into dummy variables
#endCols - endogenous X
#instCols - instruments
function DoEstimation( data, yCol, regCols, dummyCols, endCols, instCols)
    
    Y = data[yCol]
    N = length(Y)

    #base is the collection of exogenous variables in X
    base = ones(N)
    for col in regCols
        base = hcat( base, data[col] )
    end
    for col in dummyCols
        base = hcat( base, ReturnDummyMat(data[col]))
    end

    X = copy(base)
    for col in endCols
        X = hcat( X, data[col])
    end

    Z = copy(base)
    for col in instCols
        Z = hcat(Z, data[col])
    end

    #TSLS estimation using Z as the instruments.
    ProjectMat = Z*((Z'*Z) \ Z')
    β = (X' * ProjectMat * X) \ X'*ProjectMat*y
    return β
end

    


cereal = DataFrame(load("cereal_ps3.csv"))

describe(cereal)

describe(cereal[:city])

length(unique(cereal[:city]))

N = size(cereal)[1]

yCol = :share
regCols = [:sugar, :mushy]
dummyCols = [:firm, :brand, :city, :year, :quarter]
endCols = [:price]
instCols = [convert(Symbol, "z"*string(i)) for i in 1:20]

full_̂θ = DoEstimation( cereal, yCol, regCols, dummyCols, endCols, exoCols)


dummyCols = [:firm, :year, :quarter]
empty_̂θ = DoEstimation( cereal, yCol, regCols, dummyCols, endCols, exoCols)


dummyCols = [:firm, :brand, :year, :quarter]
brand_̂θ = DoEstimation( cereal, yCol, regCols, dummyCols, endCols, exoCols)


dummyCols = [:firm, :city, :year, :quarter]
city_̂θ = DoEstimation( cereal, yCol, regCols, dummyCols, endCols, exoCols)

    

        
