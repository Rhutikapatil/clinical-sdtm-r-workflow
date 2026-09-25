# Generic helpers for a synthetic SDTM-style educational demonstration.
if (!requireNamespace("haven", quietly = TRUE)) {
  stop("Please install the haven package: install.packages('haven')")
}
dir.create("data/synthetic", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs", recursive = TRUE, showWarnings = FALSE)

read_source <- function(filename) {
  path <- file.path("data", "synthetic", filename)
  if (!file.exists(path)) stop("Synthetic source not found: ", path)
  read.csv(path, stringsAsFactors = FALSE, na.strings = c("", "NA"))
}

study_day <- function(event_date, reference_date) {
  d <- as.Date(event_date) - as.Date(reference_date)
  answer <- as.integer(d)
  answer[!is.na(answer) & answer >= 0L] <- answer[!is.na(answer) & answer >= 0L] + 1L
  answer
}

write_domain <- function(df, domain) {
  stopifnot(is.data.frame(df), nrow(df) > 0L, all(df$DOMAIN == domain))
  attr(df, "label") <- paste0(domain, " synthetic educational demonstration")
  haven::write_xpt(df, file.path("outputs", paste0(domain, ".xpt")), version = 5)
  saveRDS(df, file.path("outputs", paste0(domain, ".rds")))
  message(domain, " exported: ", nrow(df), " rows")
}

require_columns <- function(df, cols, name) {
  missing <- setdiff(cols, names(df))
  if (length(missing)) stop(name, " missing: ", paste(missing, collapse = ", "))
}
