class window.LoadScreen
  notificationLabelId = '#loadingText'
  instance = new LoadScreen();

  start: () ->
    if window.navigator.onLine
      GeoLocationManager.getInstance().fetchLocation(true)
      TrainStationManager.getInstance().fetchAllTrainStations()
      flightManager = FlightManager.getInstance()
      flightManager.fetchFlights(instance.onLoadComplete, instance.onLoadFail)
      #TransportationSelectionScreen.getInstance().reset()
    else
      $(notificationLabelId).val('Du må være koblet til internett for å bruke denne applikasjonen')


  onLoadComplete: (arr) ->
    console.dir(arr)
    window.location.hash = "#transportationSelectionScreen"
    TransportationSelectionScreen.getInstance().reset()

  onLoadFail: (err) ->
    $(notificationLabelId).val('Feil ved henting av flydata')

  @getInstance: () ->
    return instance
