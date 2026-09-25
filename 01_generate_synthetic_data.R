# Fully synthetic source data. No data or derivation logic from a confidential trial.
set.seed(2026)
n <- 16L
ids <- sprintf("SYN-%03d", seq_len(n))
start <- as.Date("2026-01-10") + sample(0:12, n, replace = TRUE)
end <- start + sample(54:70, n, replace = TRUE)
arm <- rep(c("DEMO TREATMENT", "PLACEBO"), length.out = n)

dm_source <- data.frame(
  STUDYID = "SYNTHETIC", USUBJID = ids,
  SUBJID = sprintf("%03d", seq_len(n)), SITEID = sprintf("%02d", sample(1:3, n, replace = TRUE)),
  AGE = sample(35:75, n, replace = TRUE), AGEU = "YEARS",
  SEX = sample(c("F", "M"), n, replace = TRUE), COUNTRY = "USA",
  ARM = arm, stringsAsFactors = FALSE
)

ex_source <- do.call(rbind, lapply(seq_len(n), function(i) {
  # Two illustrative treatment intervals per subject.
  data.frame(
    STUDYID = "SYNTHETIC", USUBJID = ids[i], EXSEQ = 1:2,
    EXTRT = arm[i], EXDOSE = if (arm[i] == "PLACEBO") 0 else 100,
    EXDOSU = "mg", EXSTDTC = as.character(c(start[i], start[i] + 28)),
    EXENDTC = as.character(c(start[i] + 27, end[i])),
    stringsAsFactors = FALSE
  )
}))

mh_source <- do.call(rbind, lapply(seq_len(n), function(i) {
  k <- sample(1:2, 1)
  data.frame(
    STUDYID = "SYNTHETIC", USUBJID = ids[i], MHSEQ = seq_len(k),
    MHTERM = sample(c("Seasonal allergy", "Prior surgery", "Migraine", "Hypertension"), k),
    MHSTDTC = as.character(start[i] - sample(100:900, k)),
    stringsAsFactors = FALSE
  )
}))

ds_source <- do.call(rbind, lapply(seq_len(n), function(i) {
  completed <- i %% 4L != 0L
  data.frame(
    STUDYID = "SYNTHETIC", USUBJID = ids[i], DSSEQ = 1:2,
    DSTERM = c("RANDOMIZED", if (completed) "COMPLETED" else "EARLY DISCONTINUATION"),
    DSDECOD = c("RANDOMIZED", if (completed) "COMPLETED" else "ADVERSE EVENT"),
    DSCAT = c("PROTOCOL MILESTONE", "DISPOSITION EVENT"),
    DSSTDTC = as.character(c(start[i], end[i])),
    stringsAsFactors = FALSE
  )
}))

visit_days <- c(-7L, 28L, 56L)
vs_source <- do.call(rbind, lapply(seq_len(n), function(i) {
  do.call(rbind, lapply(seq_along(visit_days), function(j) {
    vals <- c(sample(105:145, 1), sample(65:95, 1), round(runif(1, 55, 98), 1))
    data.frame(
      STUDYID = "SYNTHETIC", USUBJID = ids[i],
      VISITNUM = c(1, 4, 8)[j], VISIT = c("SCREENING", "WEEK 4", "WEEK 8")[j],
      VSDTC = as.character(start[i] + visit_days[j]),
      VSTESTCD = c("SYSBP", "DIABP", "WEIGHT"),
      VSTEST = c("Systolic Blood Pressure", "Diastolic Blood Pressure", "Weight"),
      VSORRES = as.character(vals), VSORRESU = c("mmHg", "mmHg", "kg"),
      stringsAsFactors = FALSE
    )
  }))
}))

write.csv(dm_source, "data/synthetic/dm_source.csv", row.names = FALSE)
write.csv(ex_source, "data/synthetic/ex_source.csv", row.names = FALSE)
write.csv(mh_source, "data/synthetic/mh_source.csv", row.names = FALSE)
write.csv(ds_source, "data/synthetic/ds_source.csv", row.names = FALSE)
write.csv(vs_source, "data/synthetic/vs_source.csv", row.names = FALSE)
message("Synthetic data generated for ", n, " subjects")
