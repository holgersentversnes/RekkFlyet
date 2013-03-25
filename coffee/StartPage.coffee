class window.StartPage
  @_UI_FLIGHT_LIST = "flightList"
  @_UI_FLIGHT_NOTIFICATION_LABEL = "flightNotificationLabel"
  @_UI_FLIGHT_SEARCH_INPUT = "searchFlights"
  @_FLIGHT_LIST_MAX_COUNT = 5
  @_UI_FLIGHT_PAGE_CONTENT = "StartPageFlightContent"

  flightManager = null

  constructor: () ->
    flightManager = new FlightManager()
    flightManager.fetchFlights(@fetchFlightsCallback, @reportError)


  reportError: (errorMessage) ->
    console.log(errorMessage)

  fetchFlightsCallback: (flightArray) ->
    console.dir(flightArray)
    flightManager.getAirportNameById('osl', @getAirportByNameCallback, @reportError)
    show()

  getAirportByNameCallback: (name) ->
    console.log(name)

  show= () ->
    try
      $('#' + StartPage._UI_FLIGHT_SEARCH_INPUT).on 'keyup', () ->
        val = $('#' + StartPage._UI_FLIGHT_SEARCH_INPUT).val()
        onFlightSearchChange(val, StartPage._FLIGHT_LIST_MAX_COUNT)
    catch error
      console.log(error)

  hide= () ->
    $('#' + StartPage._UI_FLIGHT_SEARCH_INPUT).unbind('keyup')


  onFlightSearchChange= (newVal, count) ->
    try
      label = $('#' + StartPage._UI_FLIGHT_NOTIFICATION_LABEL)
      list = $('#' + StartPage._UI_FLIGHT_LIST)
      if newVal? and flightManager? and list? and label?
        list.empty()
        label.text('')

        if newVal.length > 0
          newFlights = flightManager.getFlightsById(newVal, count)
          console.dir(newFlights)

          if newFlights.length is count
            label.text('Rafiner søket for flere resultater')
          else if newFlights.length is 0
            label.text('Fant ingen flyavganger med søkeord: ' + newVal)
            return

          for e in newFlights
            if e?
              list.append('<li><table class="flightSearchResultElement"><tr><td>' + e.flightId + '</td><td>' + e.schedule_time + '</td><td>' + e.airport + '</td></tr></table></li>')

          $(list).listview("refresh")
    catch error


