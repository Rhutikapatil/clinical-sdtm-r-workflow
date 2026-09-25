# DM: one synthetic demographics record per subject.
dm_src <- read_source("dm_source.csv")
ex_src <- read_source("ex_source.csv")
require_columns(dm_src, c("STUDYID", "USUBJID", "SUBJID", "SITEID", "AGE", "SEX", "ARM"), "dm_source")
first_dose <- aggregate(ex_src$EXSTDTC, list(USUBJID = ex_src$USUBJID), min)
last_dose <- aggregate(ex_src$EXENDTC, list(USUBJID = ex_src$USUBJID), max)
names(first_dose)[2] <- "FIRSTDOSE"
names(last_dose)[2] <- "LASTDOSE"
dm_work <- merge(merge(dm_src, first_dose, by = "USUBJID", all.x = TRUE),
                 last_dose, by = "USUBJID", all.x = TRUE)
dm_work <- dm_work[order(dm_work$USUBJID), ]
dm <- data.frame(
  STUDYID = dm_work$STUDYID, DOMAIN = "DM", USUBJID = dm_work$USUBJID,
  SUBJID = sprintf("%03d", as.integer(dm_work$SUBJID)), RFSTDTC = as.character(dm_work$FIRSTDOSE),
  RFENDTC = as.character(dm_work$LASTDOSE), RFXSTDTC = as.character(dm_work$FIRSTDOSE),
  RFXENDTC = as.character(dm_work$LASTDOSE), SITEID = sprintf("%02d", as.integer(dm_work$SITEID)),
  AGE = dm_work$AGE, AGEU = dm_work$AGEU, SEX = dm_work$SEX,
  ARMCD = ifelse(dm_work$ARM == "PLACEBO", "PBO", "TRTA"),
  ARM = dm_work$ARM,
  ACTARMCD = ifelse(dm_work$ARM == "PLACEBO", "PBO", "TRTA"),
  ACTARM = dm_work$ARM, COUNTRY = dm_work$COUNTRY,
  stringsAsFactors = FALSE
)
rownames(dm) <- NULL
write_domain(dm, "DM")
