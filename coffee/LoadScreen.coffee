class window.LoadScreen
  notificationLabelId = '#LoadScreenContentLabel'

  start: () ->
    if window.navigator.onLine
      flightManager = FlightManager.getInstance()
      flightManager.fetchFlights(@onLoadComplete, @onLoadFail)
      #FlightManager.getInstance().getAirportNameById('osl', @onLoadComplete, @onLoadFail)
      #$.mobile.loading('show', text: 'Henter flyavganger.', textVisible: true, theme: 'c', html: "")
    else
      #$.mobile.loading('show', text: 'Du er ikke koblet til internett', textVisible: true, theme: 'd', textonly: true)

  onLoadComplete: (arr) ->
    #$.mobile.loading('hide')
    console.dir(arr)


  onLoadFail: (err) ->
    console.log('onLoadFail: ' + err)
    #$.mobile.loading('hide')
    #$(notificationLabelId).text('Feil ved henting av flyavganger')