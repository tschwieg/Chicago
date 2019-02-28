#Stargazer makes output in nice latex tables
library(stargazer)
#For quantile regression
library(quantreg)


birthData <- read.csv("data.csv")

summary(birthData)


reg <- lm( formula = birthweight~boy + married + black + age + highschool + somecollege + college + prenone + presecond + prethird + smoker + cigsdaily + weightgain + I(age^2) + I(weightgain^2), data=birthData )

stargazer(reg,style="aer",font.size="small",single.row=TRUE, intercept.top = TRUE, digits = 5)

cMat <- reg$coefficients

quantiles = c(1:9/10.0)

#A good programmer would use a list here to add all the elements of
#quantiles as seperate quantile regressions then pass that to
#stargazer, good thing I'm not a good programmer
quantReg15 <- rq( formula = birthweight~boy + married + black + age + highschool + somecollege + college + prenone + presecond + prethird + smoker + cigsdaily + weightgain + I(age^2) + I(weightgain^2), data = birthData, tau = .15 )
quantReg30 <- rq( formula = birthweight~boy + married + black + age + highschool + somecollege + college + prenone + presecond + prethird + smoker + cigsdaily + weightgain + I(age^2) + I(weightgain^2), data = birthData, tau = .3 )
quantReg45 <- rq( formula = birthweight~boy + married + black + age + highschool + somecollege + college + prenone + presecond + prethird + smoker + cigsdaily + weightgain + I(age^2) + I(weightgain^2), data = birthData, tau = .45 )
quantReg60 <- rq( formula = birthweight~boy + married + black + age + highschool + somecollege + college + prenone + presecond + prethird + smoker + cigsdaily + weightgain + I(age^2) + I(weightgain^2), data = birthData, tau = .6 )
quantReg75 <- rq( formula = birthweight~boy + married + black + age + highschool + somecollege + college + prenone + presecond + prethird + smoker + cigsdaily + weightgain + I(age^2) + I(weightgain^2), data = birthData, tau = .75 )
quantReg90 <- rq( formula = birthweight~boy + married + black + age + highschool + somecollege + college + prenone + presecond + prethird + smoker + cigsdaily + weightgain + I(age^2) + I(weightgain^2), data = birthData, tau = .9 )




stargazer( quantReg15, quantReg30, quantReg45, font.size="small", single.row=TRUE, column.sep.width = "1pt", intercept.top = TRUE, intercept.bottom = FALSE, title="Quantile Regression Coefficients",column.labels = c("$\\tau = .15$", "$\\tau = .3$", "$\\tau = .45$"),covariate.labels=c("Constant","$boy$","$married$","$black$","$age$","$highschool$","$somecollege$","$college$","$prenone$","$presecond$","$prethird$","$smoker$","$cigsdaily$","$weightgain$","$age^2$","$weightgain^2$"))#, digits = 5)

stargazer( quantReg60, quantReg75, quantReg90, font.size="small", single.row=TRUE, column.sep.width = "1pt", intercept.top = TRUE, intercept.bottom = FALSE, title="Quantile Regression Coefficients",column.labels = c("$\\tau = .6$", "$\\tau = .75$", "$\\tau = .9$"),covariate.labels=c("Constant","$boy$","$married$","$black$","$age$","$highschool$","$somecollege$","$college$","$prenone$","$presecond$","$prethird$","$smoker$","$cigsdaily$","$weightgain$","$age^2$","$weightgain^2$"))#, digits = 5)





sum( reg$residuals )
length( reg$residuals[abs(reg$residuals) < 1e-10] )


#Lets use $\tau$ = .5 as LAD is supposedly comparable to OLS
ladEstimate <- rq( formula = birthweight ~ . + I(age^2) + I(weightgain^2), data = birthData, tau = .5 )
sum( ladEstimate$residuals )
length( ladEstimate$residuals[abs(ladEstimate$residuals) < 1e-10] )

#Check if this depends on our choice of $\tau$
for( q in quantiles ){
    quantReg <- rq( formula = birthweight ~ . + I(age^2) + I(weightgain^2), data = birthData, tau = q )
    print(sum( quantReg$residuals ))
    print(length( quantReg$residuals[abs(quantReg$residuals) < 1e-10] ))
}

pdf("qNineHist.pdf")
hist(ladEstimate$dual, main="LAD Dual Variables", density=TRUE, xlab = "Dual", freq=FALSE, )
dev.off()
