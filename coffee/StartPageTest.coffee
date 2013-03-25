class window.StartPageTest
  @_UI_FLIGHT_LIST                = "flightList"
  @_UI_FLIGHT_NOTIFICATION_LABEL  = "flightNotificationLabel"
  @_UI_FLIGHT_SEARCH_INPUT        = "searchFlights"
  @_UI_FLIGHT_PAGE_DIV            = "StartPageFlightContent"
  @_UI_BAGGAGE_DIV                = "StartPageBaggageContent"
  @_UI_BAGGAGE_CHECKIN            = "baggage_checkin"
  @_UI_BAGGAGE_NONCHECKIN         = "baggage_nocheckin"
  @_FLIGHT_LIST_MAX_COUNT         = 5

  flightManager = new FlightManager()
  instance      = null;

  currentSearchValue = ""

  uiFlightListId = '#' + StartPageTest._UI_FLIGHT_LIST
  uiFlightSearchId = '#' + StartPageTest._UI_FLIGHT_SEARCH_INPUT
  uiFlightSearchDivId = '#' + StartPageTest._UI_FLIGHT_PAGE_DIV
  uiFlightNotificationLabelId = '#' + StartPageTest._UI_FLIGHT_NOTIFICATION_LABEL
  uiBaggageDivId = '#' + StartPageTest._UI_BAGGAGE_DIV
  uiBaggageCheckinId = '#' + StartPageTest._UI_BAGGAGE_CHECKIN
  uiBaggageNonCheckinId = '#' + StartPageTest._UI_BAGGAGE_NONCHECKIN

  constructor: () ->
    flightManager = new FlightManager();
    flightManager.fetchFlights(@fetchFlightsCallback, @errorCallback)
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

      $(uiFlightListId).empty()
      $(uiFlightNotificationLabelId).text('')

      if newVal.length > 0 and $(uiFlightListId).is(':visible')
        newFlights = flightManager.getFlightsById(newVal, StartPageTest._FLIGHT_LIST_MAX_COUNT)
        console.dir(newFlights)

        if newFlights.length is StartPageTest._FLIGHT_LIST_MAX_COUNT
          $(uiFlightNotificationLabelId).text('Rafiner søket for flere resultater')
        else if newFlights.length is 0
          $(uiFlightNotificationLabelId).text('Fant ingen fly med koden ' + newVal)
        else if newFlights.length is 1 and currentSearchValue != newVal and newVal.length >= currentSearchValue.length
          StartPageTest.getInstance().onFlightSelected(newFlights[0].flightId)
          currentSearchValue = newFlights[0].flightId
          return

        for e in newFlights
          if e?
            $(uiFlightListId).append('<li id=' + e.flightId + '><table class="flightSearchResultElement"><tr><td>' + e.flightId + '</td><td>' + e.schedule_time + '</td><td>' + e.airport + '</td></tr></table></li>')

        $(uiFlightListId).delegate 'li', 'click', (val) ->
          val = val['currentTarget']['id']
          StartPageTest.getInstance().onFlightSelected val
        $(uiFlightListId).listview('refresh')

        currentSearchValue = newVal
    catch error
      @errorCallback(error)

  ###
    Executed when the user presses a flight in the list or types the whole name.
  ###
  onFlightSelected: (val) ->
    $(uiFlightSearchId).val(val)
    StartPageTest.getInstance().hideStepOne()
    StartPageTest.getInstance().ShowStepTwo()
    $(uiFlightSearchId).on 'keyup', () ->
      if $(uiFlightSearchId).val().trim() != currentSearchValue
        $(uiFlightSearchId).unbind('keyup')
        StartPageTest.getInstance().showStepOne()
        StartPageTest.getInstance().onFlightSearchChange(val)
        StartPageTest.getInstance().hideStepTwo()

  fetchFlightsCallback: (flightArray) ->
    console.dir(flightArray)

  errorCallback: (error) ->
    console.error(error)

  @getInstance: () ->
    instance ?= new StartPageTest()