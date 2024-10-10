#Packages
library(pacman)
p_load('duckplyr', 'data.table', 'tidyverse')


#Unzip and load data 
zip_path <- "C:/Users/Diego/OneDrive/Documentos/Causal Inference/archive.zip"
temp_dir <- tempdir()
unzip(zip_path, exdir = temp_dir)
csv_files <- list.files(temp_dir, 
                        pattern = "\\.csv$",
                        full.names = TRUE)

#Loading data ---- 

#duckplyr 
system.time(taxi_data <- duckplyr_df_from_csv(csv_files[2]))
#dat.table 
system.time(taxi_data_f <- fread(csv_files[2]))



#Computing: Average trip per Vendor in trips of more than 1 passenger ----

#1. Duckplyr 
system.time({
  out_duckplyr <- taxi_data  |> 
    filter(passenger_count > 1) |> 
    summarize( .by = c(VendorID),
               avg_distance = mean(trip_distance))
})
#2. Data.table 
system.time({
  out_datatable <- taxi_data_f[passenger_count > 1, 
                              .(avg_distance = mean(trip_distance)), 
                               by = VendorID]
})
# 3. Load data.table and compute with dplyr 
system.time({
  out_dt_dplyr <- taxi_data_f  |> 
    filter(passenger_count > 1) |> 
    summarize( .by = c(VendorID),
               avg_distance = mean(trip_distance))
})


# Ejecute 30 times and take the average----
#Empty list of outcomes 
times_duckplyr <- numeric(30)
times_datatable <- numeric(30)
times_dt_dplyr <- numeric(30)


# 1. Duckplyr
for (i in 1:30) {
  times_duckplyr[i] <- system.time({
    out_duckplyr <- taxi_data  |> 
      filter(passenger_count > 1) |> 
      summarize( .by = c(VendorID),
                 avg_distance = mean(trip_distance))
  })["elapsed"]
}

# 2. Data.table
for (i in 1:30) {
  times_datatable[i] <- system.time({
    out_datatable <- taxi_data_f[passenger_count > 1, 
                                 .(avg_distance = mean(trip_distance)), 
                                 by = VendorID]
  })["elapsed"]
}

# 3. Data.table  + dplyr 
for (i in 1:30) {
  times_dt_dplyr[i] <- system.time({
    out_dt_dplyr <- taxi_data_f  |> 
      filter(passenger_count > 1) |> 
      summarize( .by = c(VendorID),
                 avg_distance = mean(trip_distance))
  })["elapsed"]
}

avg_time_duckplyr <- mean(times_duckplyr)
avg_time_datatable <- mean(times_datatable)
avg_time_dt_dplyr <- mean(times_dt_dplyr)


cat("Promedio de tiempos de ejecución:\n")
cat("Duckplyr: ", avg_time_duckplyr, "segundos\n")
cat("Data.table: ", avg_time_datatable, "segundos\n")
cat("Data.table + dplyr: ", avg_time_dt_dplyr, "segundos\n")




