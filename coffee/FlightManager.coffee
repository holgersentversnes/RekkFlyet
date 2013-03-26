class window.FlightManager
  instance = new FlightManager

  flightArray = new Array()
  airportMap = new Array();
  avinorFlightUrl = new FlightUrlBuilder('http://freberg.org/xmlproxy.php?url=', 'http://flydata.avinor.no/XmlFeed.asp?', 'OSL').timeFrom(0).timeTo(24).direction('D').build() # Url for Avinor, using freberg super hax proxy. Flights
  avinorAirportUrl = new FlightUrlBuilder('http://freberg.org/xmlproxy.php?url=', 'http://flydata.avinor.no/airportNames.asp?', '').build() # Url for Avinor, using freberg super hax proxy. Airports

  fetchFlights: (successCallback, errorCallback) ->
    if not window.navigator.onLine
      if errorCallback? then return errorCallback('Er ikke koblet til internett. Kan ikke hente fly informasjon.')

    jQuery.ajax
      url: avinorFlightUrl,
      dataType: 'jsonp',
      jsonp: 'jsonp',
      jsonpCallback: 'jsonCallback'

      error: (a, b, e) ->
        if errorCallback? then return errorCallback(e)

      success: (data) ->
        flightArray = new Array()
        try
          for f in data['flights']['flight']
            tmpFlight = new Flight(f)
            flightArray.push(tmpFlight)
        catch error
          return errorCallback('Feilet ved henting av fly')

      complete: () ->
        try
          if flightArray?
            flightArray.sort (one, two) ->
              if (one.flightId < two.flightId)
                return -1
              else if (one.flightId > two.flightId)
                return 1
              else
                return 0
        catch error
          return errorCallback('Feilet ved henting av fly')

        #if successCallback? then
        successCallback (flightArray)

  getFlightsById: (id, count) ->
    if not flightArray? then throw new Error('Har ikke hentet ned flyinformasjon')

    tmpLst = new Array()
    id = id.toUpperCase().trim();

    num = 0;
    for e in flightArray
      if (id is e.flightId.substring(0, id.length))
        tmpLst.push(e)
        num++
      if (num >= count)
        break

    return tmpLst

  getAirportNameById: (id, callback, errorCallback) ->
    try
      id = id.toUpperCase().trim()
      airport = airportMap[id]
      if not airport?
        @_fetchAirportNameById(id, callback, errorCallback)
      else
        callback(airport)

    catch error
      airportMap[id] = id
      if errorCallback? then errorCallback('Feil ved henting av flyplass, bruker flyplass kode')
      if callback? then callback(id)

  _fetchAirportNameById: (id, successCallback, errorCallback) ->
    if not window.navigator.onLine
      if errorCallback? then errorCallback('Er ikke koblet til internett, bruker flyplass kode')
      if successCallback? then successCallback(id)

    dataHolder = ""
    jQuery.ajax
      url: avinorAirportUrl + id,
      dataType: 'jsonp',
      jsonp: 'jsonp',
      jsonpCallback: 'jsonCallback'

      error: (a, b, e) ->
        if errorCallback? then return errorCallback(b)

      success: (responseData) ->
        dataHolder = responseData

      complete: () ->
        airportName = id;
        try
          tmp = dataHolder['airportName']['@attributes']['name']
          airportMap[id] = tmp
          airportName = tmp
        catch error
          if errorCallback? then errorCallback('Feil ved henting av flyplass, bruker flyplass kode')

        if successCallback? then successCallback (airportName)

  @getInstance: () ->
    return instance

class Flight
# Constructor takes a json flight object as argument.
  constructor: (flightObject) ->
    @uniqueId = flightObject['@attributes']['uniqueID']
    @flightId = flightObject['flight_id'].toUpperCase()
    @dom_int = flightObject['dom_int']
    @scheduled_time_date = new Date(flightObject['schedule_time'])

    minutes = @scheduled_time_date.getMinutes()
    hours = @scheduled_time_date.getHours()

    day = @scheduled_time_date.getDay()
    month = @scheduled_time_date.getMonth()

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

  getRuterFlightFormat: () ->
    day = @scheduled_time_date.getDate()
    month = parseInt(@scheduled_time_date.getMonth()) + 1
    year = @scheduled_time_date.getFullYear()
    hour = @scheduled_time_date.getHours()
    minutes = @scheduled_time_date.getMinutes()

    if day < 10 then day = "0" + day
    if month < 10 then month = "0" + month
    if hour < 10 then hour = "0" + hour
    if minutes < 10 then minutes = "0" + minutes

    return day + month + year + hour + minutes


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
