#Lets ensure that the dimensions are correct

# A is N x 2p + 2N
# A = [ X -X I -I ]


p = 5
M = 1000

β = rand(Uniform(-10,10), p)

N = 2*p+2*M


c = zeros(N)
c[(2*p+1):end] .= .5

X = rand(Uniform(), M, p)

Y = X*β + rand(Uniform(-.1,.1),M)

x = zeros(N)
x[(2*p+1):(2*p+M)] = (Y .> 0).*Y
x[(2*p+M+1):end] = (Y .<= 0).*Y*-1


A = hcat( X,-X, I, -I)

k = Vector{Int64}(undef,0)
for i in 1:(N)
    global k
    if( x[i] != 0.0 )
        k = vcat(k,i)
    end
end


BInv = inv( A[:,k])
b = Y


function Barrodale( X::Matrix{Float64}, x::Vector{Float64},
                    k::Vector{Int64}, b::Vector{Float64},
                    c::Vector{Float64}, BInv::Matrix{Float64},
                    p::Int64, M::Int64, N::Int64)

    cBar = Vector{Float64}(undef,2*p)

    ℓ = 0
    u = Vector{Float64}(undef,0)

    for i in 1:p
        j = -1
        min = 1e10
        #Which β should enter the distribution?
        for z in 1:p
            cBar[z] = c[z] - dot( c[k], BInv*X[:,z])
            if cBar[z] < min
                j = z
                min = cBar[z]
            end
        end
        for z in (p+1):2*p
            cBar[z] = c[z] - dot( c[k], -BInv*X[:,z-p])
            if cBar[z] < min
                j = z
                min = cBar[z]
            end
        end
        #j is now the smallest element of cBar

        if j <= p 
            ℓ,u = ChangeSignPivots( c, BInv, X[:,j], x, k, b, p, M, j)
        else
            ℓ,u = ChangeSignPivots( c, BInv, -X[:,j-p], x, k, b, p, M, j)
        end
        

        if ℓ == -1
            println(cBar)
        end
        

        # Now we do a normal pivot bringing in β[j]
        k[ℓ] = j

        #Are elementary matrix operations faster than this?
        for z in 1:M
            if( z == ℓ)
                continue
            end
            BInv[z,:] -= (u[z] / u[ℓ])*BInv[ℓ,:]
        end
        BInv[ℓ,:] ./=  u[ℓ]

        #Compute the new x value
        x .= 0.0
        x[k] = BInv*b
    end
    #Phase 1 complete.

    println("Phase 1 complete")
    println( x[1:2*p])

    cBar = Vector{Float64}(undef,2*M)
    min = 1e10
    j = -1
    for i in 1:M#(2*p+1):(2*p+M)
        cBar[i] = c[i+2*p] - dot( c[k], BInv[:,i])
        if cBar[i] < min
            j = i+2*p
            min = cBar[i]
        end
    end
    for i in 1:M#(2*p+1):(2*p+M)
        cBar[M+i] = c[M+i+2*p] - dot( c[k], -BInv[:,i])
        if cBar[i] < min
            j = i+2*p+M
            min = cBar[M+i]
        end
    end

    println("Starting the loop")
    # We stop once all reduced costs are positive.
    while( min < 0.0)
        sob = zeros(M)
        #println(j - 2*p)
        #println(((j-2*p-1)%M)+1)
        sob[((j-2*p-1)%M)+1] = 1.0-2.0(j-2*p > 2*p+M)
        #println( "fucked with sob")
        ℓ,u = ChangeSignPivots( c, BInv, sob, x, k, b, p, M, j)
        #println("Changed signs")
        # Now we do a normal pivot bringing in β[j]
        k[ℓ] = j

        #Are elementary matrix operations faster than this?
        for z in 1:M
            if( z == ℓ)
                continue
            end
            BInv[z,:] -= (u[z] / u[ℓ])*BInv[ℓ,:]
        end
        BInv[ℓ,:] ./=  u[ℓ]
        #BInv = inv( A[:,k])

        

        #Recalculate all of the reduced costs for u,v
        min = 1e10
        j = -1
        for i in 1:M#(2*p+1):(2*p+M)
            cBar[i] = c[i+2*p] - dot( c[k], BInv[:,i])
            if cBar[i] < min
                j = i+2*p
                min = cBar[i]
            end
        end
        for i in 1:M#(2*p+1):(2*p+M)
            cBar[M+i] = c[M+i+2*p] - dot( c[k], -BInv[:,i])
            if cBar[i] < min
                j = i+2*p+M
                min = cBar[M+i]
            end
        end
    end

    #Compute the new x value
    x .= 0.0
    x[k] = BInv*b
    return x
    
end





function ChangeSignPivots( c::Vector{Float64}, BInv::Matrix{Float64},
                           Aj::Vector{Float64}, x::Vector{Float64},
                           k::Vector{Int64}, b::Vector{Float64},
                           p::Int64, M::Int64, j::Int64)

    exiting = 0
    ℓ = -1

    u = Vector{Float64}
   

    #println(ℓ)
    while( c[j] - dot( c[k], BInv*Aj) < 1e-8)
        u = BInv*Aj

        #println(u)
        min = 1.0e10
        ℓ = -1
        for z in 1:M
            if( u[z] > 0.0 )
                thetaTemp = (x[k[z]] / u[z])
                #The strict inequality means that the first i wins the
                #tie.
                if( thetaTemp < min )
                    min = thetaTemp
                    ℓ = z
                end
            end
        end

        if ℓ == -1
            println("ℓ issue")
            return -1, u
        end
        

        #Now we know we want k[ℓ] to exit, we need to find its
        #negative (positve) counter-part
        exiting = k[ℓ]
        # If we need to do a beta change of sign
        if exiting <= 2*p
            # Note that Julia is 1-indexed so for modular
            # arthimetic we need to minus one, mod, then add one
            entering = (exiting + p-1) % (2*p)+1
        else
            entering = ((exiting-2*p)+M-1)%(2*M) + 2*p+1
        end
     
        k[ℓ] = entering
        BInv[ℓ,:] *= -1
        x .= 0.0
        x[k] = BInv*b

    end
    #If we had a negative Reduced cost before, we should undo the
    #last change, and do a regular pivot. These pivots are cheap,
    #so doing 2 more pivots than we need isn't a big deal
    k[ℓ] = exiting
    BInv[ℓ,:] *= -1

    return  ℓ,u
end
