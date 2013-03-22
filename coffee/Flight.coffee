class window.Flight
  @_FLIGHTS_ARRAY
  @_AIRPORT_MAP = []
  @_AIRPORT_URL = new UrlBuilder('http://freberg.org/xmlproxy.php?url=', 'http://flydata.avinor.no/airportNames.asp?', '').build()

  constructor: (fo) ->
    @uniqueId = fo['@attributes']['uniqueID']
    @flightId = fo['flight_id'].toUpperCase()
    @dom_int = fo['dom_int']
    @schedule_time = new Date(fo['schedule_time'])
    @arr_dep = fo['arr_dep']
    @airport = fo['airport']

    @via_airport(fo)
    @check_in(fo)
    @gate(fo)
    @status(fo)

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

  @fetchFlights: (url, callback, errorCallback) ->
    if not window.navigator.onLine
      if errorCallback?
        errorCallback('Er ikke koblet til internett. Kan ikke hente fly')
      if callback?
        Flight._FLIGHTS_ARRAY = new Array()
        return callback(Flight._FLIGHTS_ARRAY)

    jQuery.ajax
      url: url,
      dataType: 'jsonp',
      jsonp: 'jsonp',
      jsonpCallback: 'jsonCallback'

      error: (a, b, e) ->
        alert e;
        console.log(e);

      success: (data) ->
        Flight._FLIGHTS_ARRAY = new Array()
        for f in data['flights']['flight']
          tmpFlight = new Flight(f)
          Flight._FLIGHTS_ARRAY.push(tmpFlight)

      complete: () ->
        Flight._FLIGHTS_ARRAY.sort (aa, bb) ->
          if (aa.flightId < bb.flightId)
            return -1
          else if (aa.flightId > bb.flightId)
            return 1
          else
            return 0
        callback(Flight._FLIGHTS_ARRAY)

  @getFlightsById: (id, count) ->
    if Flight._FLIGHTS_ARRAY?
      tmpLst = new Array()
      id = id.toUpperCase()

      num = 0
      for e in Flight._FLIGHTS_ARRAY
        if (id is e.flightId.substring(0, id.length))
          tmpLst.push(e)
          num++
        if (num >= count)
          break
    else
      throw new Error("Har ikke hentet ned flyinformasjon")

    return tmpLst


  ###
    First checks the @_AIRPORT_MAP for entries with the given id, if not there, @_fetchAirportNameById(id, callback) will be called.
  ###
  @getAirportNameById: (id, callback, errorCallback) ->
    id = id.toUpperCase().trim()
    try
      flight = Flight._AIRPORT_MAP[id]
      if not flight?
        @_fetchAirportNameById(id, callback, errorCallback)
      else
        callback(flight)

    catch error
      Flight._AIRPORT_MAP[id] = id
      errorCallback('Feil ved henting av flyplass, bruker flyplass kode')
      callback(id)

  ###
    Requests the name of an airport where id == code. Sends result back to callback provided as param, and stores the value in @_AIRPORT_MAP
  ###
  @_fetchAirportNameById: (id, completeCallback, errorCallback) ->
    if not window.navigator.onLine
      if errorCallback?
        errorCallback('Er ikke koblet til internett, bruker flyplass koder')

      if completeCallback?
        return completeCallback(id)


    dataHolder = ""
    url = Flight._AIRPORT_URL += id
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
          Flight._AIRPORT_MAP[id] = tmp
          airportName = tmp
        catch e
          if errorCallback?
            errorCallback('Feil ved henting av flyplass, bruker flyplass kode')

        if airportName? and completeCallback?
          completeCallback(airportName)


###
  lastUpdate      - o   // Følger med hele objektet, ikke hver enkelt entry
  uniqueId        - o   // Ligger under Attributes
  flightId        - o
  dom_int         - o
  schedule_time   - o
  arr_dep         - o
  airport         - o   // Dersom Arr_dep == A så viser den hvor den kom fra, dersom App_dep == D viser den hvor den skal
  airline         - o   // Viser IATA koden for flyselskapet
  via_airport     - io  // Viser eventuelle mellomlandinger, max 6 IATA koder skilt med ','
  check_in        - io  // Viser innsjekkingsområde (bare tilgjengelig for oslo lufthavn)
  gate            - io  // Viser gatenummer. Kan inneholde både tall og bokstaver
  status_code     - io  // viser status for flyet:
                            A = Arrived
                            C = Innstilt (Canceled)
                            D = Avreist (Departed)
                            E = Ny Tid (New Time)
                            N = Ny Info (New Info)
  status_time     - io  // Attributt "time" på elementet status gir statustindspunkt for et flight.
  belt_number     - io  // Angir hvilket bagasjebånd som benyttes for et flight
###