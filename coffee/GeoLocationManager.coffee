class window.GeoLocationManager
  _location = null
  _instance = new GeoLocationManager()

  constructor: () ->
    @getPosition()

  getCurrentLocation: () ->
    return _location

  onPositionSuccess: (param) ->
    _location = param

  onPositionError: (error) ->
    console.log(error)

  getPosition: (useHighAccuracy = false) ->
    navigator.geolocation.getCurrentPosition(@onPositionSuccess, @onPositionError, { maximumAge: 10 * 60 * 1000, timeout: 5000, enableHighAccuracy: useHighAccuracy })

  @getInstance: () ->
    return _instance