class window.ThePosition
  resultD = null

  geolocationError: (error) ->
    console.log(error)

  geolocationSuccess: (pos) ->
    if resultD? and pos?
      resultD.html("Lat:" + pos.coords.latitude + "<br />" +
                    "Lon:" + pos.coords.longitude + "<br />" +
                    "Acc:" + pos.coords.accuracy + "<br />")

  constructor: (resultDiv) ->
    resultD = resultDiv

  getPosition: () ->
    navigator.geolocation.getCurrentPosition(@geolocationSuccess, @geolocationError, { maximumAge: 3000, timeout: 5000, enableHighAccuracy: true })