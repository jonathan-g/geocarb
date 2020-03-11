
#' run_geocarb
#'
#' Run a simulation of the geochemical carbon cycle.
#'
#' Run a simulation of the geochemical carbon cycle. The model runs a "spin-up"
#' simulation to allow the system to come into equilibrium and then changes
#' conditionns and tracks the response of the system. The simulation tracks
#' atmospheric carbon dioxide, dissolves species in the ocean (carbon dioxide and
#' carbonic acid; bicarbonate ions; and carbonate ions). It also accounts for
#' weathering of silicate and carbonate minerals on the surface and burial of
#' mineral carbon at the bottom of the ocean.
#'
#' @param filename A file to store the results of the simulation.
#' @param co2_spike A spike of carbon dioxide released at the end of a period.
#'   If this is a single number, the spike is released at the end of the
#'   spin-up period. If there are more than two periods (spin up and experiment),
#'   then a vector of length n-1 may be provided to simulate multiple spikes,
#'   to be released at the end of each of the first n-1 periods.
#'   The units are
#' @param co2_emissions CO2 emissions, in billions of tons of carbon.
#' @param periods A vector with the number of years in each period. The length
#'   of the vector is the number of periods. The first period is always the
#'   spinup.
#' @param time_steps A vector with the number of years per time step in each
#'   period. If a single number is given, it will be applied to each period.
#' @param degas The volcanic degassing rate, in trillions of molecules per year.
#'   Either a vector with the value for each period, or a single number that
#'   will be applied to all periods.
#' @param plants A logical variable indicating whether or not there are
#'   vascular plants. Either a vector with values for each period or a single
#'   value that will be applied to all periods.
#' @param land_area The land area, relative to today (1.0 = today). Either a
#'   vector or a single number.
#' @param delta_t2x The climate sensitivity, in degrees Kelvin of warming for
#'   each doubling of CO2.
#' @param million_years_ago How long ago to set year zero (this affects the
#'  brightness of the sun). Note that this is in _millions of years_, not years.
#' @param mean_latitude_continents The mean latitude of the continents.
#'   Either a vector or a single number.
#' @param start_recording When to start recording, relative to year zero. This
#'   allows you to skip recording the first several million years of the spinup..
#'
#' @return A tibble containing the results of the GEOCARB simulation.
#'   The columns of the tibble are:
#'   * `year`: The year in the simulation (0 is the end of the first period).
#'   * `co2.atmos`: The concentration of CO2 in the atmosphere, in parts per
#'      million.
#'   * `silicate.weathering`: The rate of SiO2 being weathered from rocks and
#'     moved to the oceans, in trillions of molecules per year.
#'   * `carbonate.weathering`: The rate of carbonate weathered from carbonate
#'      rocks and moved to the ocean, in trillions of molecules per year.
#'   * `total.weathering`: Total weathering of carbonate and silicate, in
#'     trillions of molecules per year.
#'   * `carbon.burial`: The rate at which carbonate is being converted to
#'      minerals (e.g., limestone) and buried on the ocean floor, in trillions
#'      of molecules per year.
#'   * `co2.total`: Total CO2 dissolved in the ocean. This is the sum of all
#'      forms of CO2:
#'      \ifelse{html}{\out{
#'         [CO<sub>2</sub>] +
#'         [H<sub>2</sub>CO<sub>3</sub>] +
#'         [HCO<sub>3</sub><sup>-</sup>] +
#'         [CO<sub>3</sub><sup>-2</sup>]}}{\deqn{
#'         \left[CO_{2}\right] +
#'         \left[H_{2}CO_{3}\right] +
#'         \left[HCO_{3}^{-}\right] +
#'         \left[CO_{3}^{-2}\right]
#'         }{CO2 + carbonic acid (H2CO2) + bicarbonate (HCO3-) +
#'           carbonate (CO3--)}},
#'      in moles per cubic meter.
#'   * `alkalinity.ocean`: The ocean alkalinity. This is the amount of acid (H+)
#'     necessary to neutralize the carbonate and bicarbonate in the ocean. The
#'     detailed definition is complicated, but to a good approximation,
#'     \ifelse{html}{\out{alk = [HCO<sub>3</sub><sup>-</sup>] +
#'       2[CO<sub>3</sub><sup>-2</sup>]}}{\deqn{
#'         \text{alk} = \left[HCO_3^{-}\right] + 2 \left[CO_3^{-2}\right]
#'       }{alk = [HCO3-] + 2 [CO3--]}}.
#'     This is measured in moles per cubic meter.
#'   * `carbonate.ocean`: The concentration of dissolved carbonate
#'     (\ifelse{html}{\out{CO<sub>3</sub><sup>-2</sup>}}{\eqn{\text{CO}_3^{-2}}{CO3--}})
#'     in the ocean, in micromoles per kg seawater.
#'   * `degassing.rate`: The rate at which CO2 is emitted by natural degassing
#'     (e.g., volcanoes), in trillions of molecules per year.
#'   * `emissions`: The rate at which CO2 is emitted by human activities
#'     (e.g., burning fossil fuels), in trillions of molecules per year.
#'   * `temp.atmos`: The temperature of the atmosphere, in degrees Celsius.
#'   * `temp.ocean`: The temperature of the ocean surface, in degrees Celsius.
#'
#' @examples
#' \dontrun{
#' gc <- run_geocarb(co2_spike = 1000,
#'                   co2_emissions = list(0, seq(1, 100, 1), 0),
#'                   periods = c(5E6, 100, 2E6),
#'                   time_steps = c(50, 1, 50),
#'                   degas = 7.5)
#' }
#'
#'@export
run_geocarb = function(filename,
                       co2_spike = 0,
                       co2_emissions = 0,
                       periods = c(5E6, 2E6),
                       time_steps = 50,
                       degas = 7.5,
                       plants = TRUE,
                       land_area = 1,
                       delta_t2x = 3.0,
                       million_years_ago = 0,
                       mean_latitude_continents = 30,
                       start_recording = -2000) {
  if (! exists("geocarb_module", envir = .geocarb))
    load_geocarb()
  geocarb_module <- .geocarb$geocarb_module

  gc <- geocarb_module$geocarb(co2_spike, degas,
                               time_steps, periods,
                               delta_t2x,
                               million_years_ago, mean_latitude_continents,
                               plants, land_area,
                               (periods[1] + start_recording - time_steps[1]),
                               co2_emissions)

  geocarb_module$save(gc, filename)

  names(gc) <- .geocarb$column_names[names(gc)]
}
