# Prepare Backa weather data for input in stm model
# Note that model currently accepts one obs per DOY

library(lubridate)
source('../functions/rounddf.R')

dat <- read.csv('../measurements/Backa_weather.csv', skip = 0, sep = ';')
head(dat)

# Sort out time
dat$date <- ymd(dat$DATUM)
dat$doy <- as.integer(as.character(dat$date, format = '%j'))
dat$year <- as.integer(as.character(dat$date, format = '%Y'))

# Subset
# Raanas site measurements started 7 May 2020 ended 25 May 2021
# Use 2021 measurements for May
dat <- subset(dat, date >= ymd('2020 06 01') & date <= ymd('2021 07 31'))


# Convert radiation from MJ/m2 (per d) to W/m2
# NTS: this looks correct based on final comparison to Uppsala, but need to check with Kristina
dat$Solar.rad. <- signif(dat$Solar.rad. * 1E6 / 86400, 3)

# Summarize by doy
mns <- aggregate(dat[, c('mean.temp', 'Solar.rad.')], dat[, c('doy'), drop = FALSE], mean)
yrs <- aggregate(dat[, c('year')], dat[, c('doy'), drop = FALSE], function(x) x[1])
ns <- aggregate(dat[, c('mean.temp')], dat[, c('doy'), drop = FALSE], function(x) length(x))
datd <- merge(mns, yrs, by = 'doy')
datd <- rounddf(datd, 3, signif)

# Check n
if (any(ns$n > 24)) stop('Count error')

write.csv(datd, '../output/Backa_weather.csv', row.names = FALSE)
