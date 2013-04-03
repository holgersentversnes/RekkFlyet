class window.TransportationSelectionScreen3
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
  currentSearchValue          = ""
  currentFlight               = null

  #trainManager                = new TrainManager()

  start: () ->
    flightManager.fetchFlights(@fetchFlightsCallback, @errorCallback)
    @showFlightSelection()
    @hideBaggageSelection()
    @hideGoButton()
    @hideTrainStationSelection()
    @disableGoButton()

  showFlightSelection: () ->
    $(uiFlightSearchDivId).show()
    #$(uiFlightSearchId).unbind('keyup')
    $(uiFlightSearchId).unbind()

    $(uiFlightSearchId).on 'keyup', (e) ->
      #console.log('KeyUp: ' + $(uiFlightSearchId).val())
      #console.log(e)
      instance.onFlightSearchChange($(uiFlightSearchId).val())

    $(uiFlightSearchId).on 'change', (e) ->
      #console.log('Change: ' + $(uiFlightSearchId).val())
      #console.log(e)

  hideFlightSelection: () ->
    $(uiFlightSearchDivId).hide()
    $(uiFlightSearchId).unbind('keyup')

  showBaggageSelection: () ->
    $(uiBaggageDivId).show()

  hideBaggageSelection: () ->
    $(uiBaggageDivId).hide()

  showTrainStationSelection: () ->

  hideTrainStationSelection: () ->

  showGoButton: () ->

  onSearchButtonPressed: () ->
    if currentFlight?
      console.log(currentFlight)
      trainManager.fetchTrains(2190400, currentFlight[0])

  hideGoButton: () ->

  enableGoButton: () ->

  disableGoButton: () ->

  onFlightSearchChange: (val) ->
    if not val? or not flightManager? then throw new Error('Noe gikk feil')

    try
      val = val.trim()
      val = val.toUpperCase()

      if val is currentSearchValue then return

      $(uiFlightListId).empty()
      $(uiFlightNotificationLabelId).text('')

      if val.length is 0 or not $(uiFlightSearchDivId).is(':visible') then return
      if not @isValidFlightIdFormat(val) then return

      newFlights = flightManager.getFlightsById(val, FLIGHT_LIST_MAX_COUNT)

      if newFlights.length is FLIGHT_LIST_MAX_COUNT
        $(uiFlightNotificationLabelId).text('Rafiner søket for flere resultater')
      else if newFlights.length is 0
        $(uiFlightNotificationLabelId).text('Fant ingen fly med koden ' + val)
      else if newFlights.length is 1 and currentSearchValue != val and val.length > currentSearchValue.length
        currentSearchValue = newFlights[0].flightId
        instance.onFlightSelected(currentSearchValue)
        return

      for e in newFlights
        if e?
          $(uiFlightListId).append('<li id=' + e.flightId + '><table class="flightSearchResultElement"><tr><td>' + e.flightId + '</td><td>' + e.schedule_time + '</td><td>' + e.airport + '</td></tr></table></li>')

      $(uiFlightListId).delegate 'li', 'click', (val) ->
        val = val['currentTarget']['id']
        currentSearchValue = val
        instance.onFlightSelected (val)

      $(uiFlightListId).listview('refresh')
      currentSearchValue = val
    catch error
      console.error(error)
      throw error

  onFlightSelected: (val) ->
    $(uiFlightSearchId).val(val)
    instance.hideFlightSelection()
    instance.showBaggageSelection()
    instance.showTrainStationSelection()
    instance.showGoButton()
    instance.disableGoButton()

    currentFlight = flightManager.getFlightsById(val, 1)

    $(uiFlightSearchId).on 'keyup', () ->
      newVal = $(uiFlightSearchId).val().trim()
      if newVal != currentSearchValue
        instance.disableGoButton()
        instance.hideGoButton()
        instance.hideTrainStationSelection()
        instance.hideBaggageSelection()
        instance.showFlightSelection()
        instance.onFlightSearchChange(val)
        currentFlight = null

  fetchFlightsCallback: (flightArray) ->
    console.dir(flightArray)

  errorCallback: (error) ->
    console.error(error)

  getCurrentFlight: () ->
    return currentFlight

  isValidFlightIdFormat: (val) ->
    re = new RegExp("[A-z0-9]+")
    return true

  @getInstance: () ->
    return instance