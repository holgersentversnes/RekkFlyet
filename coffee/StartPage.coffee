class window.StartPage
  @_UI_FLIGHT_LIST = "flightList"
  @_UI_FLIGHT_NOTIFICATION_LABEL = "flightNotificationLabel"
  @_UI_FLIGHT_SEARCH_INPUT = "searchFlights"
  @_FLIGHT_LIST_MAX_COUNT = 5
  @_UI_FLIGHT_PAGE_CONTENT = "StartPageFlightContent"

  flightManager = null
  instance = null

  constructor: () ->
    flightManager = new FlightManager()
    flightManager.fetchFlights(@fetchFlightsCallback, @reportError)

  reportError: (errorMessage) ->
    console.log(errorMessage)

  fetchFlightsCallback: (flightArray) ->
    console.dir(flightArray)
    flightManager.getAirportNameById('osl', @getAirportByNameCallback, @reportError)

  getAirportByNameCallback: (name) ->
    console.log(name)

  show: () =>
    try
      $('#' + StartPage._UI_FLIGHT_PAGE_CONTENT).show()
      $('#' + StartPage._UI_FLIGHT_SEARCH_INPUT).on 'keyup', () ->
        #val = $('#' + StartPage._UI_FLIGHT_SEARCH_INPUT).val()
        #StartPage.getInstance().onFlightSearchChange(val, StartPage._FLIGHT_LIST_MAX_COUNT)
    catch error
      console.error(error)

  hide: () ->
    $('#' + StartPage._UI_FLIGHT_PAGE_CONTENT).hide()
    $('#' + StartPage._UI_FLIGHT_SEARCH_INPUT).unbind('keyup')


  onFlightSearchChange: (newVal, count) =>
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
          #else if newFlights.length is 1
            #$('#' + StartPage._UI_FLIGHT_SEARCH_INPUT).val(newFlights[0].flightId)
            #return
            #return

          for e in newFlights
            if e?
              list.append('<li id=' + e.flightId + '><table class="flightSearchResultElement"><tr><td>' + e.flightId + '</td><td>' + e.schedule_time + '</td><td>' + e.airport + '</td></tr></table></li>')

          $(list).delegate 'li', 'click', (e) ->
            val = e['currentTarget']['id']
            onFlightSelected(val)
            $('#' + StartPagve._UI_FLIGHT_SEARCH_INPUT).val(val)
          $(list).listview("refresh")
    catch error

  onFlightSelected= (val) ->
    flight = flightManager.getFlightsById(val, 1)
    hide()


  @getInstance: ->
    instance ?= new StartPage();


