class window.TrainManager
  instance = new TrainManager

  @_TRAIN_ARRAY #List of all the trains returned by Ruter
  @_TRAINS_TO_SHOW_ARRAY  #List of all the trains that should be shown to the user
  _USER_TRAIN_STATION_ID = 0 #= 2190400         #Skal hentes fra inputfelt
  _USER_TIME_FROM_FLIGHT = 0 #= 260320131500    #Skal hentes fra inputfelt
  @_RUTER_TRAIN_URL = "http://freberg.org/jsonpproxy.php?url="; # + encodeURIComponent("http://api-test.trafikanten.no/TravelStage/GetDeparturesAdvanced/" + @_USER_TRAIN_STATION_ID + "?time=" + @_USER_TIME_FROM_FLIGHT + "&lines=FT&transporttypes=AirportTrain&proposals=1");
  @_CHOSEN_FLIGHT_FROM_START_PAGE = null

  setUserTrainStationID: (trainStationID) ->
    _USER_TRAIN_STATION_ID = trainStationID #2190400

  #TODO: SET TIDEN AKKURAT NÅ OG IKKE NOE FRA FLYET
  setUserTimeFromFlight: (flightTime) ->
    #_USER_TIME_FROM_FLIGHT = flightTime #260320131500
    _USER_TIME_FROM_FLIGHT = "020420131452"
    console.log("Sjekk denne tiden: " + TrainManager._USER_TIME_FROM_FLIGHT)

  getDateNowInRuterFormat: () ->
    today = new Date()

    day = today.getDate()
    month = parseInt(today.getMonth()) + 1
    year = today.getFullYear()
    hour = today.getHours()
    minutes = today.getMinutes()

    if day < 10 then day = "0" + day
    if month < 10 then month = "0" + month
    if hour < 10 then hour = "0" + hour
    if minutes < 10 then minutes = "0" + minutes

    _USER_TIME_FROM_FLIGHT = day + month + year + hour + minutes
    #return day + month + year + hour + minutes

  createEncodedProxyURL: (trainStationID, flightObject) ->
    @setUserTrainStationID(trainStationID)
    #@setUserTimeFromFlight(flightObject.getRuterFlightFormat())
    @getDateNowInRuterFormat()

    if _USER_TRAIN_STATION_ID != 0 and _USER_TIME_FROM_FLIGHT != 0
      #TrainManager._RUTER_TRAIN_URL = ""
      TrainManager._RUTER_TRAIN_URL = "http://freberg.org/jsonpproxy.php?url="
      TrainManager._RUTER_TRAIN_URL += encodeURIComponent("http://api-test.trafikanten.no/TravelStage/GetDeparturesAdvanced/" + _USER_TRAIN_STATION_ID + "?time=" + _USER_TIME_FROM_FLIGHT + "&lines=FT&transporttypes=AirportTrain&proposals=1");
      console.log("User train id: " + _USER_TRAIN_STATION_ID)
      console.log("User time from flight: " + _USER_TIME_FROM_FLIGHT)
      console.log("Ruter URL = " + TrainManager._RUTER_TRAIN_URL)

  #Denne skal kalles fra StartPage
  fetchTrains: (trainStationID, flightObject, onSuccessCallback) ->
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

        #console.log("UNDEFINED??!?!?!" + TrainManager._TRAIN_ARRAY)

        #if not TrainManager._TRAIN_ARRAY?
        #  TrainManager._TRAIN_ARRAY = null

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

        console.log(TrainManager._TRAIN_ARRAY.length)
      complete: () ->
        TrainManager.getInstance().getPossibleTrainList trainStationID, flightObject

        # TODO: endre fra scheduled_time_date til latestArrivalAtAirport
        TrainManager.getInstance().getTrainsThatArrivesBefore flightObject.scheduled_time_date, 5, (trainList) ->
          onSuccessCallback(trainList)


  getTrainsThatArrivesBefore: (arrivalTimeAtGardermoen, numberOfTrainDepartures, onTrainListCompleteCallback) ->
    TrainManager._TRAINS_TO_SHOW_ARRAY = new Array()

    counter = 1
    console.log("A")
    #console.dir(TrainManager._TRAIN_ARRAY.length)
    for f in TrainManager._TRAIN_ARRAY
      console.log("B")
      #console.log(f.scheduled_time_date)
      trainArrivalDate = new Date(f.arrivalTime)
      arrivalDate = new Date(arrivalTimeAtGardermoen)

      console.log("trainDate:" + f.arrivalTime)
      console.log("arrivalDate:" + arrivalDate)

      MINUTE = 1000 * 60
      timeDiff = Math.round((arrivalDate.getTime() - trainArrivalDate.getTime()) / MINUTE)
      console.log("timeDiff: " + timeDiff)


      if timeDiff <= 60 and timeDiff > 0
        console.log("C")
        # TODO: sjekk at ikke counter er mindre enn numberOfTrainDepartures
        if counter >= numberOfTrainDepartures
          console.log("D")
          for i in [counter...counter - numberOfTrainDepartures]
            trainz = TrainManager._TRAIN_ARRAY[i]
            TrainManager._TRAINS_TO_SHOW_ARRAY.push(trainz)
            #break
        else if counter < numberOfTrainDepartures
          console.log("E")
          for i in [counter...0]
            trainz = TrainManager._TRAIN_ARRAY[i]
            TrainManager._TRAINS_TO_SHOW_ARRAY.push(trainz)
            #break
        else
          console.log("ERROR I OPPRETTING AV TRAINS_TO_SHOW_ARRAY")
        break
      else
        counter++

    console.dir(TrainManager._TRAINS_TO_SHOW_ARRAY)
    onTrainListCompleteCallback(TrainManager._TRAINS_TO_SHOW_ARRAY)


  getPossibleTrainList: (trainStationID, flightObject) ->
    if flightObject?
      console.log("KJØRER DENNE?")
      console.dir(TrainManager._TRAIN_ARRAY)
      return TrainManager._TRAIN_ARRAY

  @getInstance: () ->
    return instance

class Train
  #Constructor takes a json train object as argument
  constructor: (trainObject) ->
    @departureStation = trainObject['DepartureStop']['Name']
    @departureTime = trainObject['ActualTime']
    @arrivalStation = trainObject['Destination']
    @arrivalTime = trainObject['ArrivalTime']