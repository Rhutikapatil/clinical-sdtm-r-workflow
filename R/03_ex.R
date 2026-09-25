# EX: synthetic exposure records and relative study-day derivations.
ex_src <- read_source("ex_source.csv")
dm <- readRDS("outputs/DM.rds")
refdate <- dm$RFSTDTC[match(ex_src$USUBJID, dm$USUBJID)]
ord <- order(ex_src$USUBJID, ex_src$EXSEQ)
ex_src <- ex_src[ord, ]
refdate <- refdate[ord]
ex <- data.frame(
  STUDYID = ex_src$STUDYID, DOMAIN = "EX", USUBJID = ex_src$USUBJID,
  EXSEQ = ex_src$EXSEQ, EXTRT = ex_src$EXTRT, EXDOSE = ex_src$EXDOSE,
  EXDOSU = ex_src$EXDOSU, EXSTDTC = ex_src$EXSTDTC, EXENDTC = ex_src$EXENDTC,
  EXSTDY = study_day(ex_src$EXSTDTC, refdate),
  EXENDY = study_day(ex_src$EXENDTC, refdate),
  stringsAsFactors = FALSE
)
rownames(ex) <- NULL
write_domain(ex, "EX")
