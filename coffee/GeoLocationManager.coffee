class window.GeoLocationManager
  _location = null
  _instance = new GeoLocationManager()

  constructor: (useHighAccuracy = false) ->
    navigator.geolocation.getCurrentPosition(@onPositionSuccess, @onPositionError, { maximumAge: 10 * 60 * 1000, timeout: 5000, enableHighAccuracy: useHighAccuracy })

  getCurrentLocation: () ->
    return _location

  onPositionSuccess: (param) ->
    _location = param

  onPositionError: (error) ->
    console.log(error)

  @getInstance: () ->
    return _instance