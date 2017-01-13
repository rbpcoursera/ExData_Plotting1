local({ # force the script to maintain local scope, so as to avoid name collisions in the main environment
  
library(lubridate)
library(sqldf)
  
# Load the data needed for the plot and filter/cast data for optimal use
loadAndPreprocessData <- function() {
  filePath <- "household_power_consumption.txt"
  
  # I'm using the SQL-DataFrame (sqldf) here to filter the data as it is loaded
  # It uses SQLite to generate a temporary file, loads the data into a table
  # and then executes this query upon it. It uses quite a lot less memory and
  # runs much faster than trying to load the whole CSV file and then filtering
  query <- "select  (Date || ' ' || Time) as Timestamp, 
                    Global_active_power, 
                    Global_reactive_power, 
                    Voltage, 
                    Sub_metering_1, 
                    Sub_metering_2, 
                    Sub_metering_3 
            from file 
            where (Date = '1/2/2007' or Date = '2/2/2007')"
  data <- read.csv.sql(filePath, query, sep = ";")
  
  # SQLite (the engine sqldf is using) does not support Datetime types, so the
  # Date/Time fields are treated as strings. Here we use Lubridate to convert 
  # those strings into a native POSIX timestamp. I concatenated the Date and Time
  # Fields in the sql query to make it even easier/quicker. 
  data$Timestamp <- dmy_hms(data$Timestamp)
  data
}

# Generates a plot as indicted by the example image
generatePlot <- function(outputFile) {
  data <- loadAndPreprocessData()
  png(outputFile, width = 480, height = 480, units = "px")
  par(mfcol = c(2, 2))
  with(data, {
      {
        plot(Timestamp, Global_active_power, ylab = "Global Active Power", xlab = "", type = "n")
        lines(Timestamp, Global_active_power, col = "black")
      } 
      {
        plot(Timestamp, Sub_metering_1, ylab = "Energy sub metering", xlab = "", type = "n")
        lines(Timestamp, Sub_metering_1, col = "black")
        lines(Timestamp, Sub_metering_2, col = "red")
        lines(Timestamp, Sub_metering_3, col = "blue")
        legend("topright", col = c("black", "red", "blue"), bty = "n",
               legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), lty = 1)
      } 
      {
        plot(Timestamp, Voltage, xlab = "datetime", type = "n")
        lines(Timestamp, Voltage, col = "black")
      } 
      {
        plot(Timestamp, Global_reactive_power, xlab = "datetime", type = "n")
        lines(Timestamp, Global_reactive_power, col = "black")
      }
    })
  dev.off()
}

generatePlot("plot4.png")
  
})