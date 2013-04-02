class window.TransportationSelectionScreen2
  FLIGHT_LIST_MAX_COUNT       = 5

  uiFlightListId              = '#flightList'
  uiFlightSearchId            = '#searchFlights'
  uiFlightSearchDivId         = '#StartPageFlightContent'
  uiFlightNotificationLabelId = '#flightNotificationLabel'
  uiBaggageDivId              = '#StartPageBaggageContent'
  uiBaggageCheckinId          = '#baggage_checkin'
  uiBaggageNonCheckinId       = '#baggage_nocheckin'

  instance                    = new TransportationSelectionScreen2()
  flightManager               = FlightManager.getInstance()
  trainManager                = TrainManager.getInstance()
  geoLocationManager          = GeoLocationManager.getInstance()
  errorReporter               = null

  currentSearchValue          = ""
  currentFlight               = null

  onFlightSearchChange: (newVal) ->
    if not newVal? or not flightManager?
      if errorReporter? then errorReporter ("Verdi eller fly er udefinert.")

    try
      newVal = newVal.trim()
      newVal = newVal.toUpperCase()



    catch error
      if errorReporter? then errorReporter('Feil ved søk på fly')

  showFlightSelection: () ->
    $(uiFlightSearchDivId).show()
    $(uiFlightSearchId).unbind('keyup')
    $(uiFlightSearchId).on 'keyup', (element) ->
      newValue = $(element).val()
      console.log(newValue)
    @onFlightSearchChange(currentSearchValue)

  hideFlightSelection: () ->
    $(uiFlightSearchDivId).hide()
    $(uiFlightSearchId).unbind('keyup')

  reset: () ->
    currentSearchValue = ""
    currentFlight = null
    @hideBaggageSelection()
    @hideTrainStationSelection()
    @disableSearchButton()
    @showFlightSelection()

  onSearchButtonPressed: () ->
    if currentFlight?
      console.log(currentFlight)
      trainManager.fetchTrains(2190400, currentFlight)

  @getInstance: () ->
    return instance

  showBaggageSelection: () ->
    $(uiBaggageDivId).show()

  hideBaggageSelection: () ->
    $(uiBaggageDivId).hide()

  showTrainStationSelection: () ->

  hideTrainStationSelection: () ->

  enableSearchButton: () ->

  disableSearchButton: () ->

