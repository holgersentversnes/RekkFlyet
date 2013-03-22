class window.StartPage
  @_FLIGHT_URL = new UrlBuilder('http://freberg.org/xmlproxy.php?url=', 'http://flydata.avinor.no/XmlFeed.asp?', 'OSL').timeFrom(0).timeTo(24).direction('D').build()
  @_FLIGHTS

  reportError= (error) ->
    console.log(error)

  fetchFlightsCallback= (flights) ->
    StartPage._FLIGHTS = flights
    console.dir(flights)

  constructor: (@flightsList, @flightsLabelNotifaction) ->
    Flight.fetchFlights(StartPage._FLIGHT_URL, fetchFlightsCallback, reportError)

  onFlightSearchChange: (newValue) ->
    if newValue? and @flightsList? and StartPage._FLIGHTS? and @flightsLabelNotifaction?
      @flightsList.empty()
      @flightsLabelNotifaction.text('')
      if newValue.length > 0
        count = 5
        newFlights = Flight.getFlightsById(newValue, count)
        console.dir(newFlights)

        if newFlights.length is count
          @flightsLabelNotifaction.text('Rafiner søket for flere resultater: ')
        else if newFlights.length is 0
          @flightsLabelNotifaction.text('Fant ingen flyavganger med søkeord: ' + newValue)

        for e in newFlights
          if e?
            #@flightsList.append('<li>' + e.flightId + '</p>' + e.airport + '</li>')  #$('<li-ul/>', { 'text': e.flightId }))
            @flightsList.append('<li><table class="flightSearchResultElement"><tr><td>' + e.flightId + '</td><td>' + e.schedule_time + '</td><td>' + e.airport + '</td></tr></table></li>')
            #listView.append($('<a/>', { 'text': 'waffle' }))
        $(@flightsList).listview("refresh")


