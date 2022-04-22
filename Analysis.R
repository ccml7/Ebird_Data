## Installation of packages if it is necesary
install.packages("remotes")
install.packages("raster")
remotes::install_github("CornellLabofOrnithology/ebirdst")

library(ebirdst)
library(raster)

# library(sf)
# library(rnaturalearth)
# library(ggplot2)
# library(viridisLite)

set_ebirdst_access_key("XXXXXXX") ## You need an access key from https://ebird.org/st/request

## Download species data
pc_path <- ebirdst_download(species = "Buteo platypterus") ## This could take a while
abd <- load_raster("abundance", path = pc_path, resolution = "lr") ## Select abundance layers

#### Enter seasonal data
initial_date <- "2020-12-07" ## Date format (YYYY-MM-DD) although year does not matter
final_date <- "2021-02-08"

## Extracting weeks numbers from dates
weeks <- function(initial_date, final_date) { 
    week1 <- as.numeric(strftime(initial_date, "%V"))
    week2 <- as.numeric(strftime(final_date, "%V"))

    if (week1 < week2) {
       weeks_final <- seq(from = week1, to = week2, by = 1)
    } else if (week1 > week2) {
       part1 <- seq(week1, 52, by = 1)
       part2 <- seq(1, week2, by = 1)
       weeks_final <- sort(c(part1, part2))
    } else {
       print("Date values are equal or doesn't correspond to a date format")
    }

    return(weeks_final)
}

weeks_numbers <- weeks(initial_date = initial_date, final_date = final_date)

seasonal_measure <- function(raster_stack, weeks) {
    number_weeks <- length(weeks)
    raster_list <- list()
    for (i in 1:number_weeks) {
        for (value in weeks) {
            raster_list[[i]] <- raster_stack[[value]]
        }
    }

    season_stack <- stack(raster_list)
    sum_up <- raster::calc(season_stack, sum)
    result_raster <- sum_up
    return(result_raster)
}

species_data <- seasonal_measure(raster_stack = abd, weeks = weeks_numbers)

### Geographical data
## Layers upload
area_interest <- shapefile("/home/camilo/Documentos/Projects/Ebird_Data/layers/AreaEstudio_HC_20220311.shp")
colombia_shape <- shapefile("/home/camilo/Documentos/Capas/COL_adm/COL_adm1.shp")

area_transformed <- spTransform(area_interest, crs(abd))
colombia_transformed <- spTransform(colombia_shape, crs(abd))

## Selecting departaments surrounding area of interest
pol1 <- which(colombia_transformed@data$NAME_1 == "Córdoba")
pol2 <- which(colombia_transformed@data$NAME_1 == "Antioquia")

pol_final <- union(colombia_transformed[pol1,], colombia_transformed[pol2,])
pol_final <- aggregate(pol_final)

colombia_data <- mask(crop(species_data, pol_final), pol_final)
total <- cellStats(colombia_data, sum)

area_interest_data <- mask(crop(species_data, area_transformed), area_transformed)
area <- cellStats(area_interest_data, sum)

percentaje_population <- (area / total) * 100
percentaje_population

#### Mapping Results
## Hay que correr todas la lineas para tener el mapa al final
### CAMBIAR LA RUTA DE DESTINO DE LA FIGURA!!!!!
png("/home/camilo/Documentos/Projects/Ebird_Data/Mapa-Especie.png", units = "cm", width = 15, height = 15, res = 100)
plot(colombia_data, title = "Abudancia relativa Buteo platypterus") ## CAMBIAR NOMBRE DE LA ESPECIE!!!
plot(colombia_transformed[pol1,], add = T)
plot(colombia_transformed[pol2,], add = T)
plot(area_transformed, add = T, lwd = 1, border = "red")
dev.off()
