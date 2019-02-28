data <- read.csv( "ps4.csv" )


k <- ncol(data)
N <- nrow(data)


## Since we are not calling lm, we want to do matrix algebra, we need
## R to not store this stuff as a data frame. What a terrible language.

Y <-  as.matrix(data$y)
X <- as.matrix(cbind( rep(1,N), data[,2:3] ))

## Remember that matrix multiplication uses the %*%
mat <-  t(X)%*%X

## Rather than using inverses, let's be numerically stable and use the
## Cholesky decomp and forward/back substitution for legitimate answers
F <- chol(mat)

## We now have $ X' X \beta = X' Y$
## This is equivalent to $F' F \beta = X' Y$
## Thus $\beta = \inv{F} \inv{F'}  X' Y$

## Note that F' is lower triangular so we use forward substitution.
beta <-  backsolve( F, forwardsolve( t(F), t(X)%*%Y ) )

## Now lets build our variance estimates.

outerproduct <- function( row ){
    row%*%t(row)
}

## We are interested in estimating $\inv{\left (\frac{1}{n} \sum_{i=1}^n X_i X_i' \right )}$


## The inner apply() forms the outer product matrices, the outer
## averages over them The matrix() reforms them as a matrix since
## apply flattens them.  This is equivalent to just doing
## $\frac{1}{n} X' X$, I just wanted some R practice.
outerProductGradient <- matrix( apply( apply( X, 1, outerproduct ), 1,
                                      mean ), nrow = k, ncol = k )

## Mama told me to never invert a matrix on a computer
varF <- chol( outerProductGradient )
informationEstimate <- backsolve( varF, forwardsolve( t(varF), diag(k) ) )

## Now lets get the heteroskedasticity-robust version of this bad boy.
## We multiply the matrix of $X_i X_i'$ by $\hat{u_i}^2$ component wise, hence no % 
monstronsity <- matrix( apply(
    matrix( rep( (Y - X%*%beta)^2, k*k ), nrow=k*k, ncol = N, byrow = TRUE )
     * apply( X, 1, outerproduct ), 1, mean ), nrow = k, ncol = k )

## This is what are interested in: $\Vari{\est{\beta} \vert X }$
condVarHetero <- informationEstimate%*%monstronsity%*%informationEstimate


## Note that it's  possible to just use matrix operations to get there
## I just chose this way for practice and to have it look like the notes.
## One could always do $\inv{ ( X' X ) } X' \est{\Sigma} X \inv{ ( X' X )}$


## Now we face multiple linear restrictions in the form of $R \beta = r$

## We don't really know anything about the nature of $R \Vari{ \est{ \beta } }$
## So we can't rely on any decompositions, and we'll let solve() work here
multipleLinearTest <- function( R, r, N, beta, Var ){
    N*t(R%*%beta - r )%*%solve(R%*%Var%*%t(R))%*%(R%*%beta -r  )
}


R <-  matrix( c( 0, 0, 1, 0 ,0,1 ), nrow = 2, ncol = 3 )
r <- c(  1, 1 )

## This is free to be changed.
alpha <- .05

## This c is the critical value used in a hypothesis test
c <- qchisq( alpha, df = 2, lower.tail = FALSE )


testStat <- multipleLinearTest( R, r, N, beta, condVarHetero )
pValue <-  pchisq( testStat, df = 2, lower.tail = FALSE )


## Testing: $f( \beta ) = (\beta_1 - \beta_2 )^2 = 0$
## However we need the rows of the total derivative to be linearly independent.
## $\nabla f( \beta ) = ( 0, 2( \beta_1 - \beta_2 ), -2 ( \beta_1 - \beta_2 ) )'$
## The rows are not linearly independent - The standard nonlinear test will not work.

## Worse yet, if we attempt to simply take the square root of both
## sides we lose the reliability as this is a Wald-Test. Wald Tests
## are not invariant to non-linear Transforms. This means we want to
## use a likelihood-ratio test, which is. However if we do not want to
## assume normality of Y and then the GLM framework to get a
## likelihood-ratio test, we can just stand for the errors in the Wald Test.

## Our test is simply testing if $\beta_1 - \beta_2 = 0$

R <- matrix( c( 0, 1, -1 ), nrow = 1, ncol = 3 )
r <- c(0)

## I just copy and pasted the previous code
c <- qchisq( alpha, df = 1, lower.tail = FALSE )
testStat <- fischerFTest( R, r, N, beta, condVarHetero )
pValue <-  pchisq( testStat, df = 1, lower.tail = FALSE )
