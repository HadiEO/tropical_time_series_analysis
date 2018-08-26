# The input X is model.matrix with columns: (Intercept) trend (and seasonal components if specified in formula)
# (Intercept) is just 1s, trend is linear time trend running from 1 to number of observations
# The input y is response (measured) as matrix (N x 1) 

# The modification: when an "oldFlag" obs has the response value replaced with NA,
# the MOSUM doesn't evaluate to NA. The MOSUM window stays the same as before the NA
# assignment. The sigmahat also stays the same (from environment of the mefp object, set in monitor_mod())

computeEmpProc_mod <- function (X, y) 
{
  e <- as.vector(y - X %*% histcoef)
  process <- rep(0, nrow(X) - K + 1)
  for (i in 0:(nrow(X) - K)) {
    process[i + 1] <- sum(e[(i + 1):(i + K)], na.rm = TRUE)   # Here na.rm set to TRUE
  }
  process/(sigmahat * sqrt(histsize))
}


# Testing the function   (to comment out!)
# x_backup <- x
# y_backup <- y
# 
# X <- x
# y[51] <- NA
# environment(computeEmpProc_mod) <- environment(obj$computeEmpProc)
# process_mod <- computeEmpProc_mod(x, y)
# process_ori <- obj$computeEmpProc(x_backup, y_backup)
# plot(1:length(process_ori), process_ori)
# points(1:length(process_mod), process_mod, col = "red", cex = 1.5)



