param T = 10000;
param entryOne{i in 1..T};
param entryTwo{i in 1..T};
param x{i in 1..T};

read {i in 1..T}entryOne[i] < entryOne.txt;
read {i in 1..T}entryTwo[i] < entryTwo.txt;
read {i in 1..T}x[i] < x.txt;
                                            
                                            

var pOne{i in 1..T};
var pTwo{i in 1..T};
var alpha;
var delta;

var xiOne{ i in 1..T} = exp( x[i]*alpha - delta*pTwo[i] );
var xiTwo{ i in 1..T} = exp( x[i]*alpha - delta*pOne[i] );


maximize LogLikelihood: sum{i in 1..T} entryOne[i]*log(pOne[i]) +
         (1-entryOne[i])*log(1 - pOne[i]) + entryTwo[i]*log(pTwo[i]) +
         (1-entryTwo[i])*log(1-entryTwo[i]);
subject to EquilibriumOne:
pOne[i] == xiOne / ( 1 + xiOne);
subject to EquilibriumTwo:
pTwo[i] == xiTwo / ( 1 + xiTwo);
