library(parallel)
library(randomForest)
data(LetterRecognition, package = "mlbench")
set.seed(seed = 7654321, "L'Ecuyer-CMRG")

n = nrow(LetterRecognition)
n_test = floor(0.2 * n)
i_test = sample.int(n, n_test)
train = LetterRecognition[-i_test, ]
test = LetterRecognition[i_test, ]

nc = 2
ntree = lapply(splitIndices(500, nc), length)
rf = function(x) randomForest(lettr ~ ., train, ntree=x, importance=TRUE)
rf.out = mclapply(ntree, rf, mc.cores = nc)
rf.all = do.call(combine, rf.out)

crows = splitIndices(nrow(test), nc) 
rfp = function(x) as.vector(predict(rf.all, test[x, ])) 
cpred = mclapply(crows, rfp, mc.cores = nc) 
pred = do.call(c, cpred) 

correct <- sum(pred == test$lettr)
cat("Proportion Correct:", correct/(n_test), "\n")
