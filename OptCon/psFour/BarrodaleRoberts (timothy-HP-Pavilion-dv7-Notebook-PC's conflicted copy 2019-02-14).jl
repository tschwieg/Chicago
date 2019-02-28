#Lets ensure that the dimensions are correct

# A is N x 2p + 2N
# A = [ X -X I -I ]


p = 3
M = 20

N = 2*p+2*M


c = zeros(N)
c[(2*p+1):end] = .5

X = rand(Uniform(), M, p)

Y = X[:,1] + 2*X[:,2] - X[:,3] + rand(Uniform(-.1,.1),M)

x = zeros(N)
x[(2*p+1):(2*p+M)] = (Y .> 0).*Y
x[(2*p+M+1):end] = (Y .<= 0).*Y*-1


A = hcat( X,-X, I, -I)


k = Vector{Int64}()
for i in 1:(N)
    if( x[i] != 0.0 )
        k = vcat(k,i)
    end
end

BInv = inv( A[:,k])
b = Y


function Barrodale( A::Matrix{Float64}, x::Vector{Float64},
                    k::Vector{Float64}, b::Vector{Float64},
                    c::Vector{Float64}, BInv::Matrix{Float64},
                    p::Int64, M::Int64, N::Int64)

    
    cBar = Vector{Float64}(2*p)

    for i in 1:p
        j = -1
        min = 1e10
        #Which β should enter the distribution?
        for z in 1:2*p
            cBar[z] = c[z] - dot( c[k], BInv*A[:,z])
            if cBar[z] < min
                j = z
                min = cBar[z]
            end
        end
        #j is now the smallest element of cBar

        ℓ = ChangeSignPivots( c, BInv, A, x, k, b, p, M, j)

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

    cBar = Vector{Float64}(2*M)
    min = 1e10
    j = -1
    for i in (2*p+1):N
        cBar[i-2*p] = c[i] - dot( c[k], BInv*A[:,i])
        if cBar[i-2*p] < min
            j = i
            min = cBar[i-2*p]
        end
    end

    # We stop once all reduced costs are positive.
    while( min < 0.0)
    
        ℓ = ChangeSignPivots( c, BInv, A, x, k, b, p, M, j)
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

        #Compute the new x value
        x .= 0.0
        x[k] = BInv*b

        #Recalculate all of the reduced costs for u,v
        min = 1e10
        j = -1
        for i in (2*p+1):N
            cBar[i-2*p] = c[i] - dot( c[k], BInv*A[:,i])
            if cBar[i-2*p] < min
                j = i
                min = cBar[i-2*p]
            end
        end
    end
    
end





function ChangeSignPivots( c::Vector{Float64}, BInv::Matrix{Float64},
                           A::Matrix{Float64}, x::Vector{Float64},
                           k::Vector{Int64}, b::Vector{Float64},
                           p::Int64, M::Int64, j::Int64)

    
    while( c[j] - dot( c[k], BInv*A[:,j]) < 1e-8)
        u = BInv*A[:,j]

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
        

        #Now we know we want k[ℓ] to exit, we need to find its
        #negative (poisitve) counter-part
        exiting = k[ℓ]
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

    return  ℓ
end
