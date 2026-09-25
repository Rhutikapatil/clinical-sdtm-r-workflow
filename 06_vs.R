# VS: synthetic vital-sign values by subject, visit, and test.
vs_src <- read_source("vs_source.csv")
dm <- readRDS("outputs/DM.rds")
ord <- order(vs_src$USUBJID, vs_src$VISITNUM, vs_src$VSTESTCD)
vs_src <- vs_src[ord, ]
refdate <- dm$RFSTDTC[match(vs_src$USUBJID, dm$USUBJID)]
vs <- data.frame(
  STUDYID = vs_src$STUDYID, DOMAIN = "VS", USUBJID = vs_src$USUBJID,
  VSSEQ = ave(seq_len(nrow(vs_src)), vs_src$USUBJID, FUN = seq_along),
  VSTESTCD = vs_src$VSTESTCD, VSTEST = vs_src$VSTEST,
  VSORRES = vs_src$VSORRES, VSORRESU = vs_src$VSORRESU,
  VSSTRESC = vs_src$VSORRES, VSSTRESN = as.numeric(vs_src$VSORRES),
  VSSTRESU = vs_src$VSORRESU,
  VISITNUM = vs_src$VISITNUM, VISIT = vs_src$VISIT,
  VSDTC = vs_src$VSDTC, VSDY = study_day(vs_src$VSDTC, refdate),
  stringsAsFactors = FALSE
)
rownames(vs) <- NULL
write_domain(vs, "VS")
