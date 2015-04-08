###############
## libraries ##
###############
# check if already installed, else ask to install it

packs <- c("dplyr","lubridate","chron")

for(pack in packs){
  answer <- 0
  if(sum(installed.packages()==pack,na.rm=TRUE)==0){
    while(answer!="n" & answer!="y"){
      print(paste(pack, "package is not installed. Do you agree to install it? (type y/n)"))
      answer<-readline()
    }
    if(answer=="y"){install.packages(pkgs = as.character(pack))} 
  }    
}

library(dplyr)
library(lubridate) 
library(chron)

###################
## load data set ##
###################

# download and unzip
if(!file.exists("./exdata_data_household_power_consumption.zip")){
  url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
  download.file(url,"./exdata_data_household_power_consumption.zip")
  unzip("./exdata_data_household_power_consumption.zip",exdir=".")

  # save downloading date
  file <- file("./downldate.txt")
  writeLines(date(), file)
  close(file)
}

# reading the data set
# missing values are coded as ?
# convert date and time
if(!(exists("hpc"))){
  hpc <- read.table("household_power_consumption.txt",
                    header=T, sep=';', na.strings="?",colClasses=c("character","character","numeric","numeric",
                                "numeric","numeric","numeric","numeric","numeric"))
  hpc <- hpc[hpc$Date == "1/2/2007"|hpc$Date == "2/2/2007",]
  
  hpc <- mutate(hpc, Date=dmy(Date))%>%
    mutate(Time=chron(times=Time))
  hpc$time <- as.POSIXct(paste(hpc$Date,hpc$Time))
}

##############
## plotting ##
##############

# change local language setting
Sys.setlocale("LC_TIME", "English")

# save it to a PNG file with a width of 480 pixels and a height of 480 pixels
png(filename = "plot4.png", width = 480, height = 480, units = "px")

# plot 4 : combining plots using par()

par(mfcol=c(2,2))

# 1 (same as plot 2)
plot(hpc$time, hpc$Global_active_power, type="l",
     xlab="", ylab="Global Active Power (kilowatts)")

# 2 (same as plot 3, but without box for legend)
plot(hpc$time, hpc$Sub_metering_1, type="l", xlab="", ylab="Energy sub metering")
lines(hpc$time, hpc$Sub_metering_2, type="l", col="red")
lines(hpc$time, hpc$Sub_metering_3, type="l", col="blue")
legend("topright", lty=1, lwd=1, col=c("black","blue","red"), legend=
         c("Sub_metering_1","Sub_metering_2","Sub_metering_3"), bty="n")

# 3 : like plot 2, but with Voltage and xlab (voltage variation by time)
plot(hpc$time, hpc$Voltage, type="l",
     xlab="datetime", ylab="Voltage")

# 4 : like plot 2, but with Global_reactive_power and xlab (global reactive power variation by time)
plot(hpc$time, hpc$Global_reactive_power, type="l",
     xlab="datetime", ylab="Global_reactive_power")

# close file
dev.off()

# removing intermediate values
rm(list=ls()[!(ls()=="hpc")])