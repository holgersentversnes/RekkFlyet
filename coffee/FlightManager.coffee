class window.FlightManager
  instance = null
  @_FLIGHTS_ARRAY   # List of all the flights returned by Avinor
  @_AIRPORT_MAP = []# Map containing the loaded aiport names. key: code, value: name
  @_AVINOR_AIRPORT_URL = new UrlBuilder('http://freberg.org/xmlproxy.php?url=', 'http://flydata.avinor.no/airportNames.asp?', '').build() # Url for Avinor, using freberg super hax proxy. Airports
  @_AVINOR_FLIGHT_URL = new UrlBuilder('http://freberg.org/xmlproxy.php?url=', 'http://flydata.avinor.no/XmlFeed.asp?', 'OSL').timeFrom(2).timeTo(24).direction('D').build() # Url for Avinor, using freberg super hax proxy. Flights

  # Fetches all the flights returned by Avinor using the @_AVINOR_FLIGHT_URL.
  # Takes two functions as callback. successCallback(Array) and errorCallback(message).
  # Checks if phone is connected to the internet. If not, it will an error message via errorCallback and a empty array to successCallback.
  fetchFlights: (successCallback, errorCallback) ->
    if not window.navigator.onLine
      if errorCallback?
        errorCallback 'Er ikke koblet til internett. Kan ikke hente fly.'
      if successCallback?
        FlightManager._FLIGHTS_ARRAY = new Array()
        return successCallback Flights._FLIGHTS_ARRAY

    jQuery.ajax
      url: FlightManager._AVINOR_FLIGHT_URL,
      dataType: 'jsonp',
      jsonp: 'jsonp',
      jsonpCallback: 'jsonCallback'

      error: (a, b, e) ->
        if errorCallback?
          errorCallback e

      success: (data) ->
        FlightManager._FLIGHTS_ARRAY = new Array()
        for f in data['flights']['flight']
          tmpFlight = new Flight(f)
          FlightManager._FLIGHTS_ARRAY.push(tmpFlight)

      complete: () ->
        FlightManager._FLIGHTS_ARRAY.sort (aa, bb) ->
          if (aa.flightId < bb.flightId)
            return -1
          else if (aa.flightId > bb.flightId)
            return 1
          else
            return 0
        successCallback(FlightManager._FLIGHTS_ARRAY)

  # Returns an array where all the entries are of type Flight where beginning of id is the same of the flight id.
  # Throws an error if no flight information has been fetched.
  getFlightsById: (id, count) ->
    if FlightManager._FLIGHTS_ARRAY?
      tmpLst = new Array()
      id = id.toUpperCase()

      num = 0
      for e in FlightManager._FLIGHTS_ARRAY
        if (id is e.flightId.substring(0, id.length))
          tmpLst.push(e)
          num++
        if (num >= count)
          break
    else
      throw new Error("Har ikke hentet ned flyinformasjon")
    return tmpLst

  # Returns the name of the airport in a callback. If an airport with the given id is not stored in the map, it will fetch it using fetchAirporNameById.
  # Value will be returned with callback.
  getAirportNameById: (id, callback, errorCallback) ->
    id = id.toUpperCase().trim()
    try
      flight = FlightManager._AIRPORT_MAP[id]
      if not flight?
        @fetchAirportNameById(id, callback, errorCallback)
      else
        callback(flight)

    catch error
      FlightManager._AIRPORT_MAP[id] = id
      errorCallback('Feil ved henting av flyplass, bruker flyplass kode')
      callback(id)

  # Fetches the airportname from Avinor using the ID. If nothing is returned (invalid id, no internet, or any other exception), the airport IATA code will be used.
  fetchAirportNameById: (id, completeCallback, errorCallback) ->
    if not window.navigator.onLine
      if errorCallback?
        errorCallback('Er ikke koblet til internett, bruker flyplass koder')

      if completeCallback?
        return completeCallback(id)


    dataHolder = ""
    url = FlightManager._AVINOR_AIRPORT_URL += id
    jQuery.ajax
      url: url,
      dataType: 'jsonp',
      jsonp: 'jsonp',
      jsonpCallback: 'jsonCallback'

      error: (a, b, e) ->
        console.log(e);

      success: (data) ->
        dataHolder = data

      complete: ->
        airportName = id
        try
          tmp = dataHolder['airportName']['@attributes']['name']
          FlightManager._AVINOR_AIRPORT_URL[id] = tmp
          airportName = tmp
        catch e
          if errorCallback?
            errorCallback('Feil ved henting av flyplass, bruker flyplass kode')

        if airportName? and completeCallback?
          completeCallback(airportName)

  @getInstance: () ->
    instance?= new FlightManager()

class Flight
  # Constructor takes a json flight object as argument.
  constructor: (flightObject) ->
    @uniqueId = flightObject['@attributes']['uniqueID']
    @flightId = flightObject['flight_id'].toUpperCase()
    @dom_int = flightObject['dom_int']
    tmpDate = new Date(flightObject['schedule_time'])

    minutes = tmpDate.getMinutes()
    hours = tmpDate.getHours()

    day = tmpDate.getDay()
    month = tmpDate.getMonth()

    if minutes < 10 then minutes = "0" + minutes
    if hours <10 then hours = "0" + hours

    if day < 10 then day = "0" + day
    if month < 10 then month = "0" + month

    @schedule_time = "Kl: " + hours + ":" + minutes + " - " + day + "/" + month
    @arr_dep = flightObject['arr_dep']
    @airport = flightObject['airport']

    @via_airport(flightObject)
    @check_in(flightObject)
    @gate(flightObject)
    @status(flightObject)

  via_airport: (val) ->
    if val['airport']?
      @via_airport = val['airport']
    else
      @via_airport = ""
    return this

  check_in: (val) ->
    if val['check_in']?
      @check_in = val['check_in']
    else
      @check_in = ""
    return this

  gate: (val) ->
    if val['gate']?
      @gate = val['gate']
    else
      @gate = ""
    return this

  status: (val) ->
    if val['status']?
      code = val.status['@attributes'].code
      time = val.status['@attributes'].time
      if not code? then code = ""
      if not time? then time = ""
      @status_code = code
      @status_time = time
    else
      @status_code = ""
      @status_time = ""
    return this