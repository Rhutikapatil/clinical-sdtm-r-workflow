# Internal consistency QC for the synthetic educational recreation.
domains <- c("DM", "EX", "MH", "DS", "VS")
obj <- setNames(lapply(domains, function(d) readRDS(file.path("outputs", paste0(d, ".rds")))), domains)
src <- setNames(lapply(c("dm", "ex", "mh", "ds", "vs"),
                      function(d) read_source(paste0(d, "_source.csv"))), domains)

tests <- c(
  "DM one record per subject" = !anyDuplicated(obj$DM$USUBJID),
  "DM covers synthetic subjects" = setequal(obj$DM$USUBJID, src$DM$USUBJID),
  "DM reference dates populated" = all(!is.na(obj$DM$RFSTDTC) & !is.na(obj$DM$RFENDTC)),
  "EX source row count" = nrow(obj$EX) == nrow(src$EX),
  "MH source row count" = nrow(obj$MH) == nrow(src$MH),
  "DS source row count" = nrow(obj$DS) == nrow(src$DS),
  "VS source row count" = nrow(obj$VS) == nrow(src$VS),
  "Every domain has valid subject IDs" = all(vapply(obj, function(d) all(d$USUBJID %in% obj$DM$USUBJID), logical(1))),
  "Domain column agrees with file" = all(vapply(names(obj), function(d) all(obj[[d]]$DOMAIN == d), logical(1))),
  "EX day from DM reference start" = {
    ref <- obj$DM$RFSTDTC[match(obj$EX$USUBJID, obj$DM$USUBJID)]
    identical(as.integer(obj$EX$EXSTDY), study_day(obj$EX$EXSTDTC, ref))
  },
  "VS study day from DM reference start" = {
    ref <- obj$DM$RFSTDTC[match(obj$VS$USUBJID, obj$DM$USUBJID)]
    identical(as.integer(obj$VS$VSDY), study_day(obj$VS$VSDTC, ref))
  },
  "VS keys are unique" = !anyDuplicated(obj$VS[c("USUBJID", "VSSEQ")]),
  "DS keys are unique" = !anyDuplicated(obj$DS[c("USUBJID", "DSSEQ")]),
  "MH keys are unique" = !anyDuplicated(obj$MH[c("USUBJID", "MHSEQ")]),
  "EX keys are unique" = !anyDuplicated(obj$EX[c("USUBJID", "EXSEQ")])
)
for (domain in domains) {
  path <- file.path("outputs", paste0(domain, ".xpt"))
  read_back <- tryCatch(if (file.exists(path)) haven::read_xpt(path) else NULL,
                        error = function(e) NULL)
  tests[paste0(domain, " XPT readable")] <- !is.null(read_back)
  tests[paste0(domain, " XPT row count")] <- !is.null(read_back) && nrow(read_back) == nrow(obj[[domain]])
  tests[paste0(domain, " XPT variable order")] <- !is.null(read_back) && identical(names(read_back), names(obj[[domain]]))
}
validation <- data.frame(CHECK = names(tests), PASS = as.logical(tests), row.names = NULL)
write.csv(validation, "outputs/validation_summary.csv", row.names = FALSE)
print(validation, row.names = FALSE)
if (!all(validation$PASS)) stop("One or more synthetic demonstration QC checks failed. See outputs/validation_summary.csv")
message("All synthetic demonstration QC checks passed. Not an independent reference comparison.")
