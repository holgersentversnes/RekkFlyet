class window.TrainStation
  trainStationArray = new Array();

  constructor: (trainStation) ->
    @id = trainStation['id']
    @name = trainStation[ "name" ]
    @x = trainStation[ "x" ]
    @y = trainStation[ "y" ]
    @latitude = trainStation[ "latitude" ]
    @longitude = trainStation[ "longitude" ]

  @getAllTrainStations: () ->
    return trainStationArray