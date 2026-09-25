# DS: synthetic randomization milestone and disposition events.
ds_src <- read_source("ds_source.csv")
dm <- readRDS("outputs/DM.rds")
ord <- order(ds_src$USUBJID, ds_src$DSSEQ)
ds_src <- ds_src[ord, ]
refdate <- dm$RFSTDTC[match(ds_src$USUBJID, dm$USUBJID)]
ds <- data.frame(
  STUDYID = ds_src$STUDYID, DOMAIN = "DS", USUBJID = ds_src$USUBJID,
  DSSEQ = ds_src$DSSEQ, DSTERM = ds_src$DSTERM, DSDECOD = ds_src$DSDECOD,
  DSCAT = ds_src$DSCAT, DSSTDTC = ds_src$DSSTDTC,
  DSSTDY = study_day(ds_src$DSSTDTC, refdate),
  stringsAsFactors = FALSE
)
rownames(ds) <- NULL
write_domain(ds, "DS")
