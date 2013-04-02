class window.GeoLocationManager
  @getPosition: (success, error, useHighAccuracy = false) ->
    navigator.geolocation.getCurrentPosition(success, error, { maximumAge: 10 * 60 * 1000, timeout: 5000, enableHighAccuracy: useHighAccuracy })