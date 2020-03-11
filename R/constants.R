assign("column_names",
       c(
         year = "year",
         tco2 = "co2.total",
         pCO2 = "co2.atmos",
         alk = "alkalinity.ocean",
         d13Cocn = "delta.13C.ocean",
         d13Catm = "delta.13C.atmos",
         CO3 = "carbonate.ocean",
         WeatC = "carbonate.weathering",
         WeatS = "silicate.weathering",
         TotW = "total.weathering",
         BurC = "carbon.burial",
         Degas = "degassing.rate",
         Emiss = "emissions",
         Tatm = "temp.atmos",
         Tocn = "temp.ocean"
       ),
       envir = .geocarb)

assign("column_descr",
       c(
         year = "year",
         tco2 = "Total CO2",
         pCO2 = "Atmospheric CO2",
         alk = "Ocean Alkalinity",
         d13Cocn = "Delta 13C (ocean)",
         d13Catm = "Delta 13C (atmosphere)",
         CO3 = "Ocean carbonate concentration",
         WeatC = "Carbonate Weathering Rate",
         WeatS = "Silicate Weathering Rate",
         TotW = "Total Weathering Rate",
         BurC = "Carbon Burial Rate",
         Degas = "Degassing Rate",
         Emiss = "CO2 Emissions",
         Tatm = "Atmospheric Temperature",
         Tocn = "Ocean Temperature"
       ),
       envir = .geocarb)


assign("columns",
       dplyr::tibble(
         index = names(.geocarb$column_names),
         name = .geocarb$column_names) %>%
         dplyr::full_join(
           dplyr::tibble(index = names(.geocarb$column_descr),
                  description = .geocarb$column_descr),
           by = "index"
         ),
       envir = .geocarb)

