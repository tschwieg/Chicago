using LinearAlgebra
using Random
using Distributions
using JuMP
using Gurobi

#B is the active basis
#x is the feasible basic solution
#A,c,b are the parameters of the linear program
#k is the index of the basis in A
function SimplexIteration( B::Matrix{Float64}, x::Vector{Float64},
                           A::Matrix{Float64}, c::Vector{Float64},
                           b::Vector{Float64}, k::Vector{Int64},
                           M::Int64, N::Int64)

    BInv = inv(B)

    j = -1
    #Numerical Precision problems when working with the inverse
    for i in 1:M
        if( c[i] - dot( c[k], BInv*A[:,i]) < -1e-8)
            j = i
            break
        end
    end
   
    #Check if we are at an optimal solution
    if( j == -1 )
        return 1
    end
    
    u = BInv*A[:,j]
    #Check if the problem is unbounded below
    if( sum(u[i] > 0 for i in 1:M ) == 0)
        return -1
    end
    

    #This is an implementation of Bland's Rule
    min = 1.0e10
    ℓ = -1
    for i in 1:M
        if( u[i] > 0.0 )
            thetaTemp = (x[k[i]] / u[i])
            #The strict inequality means that the first i wins the
            #tie.
            if( thetaTemp < min )
                min = thetaTemp
                ℓ = i
            end
        end
    end
    #Now the basis has k instead of ℓ
    k[ℓ] = j
    
    B[:,ℓ] = A[:,j]

    x .= 0.0
    x[k] = BInv*b
    
    #Continue iterating:
    return 0
end


function RevissedSimplexIteration( BInv::Matrix{Float64}, x::Vector{Float64},
                           A::Matrix{Float64}, c::Vector{Float64},
                           b::Vector{Float64}, k::Vector{Int64},
                           M::Int64, N::Int64)


    #First let us compute some costs, we stop computing costs as soon
    #as we have a negative cost
    j = -1
    #Numerical Precision problems when working with the inverse
    for i in 1:M
        if( c[i] - dot( c[k], BInv*A[:,i]) < -1e-8)
            j = i
            break
        end
    end
   
    #Check if we are at an optimal solution
    if( j == -1 )
        return 1
    end
    
    u = BInv*A[:,j]
    #Check if the problem is unbounded below
    if( sum(u[i] > 0 for i in 1:M ) == 0)
        return -1
    end
    

    #This is an implementation of Bland's Rule
    min = 1.0e10
    ℓ = -1
    for i in 1:M
        if( u[i] > 0.0 )
            thetaTemp = (x[k[i]] / u[i])
            #The strict inequality means that the first i wins the
            #tie.
            if( thetaTemp < min )
                min = thetaTemp
                ℓ = i
            end
        end
    end
    #Now the basis has k instead of ℓ
    k[ℓ] = j

    #Are elementary matrix operations faster than this?
    for i in 1:M
        if i != ℓ
            @inbounds BInv[i,:] -= (u[i] / u[ℓ])*BInv[ℓ,:]
        end
        # @inbounds val = (u[i] / u[ℓ])
        # @simd for j in 1:M
        #     @inbounds BInv[i,j] -= val*BInv[ℓ,j]
        # end
    end
    val = u[ℓ]
    for j in 1:M
        @inbounds BInv[ℓ,j] =  BInv[ℓ,j] / u[ℓ]
    end
    #BInv[ℓ,:] ./= u[ℓ]
    

    # @simd for j in 1:N
    #     @inbounds x[j] = 0.0
    # end
    x .= 0
    x[k] = BInv*b
    
    #Continue iterating:
    return 0
end

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
    for i in 1:M#Note that the second half of the residuals uses -I 
        cBar[M+i] = c[M+i+2*p] - dot( c[k], -BInv[:,i])
        if cBar[i] < min
            j = i+2*p+M
            min = cBar[M+i]
        end
    end

    println("Starting the loop")
    # We stop once all reduced costs are positive.
    while( min < 0.0)
        #Since we know we are using A[:,j] where j is a standard
        #ordered basis, we just need to make sure we get the element
        #correct. Lots of silly modular shit to do that
        sob = zeros(M)
        sob[((j-2*p-1)%M)+1] = 1.0-2.0(j-2*p > 2*p+M)
        ℓ,u = ChangeSignPivots( c, BInv, sob, x, k, b, p, M, j)
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

function GurobiQuantReg( X::Matrix{Float64},
                         Y::Vector{Float64},
                         τ::Float64,
                         p::Int64, M::Int64, N::Int64)

    
    m = Model(solver = GurobiSolver())
    @variable( m, β⁺[1:p] >= 0)
    @variable( m, β⁻[1:p] >= 0)
    @variable( m, u[1:M] >= 0)
    @variable( m, v[1:M] >= 0)
    @constraint( m, fit[i=1:M],
                 sum( X[i,j]*β⁺[j] for j in 1:p )
                 - sum( X[i,j]*β⁻[j] for j in 1:p)
                 + u[i] - v[i] == Y[i] )
    @objective( m, Min, τ*sum( u[i] for i in 1:M )
                + (1-τ)*sum(v[i] for i in 1:M) )
    status = solve(m)
    println(getvalue(β⁺))
    println(getvalue(β⁻))
    return [getvalue(β⁺), getvalue(β⁻), getvalue(u), getvalue(v)]
end



    

function SimplexRunSlow( M::Int64)
    p = 5
    Random.seed!( 235711 )

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
    for i in 1:N
        if( x[i] != 0.0 )
            k = vcat(k,i)
        end
    end


    #BInv = inv( A[:,k])
    B = A[:,k]
    b = Y


    #exitCode = RevissedSimplexIteration( BInv, x, A, c,b,k,M,N)
    exitCode = SimplexIteration( B, x, A, c,b,k,M,N)
    while( exitCode == 0 )
        #println("iteration")
        #exitCode = RevissedSimplexIteration( BInv, x, A, c,b,k,M,N)
        exitCode = SimplexIteration( B, x, A, c,b,k,M,N)
        x .= 0
        x[k] = B \ b
    end
    println( "estimated β: ", x[1:p] + -1 .* x[(p+1):2*p])
    println( "actual β:", β)
    #return x

end



function SimplexRunFast( M::Int64)
    p = 5

    Random.seed!( 235711 )
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
    for i in 1:N
        if( x[i] != 0.0 )
            k = vcat(k,i)
        end
    end


    BInv = inv( A[:,k])
    b = Y


    exitCode = RevissedSimplexIteration( BInv, x, A, c,b,k,M,N)
    while( exitCode == 0 )
        #println("iteration")
        exitCode = RevissedSimplexIteration( BInv, x, A, c,b,k,M,N)
        x .= 0
        x[k] = BInv*b
    end
    println( exitCode )
    println( "estimated β: ", x[1:p] + -1 .* x[(p+1):2*p])
    println( "actual β:", β)
    #return x

end

function SimplexRunBarrodale( M::Int64)
    p = 5

    Random.seed!( 235711 )
    β = rand(Uniform(-10,10), p)

    N = 2*p+2*M


    c = zeros(N)
    c[(2*p+1):end] .= .5

    X = rand(Uniform(), M, p)

    Y = X*β + rand(Uniform(-.1,.1),M)

    x = zeros(N)
    x[(2*p+1):(2*p+M)] = (Y .> 0).*Y
    x[(2*p+M+1):end] = (Y .<= 0).*Y*-1


    #A = hcat( X,-X, I, -I)
    BInv = zeros(M,M)

    k = Vector{Int64}(undef,0)
    for i in 1:N
        if( x[i] != 0.0 )
            k = vcat(k,i)
        end
    end
    for i in 1:M
        neg = (k[i]-2*p) > M
        j = (k[i] - 2*p-1)%M+1
        BInv[j,i] = 1.0-(2*neg)
    end
    BInv = inv(BInv)


    #BInv = inv( A[:,k])
    b = Y


    x = Barrodale( X, x, k, b, c, BInv, p, M, N)
    
    println( "estimated β: ", x[1:p] + -1 .* x[(p+1):2*p])
    println( "actual β:", β)
    #return x

end

function SimplexRunGurobi( M::Int64)
    p = 5
    #Random.seed!( 235711 )
    srand(235711)

    β = rand(Uniform(-10,10), p)

    N = 2*p+2*M

    X = rand(Uniform(), M, p)

    Y = X*β + rand(Uniform(-.1,.1),M)

    x = GurobiQuantReg( X, Y, .5, p, M, N)
end



#M = 250
# Fast: 0.300426
# Slow: 0.750987667
# BR: 0.292047333

#M = 500
# Fast: 5.438479
# Slow: 10.307776333
# BR: 0.473022

#M = 750
# Fast: 25.473887
# Slow: 39.933402333
# BR: 2.173836

#M = 1000
# Fast: 21.178596667
# Slow: 28.797609333
# BR: 2.868348

# M = 1250
# Fast: 75.5935325
# Slow: 102.380060
# BR: 19.424499667
