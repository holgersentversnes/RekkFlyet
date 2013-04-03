class window.TransportationSelectionScreen
  FLIGHT_LIST_MAX_COUNT       = 5

  uiFlightListId              = '#flightList'
  uiFlightSearchId            = '#searchFlights'
  uiFlightSearchDivId         = '#StartPageFlightContent'
  uiFlightNotificationLabelId = '#flightNotificationLabel'
  uiBaggageDivId              = '#StartPageBaggageContent'
  uiBaggageCheckinId          = '#baggage_checkin'
  uiBaggageNonCheckinId       = '#baggage_nocheckin'

  instance                    = new TransportationSelectionScreen()
  flightManager               = FlightManager.getInstance()
  trainManager                = TrainManager.getInstance()
  geoLocationManager          = GeoLocationManager.getInstance()
  errorReporter               = null

  currentSearchValue          = "1"
  currentFlight               = null

  constructor: () ->
    FlightManager.getInstance().fetchFlights()

  onFlightSearchChange: (newVal) ->
    if not newVal? or not flightManager?
      if errorReporter? or errorReporter not null then errorReporter ("Verdi eller fly er udefinert.")

    try
      newVal = newVal.trim()
      newVal = newVal.toUpperCase()

      if newVal is currentSearchValue and newVal.length is 0 then return

      $(uiFlightListId).undelegate 'li', 'click'
      $(uiFlightListId).empty()
      $(uiFlightNotificationLabelId).text('')

      if newVal.length is 0 or not $(uiFlightSearchDivId).is(':visible') then return

      newFlights = flightManager.getFlightsByFlightId(newVal, FLIGHT_LIST_MAX_COUNT)

      if newFlights.length is FLIGHT_LIST_MAX_COUNT
        $(uiFlightNotificationLabelId).text('Rafiner søket for flere resultater')
      else if newFlights.length is 0
        $(uiFlightNotificationLabelId).text('Fant ingen fly med koden ' + newVal)
      else if newFlights.length is 1 and currentSearchValue != newVal and newVal.length > currentSearchValue.length
        currentSearchValue = newFlights[0].flightId
        instance.onFlightSelected(flightManager.getFlightByUniqueId(newFlights[0].uniqueId))
        return

      for e in newFlights
        if e?
          $(uiFlightListId).append('<li id=' + e.uniqueId + '><table class="flightSearchResultElement"><tr><td>' + e.flightId + '</td><td>' + e.schedule_time + '</td><td>' + e.airport + '</td></tr></table></li>')

      $(uiFlightListId).listview('refresh')
      currentSearchValue = newVal

      $(uiFlightListId).delegate 'li', 'click', (selected) ->
        selected = selected['currentTarget']['id']
        flight = flightManager.getFlightByUniqueId(selected)
        instance.onFlightSelected (flight)

    catch error
      #if errorReporter? or errorReporter not null then errorReporter('Feil ved søk på fly')
      console.log(error)

  onFlightSelected: (flight) ->
    currentFlight = flight
    currentSearchValue = flight.flightId
    $(uiFlightSearchId).val(flight.flightId)
    @hideFlightSelection()
    @showBaggageSelection()
    @showTrainStationSelection()
    @disableSearchButton()
    console.log("Current Flight Unique ID: " + flight.uniqueId)

    $(uiFlightSearchId).on 'keyup', () ->
      newVal = $(uiFlightSearchId).val().trim()
      if newVal != currentSearchValue
        instance.reset()

  showFlightSelection: () ->
    $(uiFlightSearchDivId).show()
    $(uiFlightSearchId).unbind('keyup')
    $(uiFlightSearchId).on 'keyup', (element) ->
      newValue = $(uiFlightSearchId).val()
      instance.onFlightSearchChange(newValue)
    @onFlightSearchChange("")
    currentFlight = null

  hideFlightSelection: () ->
    $(uiFlightSearchDivId).hide()
    $(uiFlightSearchId).unbind('keyup')
    $(uiFlightListId).empty()
    $(uiFlightListId).listview('refresh')

  reset: () ->
    currentSearchValue = "1"
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

