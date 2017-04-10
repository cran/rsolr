### R code from vignette source 'intro.Rnw'

###################################################
### code chunk number 1: loadData
###################################################
library(nycflights13)
dim(flights)
head(flights)


###################################################
### code chunk number 2: startSolr
###################################################
library(rsolr)
schema <- deriveSolrSchema(flights)
solr <- TestSolr(schema)


###################################################
### code chunk number 3: SolrFrame
###################################################
sr <- SolrFrame(solr$uri)


###################################################
### code chunk number 4: uploadData
###################################################
sr[] <- flights


###################################################
### code chunk number 5: previewSolrFrame
###################################################
dim(sr)
head(sr)


###################################################
### code chunk number 6: subset
###################################################
subset(sr, month == 1 & day == 1)


###################################################
### code chunk number 7: window
###################################################
window(sr, start=1L, end=10L)


###################################################
### code chunk number 8: head
###################################################
head(sr, 10L)


###################################################
### code chunk number 9: sequence
###################################################
sr[1:10,]


###################################################
### code chunk number 10: sort
###################################################
sort(sr, by = ~ year + month + day)


###################################################
### code chunk number 11: sortDecreasing
###################################################
sort(sr, by = ~ arr_delay, decreasing=TRUE)


###################################################
### code chunk number 12: select
###################################################
subset(sr, select=c(year, month, day))


###################################################
### code chunk number 13: bracket
###################################################
sr[c("year", "month", "day")]


###################################################
### code chunk number 14: selectRange
###################################################
subset(sr, select=year:day)


###################################################
### code chunk number 15: selectExclude
###################################################
subset(sr, select=-(year:day))


###################################################
### code chunk number 16: globs
###################################################
sr[c("arr_*", "dep_*")]


###################################################
### code chunk number 17: rename
###################################################
### FIXME: broken in current Solr CSV writer
### rename(sr, tail_num = "tailnum")


###################################################
### code chunk number 18: transform
###################################################
sr2 <- transform(sr,
                 gain = arr_delay - dep_delay,
                 speed = distance / air_time * 60)
sr2[c("gain", "speed")]


###################################################
### code chunk number 19: advanced-with
###################################################
with(defer(sr), data.frame(gain = head(arr_delay - dep_delay),
                           speed = head(distance / air_time * 60)))


###################################################
### code chunk number 20: DataFrame
###################################################
with(defer(sr),
     S4Vectors::DataFrame(gain = arr_delay - dep_delay,
                          speed = distance / air_time * 60))


###################################################
### code chunk number 21: unique
###################################################
unique(sr["tailnum"])
unique(sr[c("origin", "tailnum")])


###################################################
### code chunk number 22: aggregate
###################################################
aggregate(sr, delay = mean(dep_delay, na.rm=TRUE))


###################################################
### code chunk number 23: aggregate-formula
###################################################
delay <- aggregate(~ tailnum, sr,
                       count = TRUE,
                       dist = mean(distance, na.rm=TRUE),
                       delay = mean(arr_delay, na.rm=TRUE))
delay <- subset(delay, count > 20 & dist < 2000)


###################################################
### code chunk number 24: nunique
###################################################
head(aggregate(~ dest, sr,
               nplanes = nunique(tailnum),
               nflights = ndoc(tailnum)))


###################################################
### code chunk number 25: aggregate-dynamic
###################################################
head(aggregate(~ I(distance > 1000) + tailnum, sr,
               delay = mean(arr_delay, na.rm=TRUE)))


###################################################
### code chunk number 26: aggreate-evenodd
###################################################
head(aggregate(~ odd + tailnum, transform(sr, odd = distance %% 2),
               delay = mean(arr_delay, na.rm=TRUE)))


###################################################
### code chunk number 27: aggregate-subset
###################################################
head(aggregate(~ tailnum, sr,
               subset = distance > 500,
               delay = mean(arr_delay, na.rm=TRUE)))


###################################################
### code chunk number 28: aggregate-all
###################################################
aggregate(sr, delay = mean(arr_delay, na.rm=TRUE))


###################################################
### code chunk number 29: kill
###################################################
solr$kill()


