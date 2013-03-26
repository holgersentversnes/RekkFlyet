class window.StartPage
  @_FLIGHT_LIST_MAX_COUNT         = 5
  @_CHOSEN_FLIGHT                 = null

  flightManager = new FlightManager()
  trainManager = new TrainManager()
  instance      = null;

  uiFlightListId = '#flightList'
  uiFlightSearchId = '#searchFlights'
  uiFlightSearchDivId = '#StartPageFlightContent'
  uiFlightNotificationLabelId = '#flightNotificationLabel'
  uiBaggageDivId = '#StartPageBaggageContent'
  uiBaggageCheckinId = '#baggage_checkin'
  uiBaggageNonCheckinId = '#baggage_nocheckin'

  currentSearchValue = ""
  flightManager = null
  instance      = null

  constructor: (fm) ->
    flightManager = fm
    @hideStepTwo()

  ###
    Shows the list of available flights
  ###
  showStepOne: () ->
    $(uiFlightSearchDivId).show()
    $(uiFlightSearchId).on 'keyup', () ->
      instance.onFlightSearchChange($(uiFlightSearchId).val())

  ###
    Hides the list of available flights
  ###
  hideStepOne: () ->
    $(uiFlightSearchDivId).hide()
    $(uiFlightSearchId).unbind('keyup')

  ###
    Shows the baggage options and the train station "picker"
  ###
  ShowStepTwo: () ->
    $(uiBaggageDivId).show()

  ###
    Hides the baggage options and the train station "picker"
  ###
  hideStepTwo: () ->
    $(uiBaggageDivId).hide()

  ###
    Event that gets fired on search field change/key up
  ###
  onFlightSearchChange: (newVal) ->
    try
      if not newVal? or not flightManager?
        throw new Error('Something went wrong')

      newVal = newVal.trim()
      if newVal is currentSearchValue
        return

      $(uiFlightListId).empty()
      $(uiFlightNotificationLabelId).text('')

      if newVal.length > 0 and $(uiFlightListId).is(':visible')
        newFlights = flightManager.getFlightsById(newVal, StartPage._FLIGHT_LIST_MAX_COUNT)
        console.dir(newFlights)

        if newFlights.length is StartPage._FLIGHT_LIST_MAX_COUNT
          $(uiFlightNotificationLabelId).text('Rafiner søket for flere resultater')
        else if newFlights.length is 0
          $(uiFlightNotificationLabelId).text('Fant ingen fly med koden ' + newVal)
        else if newFlights.length is 1 and currentSearchValue != newVal and newVal.length >= currentSearchValue.length
          StartPage.getInstance().onFlightSelected(newFlights[0].flightId)
          currentSearchValue = newFlights[0].flightId
          return

        for e in newFlights
          if e?
            $(uiFlightListId).append('<li id=' + e.flightId + '><table class="flightSearchResultElement"><tr><td>' + e.flightId + '</td><td>' + e.schedule_time + '</td><td>' + e.airport + '</td></tr></table></li>')

        $(uiFlightListId).delegate 'li', 'click', (val) ->
          val = val['currentTarget']['id']
          StartPage.getInstance().onFlightSelected val
        $(uiFlightListId).listview('refresh')

        currentSearchValue = newVal
    catch error
      @errorCallback(error)

  ###
    Executed when the user presses a flight in the list or types the whole name.
  ###
  onFlightSelected: (val) ->
    StartPage._CHOSEN_FLIGHT = flightManager.getFlightsById(val, 1);
    $(uiFlightSearchId).val(val)

    StartPage.getInstance().hideStepOne()
    StartPage.getInstance().ShowStepTwo()
    $(uiFlightSearchId).on 'keyup', () ->
      if $(uiFlightSearchId).val().trim() != currentSearchValue
        $(uiFlightSearchId).unbind('keyup')
        StartPage.getInstance().showStepOne()
        StartPage.getInstance().onFlightSearchChange(val)
        StartPage.getInstance().hideStepTwo()

  fetchFlightsCallback: (flightArray) ->
    console.dir(flightArray)

  errorCallback: (error) ->
    console.error(error)

  @getInstance: () ->
    instance ?= new StartPage()