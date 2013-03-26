###

File name: TrainStation.coffee
Last updated: March 25th, 2013
Version: 1.0

Description:
  A train station is defined by its ID, name and position (both geographical and UTM coordinates). It contains one
  method, closestTo(), for setting the object's attributes to the closest airport train station based on a specific
  latitude/longitude pair. It also provides a reset method. When either method is called, the object's onUpdated
  callback will be called in order to allow GUI to be updated, etc.

Usage example:

  onStationUpdate = ( station ) =>
    console.log( station.name )

  station = new TrainStation( onStationUpdate )
  station.closestTo( 60, 11 )

###

class window.TrainStation
  @id
  @name
  @x
  @y
  @latitude
  @longitude


  constructor: ( @onUpdated ) ->
    @reset()


  reset: () =>
    @id = -1
    @name = "Ukjent stasjon"
    @x = 0
    @y = 0
    @latitude = 0.0
    @longitude = 0.0

    @_notifyUpdated()


  closestTo: ( latitude, longitude ) =>
    @latitude = latitude
    @longitude = longitude
    jQuery.getJSON( "json/airporttrain_stations.json", @_saveClosestTrainStationInformation )


  _notifyUpdated: () =>
    if ( @onUpdated? )
      @onUpdated( this )


  _saveClosestTrainStationInformation: ( stations ) =>
    latitude = @latitude
    longitude = @longitude

    closestStationInformation = null
    closestDistance = -1

    for stationInformation in stations
      @_setInformation( stationInformation )

      distance = @_getGeometricalDistanceFrom( latitude, longitude )

      if closestDistance < 0 or distance <= closestDistance
        closestStationInformation = stationInformation
        closestDistance = distance

    @_setInformation( closestStationInformation )
    @_notifyUpdated()


  _setInformation: ( information ) =>
    @id = information[ "id" ]
    @name = information[ "name" ]
    @x = information[ "x" ]
    @y = information[ "y" ]
    @latitude = information[ "latitude" ]
    @longitude = information[ "longitude" ]


  _getGeometricalDistanceFrom: ( latitude, longitude ) =>
    deltaLatitude = @latitude - latitude
    deltaLongitude = @longitude - longitude
    return Math.sqrt( Math.pow( deltaLatitude, 2 ), Math.pow( deltaLongitude, 2 ) )