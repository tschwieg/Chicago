using DataFrames
using Query
using CSV
using Plots
pyplot()

df = CSV.read( "ps3_auction.csv")

nThreeBids  = @from i in df begin
    @where i.Size6 == 0
    @select {i.Value,i.BidC3}
    @collect DataFrame
end

plot( df[:Value], df[:BidC3], seriestype=:scatter)
x = 0:30
plot!( x, (2.0/3.0)*x)

N = size(df,1)


plot( df[:Value], df[:BidC6], seriestype=:scatter)
x = 0:30
plot!( x, (5.0/6.0)*x)


gridPoints = 0.0:.01:30.0

l = length(gridPoints)

empCDFThree = Vector{Float64}(undef,l)
empCDFSix = Vector{Float64}(undef,l)
empCDFNon = Vector{Float64}(undef,l)
for i in 1:l
    empCDFThree[i] = sum( df[:BidC3] .<= gridPoints[i]) / N
    empCDFSix[i] = sum( df[:BidC6] .<= gridPoints[i]) / N
    empCDFNon[i] = sum( df[:BidNC] .<= gridPoints[i]) / N
end

plot( gridPoints, empCDFThree, label="N = 3")
plot!( gridPoints, empCDFSix, label="N = 6")
plot!( gridPoints, empCDFNon, label="NC")

#The probability thatI win in a three person auction is the
#probability that two other iid bids are below mine.
profitThree = Vector{Float64}(undef,N)
profitSix = Vector{Float64}(undef,N)
optErrorThree = Vector{Float64}(undef,N)
optErrorSix = Vector{Float64}(undef,N)

for i in 1:N    
    slot = convert( Int64, round(df[i,:BidC3]*100))+1
    probWinThree = empCDFThree[slot]^2
    profitThree[i] = (df[i,:Value] - df[i,:BidC3])*probWinThree

    slot = convert( Int64, round(df[i,:BidC6]*100))+1
    probWin = empCDFSix[slot]^5
    profitSix[i] = (df[i,:Value] - df[i,:BidC6])*probWin

    posProfitsThree = maximum([(df[i,:Value] - gridPoints[bid]) *
                               empCDFThree[bid]^2 for bid in 1:l])
    posProfitsSix = maximum([(df[i,:Value] - gridPoints[bid]) *
                             empCDFSix[bid]^5 for bid in 1:l])
    optErrorThree[i] = posProfitsThree - profitThree[i]
    optErrorSix[i] = posProfitsSix - profitSix[i]
end

depth = 100

function NormalKernal( u )
    return ( 1.0 / sqrt( 2*ppi))*exp( -u*u / 2.0)
end

NormalKernal <- function( u ){
(1/sqrt( 2*pi))*exp( (-1*u^2)/2.0 )
}
755
GenerateKernalSmoothHistogram <- function( depth, frame, start, end, kernal ){
kSmooth <- numeric( (end-start)*depth )
i <- 0
h <- 1.06*sd(frame)*as.numeric(length(frame))^(-1.0/5.0)
for( i in 1:length(kSmooth) ){
kSmooth[i] <- 0
y <- (start+(i/depth))
for( j in 1:length(frame)){
kSmooth[i] <- kSmooth[i] + kernal( (y - frame[j])/h )
}
kSmooth[i] <- kSmooth[i] / (length(frame)*h)
}
kSmooth
}
