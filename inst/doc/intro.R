## ----checkDeps, echo = FALSE, results = "hide"--------------------------------
if (identical(suppressWarnings(packageDescription("nycflights13")), NA)) {
    knitr::opts_chunk$set(eval = FALSE)
    message("Package nycflights13 not installed: not evaluating code chunks.")
}

## ----loadData-----------------------------------------------------------------
library(nycflights13)
dim(flights)
head(flights)

## ----startSolr----------------------------------------------------------------
library(rsolr)
schema <- deriveSolrSchema(flights)
solr <- TestSolr(schema)

## ----SolrFrame----------------------------------------------------------------
sr <- SolrFrame(solr$uri)

## ----uploadData---------------------------------------------------------------
sr[] <- flights

## ----previewSolrFrame---------------------------------------------------------
dim(sr)
head(sr)

## ----subset-------------------------------------------------------------------
subset(sr, month == 1 & day == 1)

## ----window-------------------------------------------------------------------
window(sr, start=1L, end=10L)

## ----head---------------------------------------------------------------------
head(sr, 10L)

## ----sequence-----------------------------------------------------------------
sr[1:10,]

## ----sort---------------------------------------------------------------------
sort(sr, by = ~ year + month + day)

## ----sortDecreasing-----------------------------------------------------------
sort(sr, by = ~ arr_delay, decreasing=TRUE)

## ----select-------------------------------------------------------------------
subset(sr, select=c(year, month, day))

## ----bracket------------------------------------------------------------------
sr[c("year", "month", "day")]

## ----selectRange--------------------------------------------------------------
subset(sr, select=year:day)

## ----selectExclude------------------------------------------------------------
subset(sr, select=-(year:day))

## ----globs--------------------------------------------------------------------
sr[c("arr_*", "dep_*")]

## ----rename-------------------------------------------------------------------
### FIXME: broken in current Solr CSV writer
### rename(sr, tail_num = "tailnum")

## ----transform----------------------------------------------------------------
sr2 <- transform(sr,
                 gain = arr_delay - dep_delay,
                 speed = distance / air_time * 60)
sr2[c("gain", "speed")]

## ----advanced-with------------------------------------------------------------
with(defer(sr), data.frame(gain = head(arr_delay - dep_delay),
                           speed = head(distance / air_time * 60)))

## ----DataFrame----------------------------------------------------------------
with(defer(sr),
     S4Vectors::DataFrame(gain = arr_delay - dep_delay,
                          speed = distance / air_time * 60))

## ----unique-------------------------------------------------------------------
unique(sr["tailnum"])
unique(sr[c("origin", "tailnum")])

## ----aggregate----------------------------------------------------------------
aggregate(sr, delay = mean(dep_delay, na.rm=TRUE))

## ----aggregate-formula--------------------------------------------------------
delay <- aggregate(~ tailnum, sr,
                       count = TRUE,
                       dist = mean(distance, na.rm=TRUE),
                       delay = mean(arr_delay, na.rm=TRUE))
delay <- subset(delay, count > 20 & dist < 2000)

## ----nunique------------------------------------------------------------------
head(aggregate(~ dest, sr,
               nplanes = nunique(tailnum),
               nflights = ndoc(tailnum)))

## ----aggregate-dynamic--------------------------------------------------------
head(aggregate(~ I(distance > 1000) + tailnum, sr,
               delay = mean(arr_delay, na.rm=TRUE)))

## ----aggreate-evenodd---------------------------------------------------------
head(aggregate(~ odd + tailnum, transform(sr, odd = distance %% 2),
               delay = mean(arr_delay, na.rm=TRUE)))

## ----aggregate-subset---------------------------------------------------------
head(aggregate(~ tailnum, sr,
               subset = distance > 500,
               delay = mean(arr_delay, na.rm=TRUE)))

## ----aggregate-all------------------------------------------------------------
aggregate(sr, delay = mean(arr_delay, na.rm=TRUE))

## ----kill---------------------------------------------------------------------
solr$kill()

