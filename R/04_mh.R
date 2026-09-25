# MH: synthetic medical-history records; demonstration of timing fields.
mh_src <- read_source("mh_source.csv")
dm <- readRDS("outputs/DM.rds")
ord <- order(mh_src$USUBJID, mh_src$MHSEQ)
mh_src <- mh_src[ord, ]
refdate <- dm$RFSTDTC[match(mh_src$USUBJID, dm$USUBJID)]
mh <- data.frame(
  STUDYID = mh_src$STUDYID, DOMAIN = "MH", USUBJID = mh_src$USUBJID,
  MHSEQ = mh_src$MHSEQ, MHTERM = mh_src$MHTERM,
  MHSTDTC = mh_src$MHSTDTC, MHSTDY = study_day(mh_src$MHSTDTC, refdate),
  stringsAsFactors = FALSE
)
rownames(mh) <- NULL
write_domain(mh, "MH")
