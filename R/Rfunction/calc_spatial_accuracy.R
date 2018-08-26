# Currently this works for 2 class i.e. 1 (disturbed) or 0 (undisturbed)

# All inputs are vectors of same length i.e. n samples
# ref                   vector of reference label (0 or 1)
# pred                  vector of predicted label (0 or 1)
# predNotBeforeRef      vector of logical (TRUE or FALSE)

calc_spatial_accuracy <- function(ref, pred, predNotBeforeRef = NULL) {
  
  # Convert to matrix
  if(!is.matrix(ref)) ref <- matrix(ref, ncol = 1)
  if(!is.matrix(pred)) pred <- matrix(pred, ncol = 1)
  
  # Confusion matrix
  cm <- table(pred, ref)
  #         ref
  # pred   0   1
  # 0    187   3
  # 1     21 224
  
  # Calculate producer's (precision, exactness) and user's accuracy (recall, completeness)
  # UA <- round((diag(cm) / rowSums(cm)) * 100, 1)
  # PA <- round((diag(cm) / colSums(cm)) * 100, 1)
  
  # Calculate overall accuracy
  # sums <- vector()
  # for(i in 1:dim(cm)[1]){
  #   sums[i] <- cm[i,i]
  # }
  # OA <- round((sum(sums)/sum(cm))*100, 1)
  
  # Need to calculate this way cause need to assign FP for change detected earlier than reference date
  TP <- NROW(which(ref == 1 & pred == 1))
  TN <- NROW(which(ref == 0 & pred == 0))
  FP <- NROW(which(ref == 0 & pred == 1))
  FN <- NROW(which(ref == 1 & pred == 0))
  
  
  if(!is.null(predNotBeforeRef)) {
    TP.old <- TP
    # Disturbance event also only if detection date is not before reference date
    TP <- NROW(which((ref == 1 & pred == 1) & predNotBeforeRef))
    # The falsified TP adds the FP samples
    FP <- FP + (TP.old - TP)
    # Update the confusion matrix
    cm[2,2] <- TP
    cm[2,1] <- FP
  }
  
  # Calculate UA and PA of both "0" and "1" classes
  PA <- list("0" = round(100 * (TN / (TN + FP)), 1),
             "1" = round(100 * (TP / (TP + FN)), 1))
  
  UA <- list("0" = round(100 * (TN / (TN + FN)), 1),
             "1" = round(100 * (TP / (TP + FP)), 1))
  
  # Calculate OA
  OA <- round(100 * (TP + TN) / (TP + TN + FP + FN), 1)
  
  out <- list(cm = cm, 
              UA = UA,
              PA = PA,
              OA = OA)
  
  return(out)
}


