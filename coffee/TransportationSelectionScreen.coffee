class window.TransportationSelectionScreen
  FLIGHT_LIST_MAX_COUNT       = 5

  uiFlightListId              = '#flightList'
  uiFlightSearchId            = '#searchFlights'
  uiFlightSearchDivId         = '#StartPageFlightContent'
  uiFlightNotificationLabelId = '#flightNotificationLabel'
  uiBaggageDivId              = '#StartPageBaggageContent'
  uiBaggageCheckinId          = '#baggage_checkin'
  uiBaggageNonCheckinId       = '#baggage_nocheckin'
  uiTrainDropDown             = '#trainDropDown'
  uiTrainDropDownDiv          = '#trainDropDownDiv'
  uiSearchButton              = '#searchButton'
  uiClosestTrainStationButton = '#locateTrainStationButton'

  instance                    = new TransportationSelectionScreen()
  flightManager               = FlightManager.getInstance()
  trainManager                = TrainManager.getInstance()
  geoLocationManager          = GeoLocationManager.getInstance()
  trainStationManager         = TrainStationManager.getInstance()
  errorReporter               = null

  currentSearchValue          = "1"
  currentFlight               = null
  currentTrainStationId       = "0"

  constructor: () ->
    #FlightManager.getInstance().fetchFlights()
    #GeoLocationManager.getInstance().fetchLocation(false)
    #TrainStationManager.getInstance().fetchAllTrainStations()

  fillTrainDropDown: () ->
    $(uiTrainDropDown).empty()
    $(uiTrainDropDown).append('<option value="0" selected="selected">Velg togstasjon...</option>')
    for e in trainStationManager.getAllTrainStations()
      $(uiTrainDropDown).append('<option value="' + e.id + '">' + e.name + '</option>')
    $('#trainDropDown').selectmenu();
    $('#trainDropDown').selectmenu('refresh', true)

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
      #if errorReporter? or errorReporter != null then errorReporter('Feil ved søk på fly')
      console.log(error)

  onFlightSelected: (flight) ->
    console.log("onFlightSelected")
    currentFlight = flight
    currentSearchValue = flight.flightId
    $(uiFlightSearchId).val(flight.flightId)
    @hideFlightSelection()
    @showBaggageSelection()
    @showTrainStationSelection()
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
    instance.onFlightSearchChange("")
    currentFlight = null

  hideFlightSelection: () ->
    $(uiFlightSearchDivId).hide()
    $(uiFlightSearchId).unbind('keyup')
    $(uiFlightListId).empty()
    $(uiFlightListId).listview('refresh')

  reset: () ->
    $(uiSearchButton).off 'click'
    $(uiClosestTrainStationButton).off 'click'
    $(uiTrainDropDown).off 'change.stationChange'
    currentSearchValue = "1"
    currentFlight = null
    currentTrainStationId = "0"
    instance.showFlightSelection()
    instance.hideBaggageSelection()
    instance.hideTrainStationSelection()
    instance.disableSearchButton()
    $(uiSearchButton).on 'click', instance.onSearchButtonClick
    $(uiClosestTrainStationButton).on 'click', instance.onClosestTrainStationClick
    $(uiTrainDropDown).on 'change.stationChange', instance.onTrainDropDownChange
    instance.fillTrainDropDown()

  onClosestTrainStationClick: () ->
    lat = geoLocationManager.getCurrentLocation()['coords']['latitude']
    long = geoLocationManager.getCurrentLocation()['coords']['longitude']
    closest = trainStationManager.getClosestTrainStation(lat, long)
    $(uiTrainDropDown).val(closest.id)
    $('select').selectmenu('refresh', true)
    instance.onTrainDropDownChange()

  onTrainDropDownChange: () ->
    if $(uiTrainDropDown).val() is "0"
      instance.disableSearchButton()
    else
      currentTrainStationId = $(uiTrainDropDown).val()
      instance.enableSearchButton()


  onSearchButtonClick: () ->
    if currentFlight? and not $(uiSearchButton).prop('disabled') and currentTrainStationId != "0"
      $.mobile.loading 'show', { text: 'Henter toginformasjon', textVisible: true, theme: 'c', html: ""}
      flightManager.getAirportNameById(currentFlight.airport, instance.onSearchButtonClickAirportSuccess, instance.onSearchButtonClickError)

  onSearchButtonClickAirportSuccess: (airportName) ->
    console.log(airportName)
    currentFlight.airportName = airportName
    trainManager.fetchTrains currentTrainStationId, currentFlight, instance.onSearchButtonClickTrainSuccess, instance.onSearchButtonClickError

  onSearchButtonClickError: (message) ->
    console.log(message)
    if errorReporter? and errorReporter != null then errorReporter 'Feilet ved henting av toginformasjon'
    $.mobile.loading 'hide'

  onSearchButtonClickTrainSuccess: (trainArray) ->
    rs = new ResultScreen()
    rs.showTrainInResultList(currentFlight, trainArray)
    $.mobile.loading 'hide'
    window.location.hash = "#page2"


  @getInstance: () ->
    return instance

  showBaggageSelection: () ->
    $(uiBaggageDivId).show()

  hideBaggageSelection: () ->
    $(uiBaggageDivId).hide()

  showTrainStationSelection: () ->
    $(uiTrainDropDownDiv).show()

  hideTrainStationSelection: () ->
    $(uiTrainDropDownDiv).hide()

  enableSearchButton: () ->
    $(uiSearchButton).removeClass('ui-disabled')

  disableSearchButton: () ->
    $(uiSearchButton).addClass('ui-disabled')
