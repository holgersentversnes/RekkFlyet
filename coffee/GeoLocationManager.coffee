class window.GeoLocationManager
  _instance = new GeoLocationManager()
  _location = null

  fetchLocation: (useHighAccuracy = false) ->
    navigator.geolocation.getCurrentPosition(@onPositionSuccess, @onPositionError, { maximumAge: 10 * 60 * 1000, timeout: 5000, enableHighAccuracy: useHighAccuracy })

  getCurrentLocation: () ->
    return _location

  onPositionSuccess: (param) ->
    _location = param
    #console.log(param)

  onPositionError: (error) ->
    console.log(error)

  @getInstance: () ->
    return _instance