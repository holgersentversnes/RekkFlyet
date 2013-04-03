class TrainStation
  constructor: (trainStation) ->
    @id = trainStation['id']
    @name = trainStation[ "name" ]
    @x = trainStation[ "x" ]
    @y = trainStation[ "y" ]
    @latitude = trainStation[ "latitude" ]
    @longitude = trainStation[ "longitude" ]

class window.TrainStationManager
  trainStationArray = new Array()
  instance = new TrainStationManager()


  constructor: () ->

  fetchAllTrainStations: () ->
    jQuery.ajax
      url: "json/airporttrain_stations.json",
      async: false,
      dataType: 'json',
      success: (json) ->
        try
          for stationInfo in json
            ts = new TrainStation(stationInfo)
            trainStationArray.push(ts)
        catch error
          console.log error

  getClosestTrainStation: (lat, long) ->
    if trainStationArray.length is 0 then fetchAllTrainStations()

    closestStation = null
    closestDistance = -1

    for e in trainStationArray
      distance = instance.getGeometricalDistanceFrom e, lat, long

      if closestDistance < 0 or distance <= closestDistance
        closestStation = e
        closestDistance = distance
    return closestStation

  getGeometricalDistanceFrom: (station, lat, long) ->
    deltaLatitude = station.latitude - lat
    deltaLongitude = station.longitude - long
    return Math.sqrt( Math.pow( deltaLatitude, 2 ) + Math.pow( deltaLongitude, 2 ) )

  @getInstance: () ->
    return instance

  getAllTrainStations: () ->
    return trainStationArray




