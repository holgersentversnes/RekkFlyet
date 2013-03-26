class window.TrainManager
  @_TRAIN_ARRAY #List of all the trains returned by Ruter
  _USER_TRAIN_STATION_ID = 0 #= 2190400         #Skal hentes fra inputfelt
  _USER_TIME_FROM_FLIGHT = 0 #= 260320131500    #Skal hentes fra inputfelt
  @_RUTER_TRAIN_URL = "http://freberg.org/jsonpproxy.php?url="; # + encodeURIComponent("http://api-test.trafikanten.no/TravelStage/GetDeparturesAdvanced/" + @_USER_TRAIN_STATION_ID + "?time=" + @_USER_TIME_FROM_FLIGHT + "&lines=FT&transporttypes=AirportTrain&proposals=1");
  @_CHOSEN_FLIGHT_FROM_START_PAGE = null

  setUserTrainStationID: (trainStationID) ->
    _USER_TRAIN_STATION_ID = trainStationID #2190400

  setUserTimeFromFlight: (flightTime) ->
    _USER_TIME_FROM_FLIGHT = flightTime #260320131500

  createEncodedProxyURL: (trainStationID, flightObject) ->
    @setUserTrainStationID(trainStationID)
    @setUserTimeFromFlight(flightObject.getRuterFlightFormat)
    console.log("ASL")

    if _USER_TRAIN_STATION_ID != 0 and _USER_TIME_FROM_FLIGHT != 0
      TrainManager._RUTER_TRAIN_URL += encodeURIComponent("http://api-test.trafikanten.no/TravelStage/GetDeparturesAdvanced/" + _USER_TRAIN_STATION_ID + "?time=" + _USER_TIME_FROM_FLIGHT + "&lines=FT&transporttypes=AirportTrain&proposals=1");

  #Denne skal kalles fra StartPage
  fetchTrains: (trainStationID, flightObject) ->
    @createEncodedProxyURL(trainStationID, flightObject)
    jQuery.ajax
      url: TrainManager._RUTER_TRAIN_URL,
      dataType: 'jsonp',
      jsonp: 'jsonp',
      jsonpCallback: 'jsonpCallback'

      error: (a, b, e) ->
        console.log("Errorz: " + e)

      success: (data) ->
        returnData = JSON.parse(data)
        TrainManager._TRAIN_ARRAY = new Array()

        for t in returnData
          train = new Train(t)
          timeTemp = train.departureTime.substr(6, 19)
          depTime = new Date(parseInt(timeTemp))
          train.departureTime = depTime

          timeTemp = train.arrivalTime.substr(6, 19)
          arrTime = new Date(parseInt(timeTemp))
          train.arrivalTime = arrTime

          TrainManager._TRAIN_ARRAY.push(train)

          #console.log("Departure station: " + train.departureStation)
          #console.log("Departure time: " + depTime)
          #console.log("Arrival station: " + train.arrivalStation)
          #console.log("Arrival time: " + train.arrivalTime)
          #console.log("=====================================================")
        console.log(TrainManager._TRAIN_ARRAY.length)
        complete: () ->
          @getPossibleTrainList(trainStationID, flightObject)

  getPossibleTrainList: (trainStationID, flightObject) ->
    if flightObject?
      #@fetchTrains(trainStationID, flightObject)
      console.log("asdl")

    console.log("LOL")


class Train
  #Constructor takes a json train object as argument
  constructor: (trainObject) ->
    #@trainStationId = trainObject[]
    @departureStation = trainObject['DepartureStop']['Name']
    @departureTime = trainObject['ActualTime']
    @arrivalStation = trainObject['Destination']
    @arrivalTime = trainObject['ArrivalTime']